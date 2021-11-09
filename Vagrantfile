Vagrant.configure("2") do |config|
    # Provider for Docker
    config.vm.provider :docker do |docker, override|
      override.vm.box = nil
      docker.image = "rofrano/vagrant-provider:ubuntu"
      docker.remains_running = true
      docker.has_ssh = true
      docker.privileged = true
      docker.volumes = ["/sys/fs/cgroup:/sys/fs/cgroup:ro", "/Users/rudimk/.ssh:/home/vagrant/.ssh", "/Users/rudimk/Documents/codevault/leanstack-acs-controller:/leanstack-acs-controller"]
      docker.create_args = ['--platform=linux/amd64']
    end
    config.vm.hostname = "leanstack-acs-controller-box"
    config.vm.synced_folder "/Users/rudimk/Documents/codevault/leanstack-acs-controller", "/leanstack-acs-controller"
    config.vm.synced_folder "/Users/rudimk/.ssh", "/home/vagrant/.ssh"
  end