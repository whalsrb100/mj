#!/bin/bash
source src/env
export KUBECONFIG=${OKD_HOME}/auth/kubeconfig

rm -f csr_count
Approve_count=0
while [ ${Approve_count} -lt $(expr ${WORKER_NUM} \* 2) ];do
  oc get csr | grep Pending | awk '{print "oc adm certificate approve "$1}' >> csr_count
  cat csr_count | sort -Vu > csr_count.tmp
  cat csr_count.tmp > csr_count
  cat csr_count | sh 2> /dev/null
  if [ $(cat csr_count | wc -l) -ge 4 ];then break;fi
done
rm -f csr_count
