#!/bin/bash
source src/env

openshift-install create ignition-configs --dir=${OKD_HOME}
chown apache. -R ${OKD_HOME}
