#!/bin/bash
oc get installplan -n metallb-system

oc get clusterserviceversion -n metallb-system \
  -o custom-columns=Name:.metadata.name,Phase:.status.phase
