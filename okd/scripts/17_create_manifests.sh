#!/bin/bash
source src/env
if [ -d ${OKD_HOME} ];then
  rm -rf ${OKD_HOME}
fi
mkdir ${OKD_HOME}
cp -a ${HTTP_HOME}/install-config.yaml ${OKD_HOME}/
openshift-install create manifests --dir=${OKD_HOME}
#openshift-install create ignition-configs --dir=${OKD_HOME}

chown apache. -R ${HTTP_HOME}/
