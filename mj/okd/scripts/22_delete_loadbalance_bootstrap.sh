#!/bin/bash
source src/env

N=$(cat /etc/haproxy/haproxy.cfg | grep ${BOOTSTRAP_HOSTNAME} | wc -l)
echo '[Before]'
cat /etc/haproxy/haproxy.cfg | grep ${BOOTSTRAP_HOSTNAME}
sed -i "/${BOOTSTRAP_HOSTNAME}/s/^/#/g" /etc/haproxy/haproxy.cfg
echo '[After]'
cat /etc/haproxy/haproxy.cfg | grep ${BOOTSTRAP_HOSTNAME}
if [ $(cat /etc/haproxy/haproxy.cfg | grep ${BOOTSTRAP_HOSTNAME} | grep ^'#' | wc -l) -eq ${N} ];then
  systemctl reload haproxy
  if [ $? -eq 0 ];then echo 'Haproxy Reload OK'
  else echo 'Haproxy Reload Have Problem..(reload failed.)';fi
else
  echo "Not OK haproxy configuration"
fi
