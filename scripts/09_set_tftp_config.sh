#!/bin/bash
source src/env
DEFAULT_GATEWAY=${BASTION_IP}
DNS=${BASTION_IP}

if [ ! -d /var/lib/tftpboot/pxelinux.cfg ];then
  mkdir /var/lib/tftpboot/pxelinux.cfg/
fi

if [ -e /var/lib/tftpboot/default ];then
  unlink /var/lib/tftpboot/default
fi
ln -sf pxelinux.cfg/default /var/lib/tftpboot/default
if [ -e /tftpboot ];then
  unlink /tftpboot
fi
ln -sf var/lib/tftpboot /tftpboot


cp /usr/share/syslinux/{menu.c32,ldlinux.c32,libutil.c32,pxelinux.0} /var/lib/tftpboot/
cat << EOF > /var/lib/tftpboot/pxelinux.cfg/default
default menu.c32
prompt 0
#timeout 20

LABEL ${BOOTSTRAP_HOSTNAME}
menu label ${BOOTSTRAP_HOSTNAME}
KERNEL ${kernel_file}
APPEND ksdevice=bootif initrd=${initrd_img} network console=tty0 console=ttyS0 coreos.live.rootfs_url=http://${BASTION_IP}:8080/${rootfs_img} coreos.inst.install_dev=vda coreos.inst.ignition_url=http://${BASTION_IP}:8080/okd/bootstrap.ign ip=${BOOTSTRAP_IP}::${DEFAULT_GATEWAY}:${SubnetMask}:${BOOTSTRAP_HOSTNAME}.${ClusterName}.${DomainName}:${PxeIfname}:none nameserver=${DNS}
#IPAPPEND 2

LABEL ${MASTER1_HOSTNAME}
menu label ${MASTER1_HOSTNAME}
KERNEL ${kernel_file}
APPEND ksdevice=bootif initrd=${initrd_img} network console=tty0 console=ttyS0 coreos.live.rootfs_url=http://${BASTION_IP}:8080/${rootfs_img} coreos.inst.install_dev=vda coreos.inst.ignition_url=http://${BASTION_IP}:8080/okd/master.ign ip=${MASTER1_IP}::${DEFAULT_GATEWAY}:${SubnetMask}:${MASTER1_HOSTNAME}.${ClusterName}.${DomainName}:${PxeIfname}:none nameserver=${DNS}
#IPAPPEND 2

LABEL ${MASTER2_HOSTNAME}
menu label ${MASTER2_HOSTNAME}
KERNEL ${kernel_file}
APPEND ksdevice=bootif initrd=${initrd_img} network console=tty0 console=ttyS0 coreos.live.rootfs_url=http://${BASTION_IP}:8080/${rootfs_img} coreos.inst.install_dev=vda coreos.inst.ignition_url=http://${BASTION_IP}:8080/okd/master.ign ip=${MASTER2_IP}::${DEFAULT_GATEWAY}:${SubnetMask}:${MASTER2_HOSTNAME}.${ClusterName}.${DomainName}:${PxeIfname}:none nameserver=${DNS}
#IPAPPEND 2

LABEL ${MASTER3_HOSTNAME}
menu label ${MASTER3_HOSTNAME}
KERNEL ${kernel_file}
APPEND ksdevice=bootif initrd=${initrd_img} network console=tty0 console=ttyS0 coreos.live.rootfs_url=http://${BASTION_IP}:8080/${rootfs_img} coreos.inst.install_dev=vda coreos.inst.ignition_url=http://${BASTION_IP}:8080/okd/master.ign ip=${MASTER3_IP}::${DEFAULT_GATEWAY}:${SubnetMask}:${MASTER3_HOSTNAME}.${ClusterName}.${DomainName}:${PxeIfname}:none nameserver=${DNS}
#IPAPPEND 2
EOF
for i in $(seq 1 ${WORKER_NUM});do
  WORKER_HOSTNAME=$(eval echo \$WORKER${i}_HOSTNAME)
  WORKER_IP=$(eval echo \$WORKER${i}_IP)
  if [ ${WORKER_HOSTNAME} ];then
    if [ ${WORKER_IP} ];then
      echo "" >> /var/lib/tftpboot/pxelinux.cfg/default
      echo "LABEL ${WORKER_HOSTNAME}" >> /var/lib/tftpboot/pxelinux.cfg/default
      echo "menu label ${WORKER_HOSTNAME}" >> /var/lib/tftpboot/pxelinux.cfg/default
      echo "KERNEL ${kernel_file}" >> /var/lib/tftpboot/pxelinux.cfg/default
      echo "APPEND ksdevice=bootif initrd=${initrd_img} network console=tty0 console=ttyS0 coreos.live.rootfs_url=http://${BASTION_IP}:8080/${rootfs_img} coreos.inst.install_dev=vda coreos.inst.ignition_url=http://${BASTION_IP}:8080/okd/worker.ign ip=${WORKER_IP}::${DEFAULT_GATEWAY}:${SubnetMask}:${WORKER_HOSTNAME}.${ClusterName}.${DomainName}:${PxeIfname}:none nameserver=${DNS}" >> /var/lib/tftpboot/pxelinux.cfg/default
      echo "#IPAPPEND 2" >> /var/lib/tftpboot/pxelinux.cfg/default
    fi
  fi
done


systemctl disable tftp.socket
systemctl start tftp.socket

