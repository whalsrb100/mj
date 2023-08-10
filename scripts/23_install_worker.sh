#!/bin/bash
source src/env
################################################
# /var/lib/tftpboot/pxelinux.cfg/default
################################################
# 0 : bootstrap
# 1 : master1
# 2 : master2
# 3 : master3
# 4 : worker1
# 5 : worker2
# 6 : worker3
# 7 : worker4
################################################

function modify_default() {
sed -i "s/default\s.*/default ${1}/" /var/lib/tftpboot/pxelinux.cfg/default
}




for i in $(seq 1 ${WORKER_NUM});do
  WORKER_HOSTNAME=$(eval echo \$WORKER${i}_HOSTNAME)
  WORKER_IP=$(eval echo \$WORKER${i}_IP)
  if [ ${WORKER_HOSTNAME} ];then
    if [ ${WORKER_IP} ];then
      modify_default ${WORKER_HOSTNAME}
      echo "Please Install \"${WORKER_HOSTNAME}.${ClusterName}.${DomainName}\" Node"
      while [ "$(ssh core@${WORKER_HOSTNAME}.${ClusterName}.${DomainName} 'hostname' 2> /dev/null)" != "${WORKER_HOSTNAME}.${ClusterName}.${DomainName}" ];do sleep 10;echo -n ".";done
      echo -e "\n${WORKER_HOSTNAME}.${ClusterName}.${DomainName} Installed !"
    fi
  fi
done

