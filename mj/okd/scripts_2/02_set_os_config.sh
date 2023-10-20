#!/bin/bash
source src/env
hostnamectl set-hostname ${BASTION_HOSTNAME}.${ClusterName}.${DomainName}
systemctl restart rsyslog systemd-hostnamed
sed -i 's/SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
setenforce 0
systemctl disable --now firewalld

sed -i "s/#   StrictHostKeyChecking ask/   StrictHostKeyChecking no/" /etc/ssh/ssh_config
systemctl restart sshd

