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
echo -ne "\nExecute Command: openshift-install wait-for install-complete --dir=${OKD_HOME} --log-level debug"
for i in $(seq 1 3);do echo -n '.';done && echo
openshift-install wait-for install-complete --dir=${OKD_HOME} --log-level debug
export KUBECONFIG=${OKD_HOME}/auth/kubeconfig
oc get co
echo "export KUBECONFIG=${OKD_HOME}/auth/kubeconfig"
echo "oc get co"

