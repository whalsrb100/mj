#!/bin/bash
source src/env

sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/*
cat << EOF > /etc/yum.repos.d/local.repo
[AppStream_iso]
name=AppStream_iso
baseurl=file:///media/AppStream
gpgcheck=0
enabled=1

[BaseOS_iso]
name=BaseOS_iso
baseurl=file:///media/BaseOS
gpgcheck=0
enabled=1
EOF

if [ $(df -P | awk '{if($NF=="/media")print}' | wc -l) -eq 0 ];then
  echo 'You need to Mount CentOS-8.3 image on "/media".'
  exit 1
fi

LOG_FILE="${0}_log"
dnf install -y tar bzip2 gzip xz jq git rsync vim net-tools sos sysstat bind bind-utils podman httpd-tools \
	dhcp-server tftp-server httpd syslinux libvirt-libs wget haproxy expect bc | tee ${LOG_FILE}

systemctl enable --now io.podman.service io.podman.socket podman.socket
systemctl disable dhcpd tftp.socket
