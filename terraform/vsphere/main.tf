variable "vsphere_user" {
  type = string
}

variable "vsphere_password" {
  type = string
}

variable "vsphere_server" {
  type = string
}

variable "vsphere_datacenter" {
  type = string
}

variable "vsphere_cluster" {
  type = string
}

variable "ssh_passwd" {
  type = string
}

variable "ssh_pub_key" {
  type = string
}

variable "vm_config_map" {
  type = list(object({
    vsphere_datastore = string
    vsphere_host = string
    vsphere_network = string
    vsphere_template = string
    vm_disk = number
    vm_vcpu = number
    vm_ram = number
    vm_name = string
    vm_guest = string
    vm_domain = string
    vm_ip = string
    vm_gateway = string
    }))
}


provider "vsphere" {
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = var.vsphere_server

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = var.vsphere_datacenter
}

data "vsphere_datastore" "datastore" {
  count = length(var.vm_config_map)
  name          = var.vm_config_map[count.index].vsphere_datastore
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.vsphere_cluster
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "network" {
  count = length(var.vm_config_map)
  name          = var.vm_config_map[count.index].vsphere_network
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_virtual_machine" "template" {
  count = length(var.vm_config_map)
  name          = var.vm_config_map[count.index].vsphere_template
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

resource "vsphere_virtual_machine" "vm" {
  count = length(var.vm_config_map)
  name             = var.vm_config_map[count.index].vm_name
  resource_pool_id = "${data.vsphere_compute_cluster.cluster.resource_pool_id}"
  datastore_id     = "${data.vsphere_datastore.datastore[count.index].id}"

  num_cpus = var.vm_config_map[count.index].vm_vcpu
  memory   = var.vm_config_map[count.index].vm_ram
  guest_id = var.vm_config_map[count.index].vm_guest
  host_system_id = var.vm_config_map[count.index].vsphere_host

  scsi_type = "${data.vsphere_virtual_machine.template[count.index].scsi_type}"

  network_interface {
    network_id   = "${data.vsphere_network.network[count.index].id}"
    adapter_type = "${data.vsphere_virtual_machine.template[count.index].network_interface_types[0]}"
  }

  disk {
    label            = "disk0"
    size             = var.vm_config_map[count.index].vm_disk
    eagerly_scrub    = "${data.vsphere_virtual_machine.template[count.index].disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.template[count.index].disks.0.thin_provisioned}"
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template[count.index].id}"

    customize {
      linux_options {
        host_name = var.vm_config_map[count.index].vm_name
        domain    = var.vm_config_map[count.index].vm_domain
      }

      network_interface {
        ipv4_address = var.vm_config_map[count.index].vm_ip
        ipv4_netmask = 24
      }
      dns_server_list = ["8.8.8.8"]

      ipv4_gateway = var.vm_config_map[count.index].vm_gateway
    }
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/ubuntu/.ssh",
      "touch /home/ubuntu/.ssh/authorized_keys",
      "echo ${var.ssh_pub_key} >> /home/ubuntu/.ssh/authorized_keys",
      "sudo growpart /dev/sda 2",
      "sudo resize2fs /dev/sda2"
    ]
  }
  connection {
    host = var.vm_config_map[count.index].vm_ip
    type = "ssh"
    user = "ubuntu"
    password = var.ssh_passwd
  }
}
