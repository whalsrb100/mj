#!/bin/bash
source src/env
cat ${OKD_HOME}/manifests/cluster-scheduler-02-config.yml | grep mastersSchedulable
sed -i 's/  mastersSchedulable: true/  mastersSchedulable: false/' ${OKD_HOME}/manifests/cluster-scheduler-02-config.yml
cat ${OKD_HOME}/manifests/cluster-scheduler-02-config.yml | grep mastersSchedulable
