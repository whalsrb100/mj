#!/bin/bash
source src/env
if [ -f /etc/dhcp/${DHCPCONFIGFILE} ];then
  CNT=1
  while [ -f /etc/dhcp/${DHCPCONFIGFILE}_backup_${CNT} ];do
    CNT=$(expr ${CNT} \+ 1)
  done
  mv /etc/dhcp/${DHCPCONFIGFILE} /etc/dhcp/${DHCPCONFIGFILE}_backup_${CNT}
fi
src/create_config_for_dhcpd /etc/dhcp/${DHCPCONFIGFILE}
systemctl disable dhcpd
systemctl start dhcpd
