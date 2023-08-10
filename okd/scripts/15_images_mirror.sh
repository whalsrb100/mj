#!/bin/bash
source src/env
OCP_RELEASE="${OCVersion}"
LOCAL_REGISTRY="${BASTION_HOSTNAME}.${ClusterName}.${DomainName}:5000"
LOCAL_REPOSITORY="openshift/okd"
PRODUCT_REPO="openshift"
RELEASE_NAME="okd"
LOCAL_SECRET_JSON="${PullSecret}"

GODEBUG=x509ignoreCN=0 oc adm -a ${LOCAL_SECRET_JSON} release mirror \
--from=quay.io/${PRODUCT_REPO}/${RELEASE_NAME}:${OCP_RELEASE} \
--to=${LOCAL_REGISTRY}/${LOCAL_REPOSITORY} \
--to-release-image=${LOCAL_REGISTRY}/${LOCAL_REPOSITORY}:${OCP_RELEASE}
