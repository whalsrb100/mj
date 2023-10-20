#!/bin/bash
source src/env
OCP_RELEASE="${OCVersion}"
LOCAL_REGISTRY="${BASTION_HOSTNAME}.${ClusterName}.${DomainName}:5000"
#LOCAL_REPOSITORY="okd/openshift4"
LOCAL_REPOSITORY="okd4/openshift"
PRODUCT_REPO="openshift"
RELEASE_NAME="okd"
LOCAL_SECRET_JSON="${PullSecret}"

#    # 4.12.21-x86_64
#    PRODUCT_REPO="openshift-release-dev"
#    RELEASE_NAME="ocp-release"
#    OCP_RELEASE="4.12.21-x86_64"
#    #4.12.0-0.okd-2023-04-16-041331

#GODEBUG=x509ignoreCN=0 oc adm -a ${LOCAL_SECRET_JSON} release mirror \
oc adm -a ${LOCAL_SECRET_JSON} release mirror \
--from=quay.io/${PRODUCT_REPO}/${RELEASE_NAME}:${OCP_RELEASE} \
--to=${LOCAL_REGISTRY}/${LOCAL_REPOSITORY} \
--to-release-image=${LOCAL_REGISTRY}/${LOCAL_REPOSITORY}:${OCP_RELEASE}
