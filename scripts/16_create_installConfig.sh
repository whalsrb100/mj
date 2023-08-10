#!/bin/bash
source src/env

rm -f ~/.ssh/{id_rsa,id_rsa.pub}

# expect -c "
# set timeout 2
# spawn ssh-keygen -t rsa
# expect ':'
# 	send \"\\n\"
# expect ':'
# 	send \"\\n\"
# expect ':'
# 	send \"\\n\"
# expect eof
# "


ssh-keygen -b 4096 -t rsa -f /root/.ssh/id_rsa -q -N ''


cat << EOF > ${HTTP_HOME}/install-config.yaml
apiVersion: v1
baseDomain: ${DomainName}
metadata:
  name: ${ClusterName}

compute:
- hyperthreading: Enabled
  name: worker
  replicas: 0

controlPlane:
  hyperthreading: Enabled
  name: master
  replicas: 3

networking:
  clusterNetwork:
  - cidr: 10.128.0.0/14 
    hostPrefix: 23 
  networkType: OpenShiftSDN
  serviceNetwork: 
  - 172.30.0.0/16

platform:
  none: {}

fips: false

pullSecret: '{"auths":{"${BASTION_HOSTNAME}.${ClusterName}.${DomainName}:5000":{"auth":"YWRtaW46YWRtaW4="}}}'
sshKey: '$(cat /root/.ssh/id_rsa.pub)'
additionalTrustBundle: |
$(cat ${CRT} | sed 's/^/  /g')
imageContentSources:
- mirrors:
  - ${BASTION_HOSTNAME}.${ClusterName}.${DomainName}:5000/openshift/okd
  source: quay.io/openshift/okd
- mirrors:
  - ${BASTION_HOSTNAME}.${ClusterName}.${DomainName}:5000/openshift/okd
  source: quay.io/openshift/okd-content
EOF
if [ -d ${OKD_HOME} ];then
rm -rf ${OKD_HOME}
fi
mkdir ${OKD_HOME}/
cp ${HTTP_HOME}/install-config.yaml ${OKD_HOME}/
chown apache. -R ${HTTP_HOME}/
