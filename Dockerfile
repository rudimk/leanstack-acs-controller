FROM ubuntu:18.04
MAINTAINER "Rudi MK <rudraksh@indiqus.com>"
LABEL Vendor="IndiQus" License="ApacheV2" Version="0.1.0"

# Basic housekeeping
RUN apt update
RUN apt install -y curl openssh-server

# Add ACS DEB packages for clodustack-management and clodustack-common, that you've built and copied into this directory, and then install them.

ADD cloudstack-common.deb /root/
ADD cloudstack-management.deb /root/
RUN dpkg -i /root/cloudstack-common.deb
RUN dpkg -i /root/cloudstack-management.deb
RUN locale-gen en_US.UTF-8

# Expose ports
EXPOSE 8080
EXPOSE 8250

