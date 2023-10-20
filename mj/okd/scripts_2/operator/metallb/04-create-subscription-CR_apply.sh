#!/bin/bash
oc create -f 04-create-subscription-CR.yaml
oc label ns metallb-system "openshift.io/cluster-monitoring=true"
