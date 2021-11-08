FROM jrei/systemd-ubuntu:18.04
MAINTAINER "Rudi MK <rudraksh@indiqus.com>"
LABEL Vendor="IndiQus" License="ApacheV2" Version="0.1.0"

# Basic housekeeping
RUN apt update
RUN apt install -y curl openssh-server genisoimage nfs-common python3-pip python3-distutils python3-distutils-extra python3-netaddr uuid-runtime openjdk-11-jre-headless sudo python3-mysql.connector augeas-tools mysql-client ipmitool gawk iproute2 qemu-utils python3-dnspython lsb-release locales mysql-server

# Add ACS DEB packages for cloudstack-management and cloudstack-common, that you've built and copied into this directory, and then install them.

RUN wget -O - http://download.cloudstack.org/release.asc | apt-key add -
RUN echo "deb http://download.cloudstack.org/ubuntu bionic 4.15" >> /etc/apt/sources.list.d/cloudstack.list
RUN apt update
RUN apt install -y cloudstack-common cloudstack-management cloudstack-usage
RUN locale-gen en_US.UTF-8


# Expose ports
EXPOSE 8080
EXPOSE 8250
EXPOSE 9090

