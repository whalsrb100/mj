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
rm -f ~/.ssh/known_hosts

function modify_default() {
sed -i "s/default\s.*/default ${1}/" /var/lib/tftpboot/pxelinux.cfg/default
}

modify_default ${BOOTSTRAP_HOSTNAME}
echo "Please Install \"${BOOTSTRAP_HOSTNAME}.${ClusterName}.${DomainName}\" Node"
while [ "$(ssh core@${BOOTSTRAP_HOSTNAME}.${ClusterName}.${DomainName} 'hostname' 2> /dev/null)" != "${BOOTSTRAP_HOSTNAME}.${ClusterName}.${DomainName}" ];do sleep 10;echo -n ".";done
echo -e "\n${BOOTSTRAP_HOSTNAME}.${ClusterName}.${DomainName} Installed !"
echo -ne "Wait for bootstrap health check"
while [ $(ssh core@${BOOTSTRAP_HOSTNAME}.${ClusterName}.${DomainName} "journalctl -b | grep 'healthy: successfully committed proposal'" 2> /dev/null | wc -l) -ne 1 ];do sleep 5;echo -n ".";done

modify_default ${MASTER1_HOSTNAME}
echo -e "\nPlease Install \"${MASTER1_HOSTNAME}.${ClusterName}.${DomainName}\" Node"
while [ "$(ssh core@${MASTER1_HOSTNAME}.${ClusterName}.${DomainName} 'hostname' 2> /dev/null)" != "${MASTER1_HOSTNAME}.${ClusterName}.${DomainName}" ];do sleep 10;echo -n ".";done
echo -e "\n${MASTER1_HOSTNAME}.${ClusterName}.${DomainName} Installed !"

modify_default ${MASTER2_HOSTNAME}
echo -e "\nPlease Install \"${MASTER2_HOSTNAME}.${ClusterName}.${DomainName}\" Node"
while [ "$(ssh core@${MASTER2_HOSTNAME}.${ClusterName}.${DomainName} 'hostname' 2> /dev/null)" != "${MASTER2_HOSTNAME}.${ClusterName}.${DomainName}" ];do sleep 10;echo -n ".";done
echo -e "\n${MASTER2_HOSTNAME}.${ClusterName}.${DomainName} Installed !"

modify_default ${MASTER3_HOSTNAME}
echo -e "\nPlease Install \"${MASTER3_HOSTNAME}.${ClusterName}.${DomainName}\" Node"
while [ "$(ssh core@${MASTER3_HOSTNAME}.${ClusterName}.${DomainName} 'hostname' 2> /dev/null)" != "${MASTER3_HOSTNAME}.${ClusterName}.${DomainName}" ];do sleep 10;echo -n ".";done
echo -e "\n${MASTER3_HOSTNAME}.${ClusterName}.${DomainName} Installed !"

echo "Check finished deploy coreos"
while [ $(ssh core@${MASTER1_HOSTNAME}.${ClusterName}.${DomainName} "journalctl | grep 'Created new deployment /ostree/deploy/fedora-coreos/deploy/' | wc -l") -ne 3 ];do sleep 2;done
echo "[${MASTER1_HOSTNAME}.${ClusterName}.${DomainName}] O K"
while [ $(ssh core@${MASTER2_HOSTNAME}.${ClusterName}.${DomainName} "journalctl | grep 'Created new deployment /ostree/deploy/fedora-coreos/deploy/' | wc -l") -ne 3 ];do sleep 2;done
echo "[${MASTER2_HOSTNAME}.${ClusterName}.${DomainName}] O K"
while [ $(ssh core@${MASTER3_HOSTNAME}.${ClusterName}.${DomainName} "journalctl | grep 'Created new deployment /ostree/deploy/fedora-coreos/deploy/' | wc -l") -ne 3 ];do sleep 2;done
echo "[${MASTER3_HOSTNAME}.${ClusterName}.${DomainName}] O K"


echo -ne "\nExecute Command: openshift-install wait-for bootstrap-complete --dir=${OKD_HOME} --log-level debug"
for i in $(seq 3 -1 1);do sleep 0.5;echo -ne "${i}";sleep 0.5;echo -en "\r";done && echo
openshift-install wait-for bootstrap-complete --dir=${OKD_HOME} --log-level debug

while [ $(for i in ${MASTER1_HOSTNAME} ${MASTER2_HOSTNAME} ${MASTER3_HOSTNAME};do ssh ${i}.${ClusterName}.${DomainName} -l core "journalctl | grep status=Running | wc -l";done | awk '{printf $1"+"}' | sed 's/+$/\n/' | bc) -lt 103 ];do
  sleep 5
done
echo 'Running Containers Check ok'
