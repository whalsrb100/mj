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

pullSecret: '{"auths":{"cloud.openshift.com":{"auth":"b3BlbnNoaWZ0LXJlbGVhc2UtZGV2K29jbV9hY2Nlc3NfYjQ3ODQwMGY4NDRjNDY5OWE1NTlhZmYzMzU2YTRlMDg6VUNZRldWR0wxT0NPNUlLTUFXTU5MWDJaQ1pJOThIOTVDOUtVU0MxRVZMSEpUOU9KSEkzVEsxNzkzRVJLQTJQUw==","email":"infra@growin.co.kr"},"quay.io":{"auth":"b3BlbnNoaWZ0LXJlbGVhc2UtZGV2K29jbV9hY2Nlc3NfYjQ3ODQwMGY4NDRjNDY5OWE1NTlhZmYzMzU2YTRlMDg6VUNZRldWR0wxT0NPNUlLTUFXTU5MWDJaQ1pJOThIOTVDOUtVU0MxRVZMSEpUOU9KSEkzVEsxNzkzRVJLQTJQUw==","email":"infra@growin.co.kr"},"registry.connect.redhat.com":{"auth":"fHVoYy1wb29sLThhNTg0YWI5LWE1ZDQtNGY5OS05MDgxLTI3OTYyOTAxYzc1NzpleUpoYkdjaU9pSlNVelV4TWlKOS5leUp6ZFdJaU9pSXlPRFUyWldJNFlXRXdOakUwTmpFd1lURTRNelZtTVdVek0yVTVabVF5TkNKOS5nSXdncDFscFVFSnNiYkdnXzU2RmZGal83X3pEQ1Ria1hEVVpJQTg2bW5tdW01ejJmTGNYRmZKc3VaOTJqbDRkYWJSaU5FNTNPQmhPdVVQeHRXcGl2VkJmdjN5NlpPb1NGSzJRSEdTa3VrYmFGY2h4bnJyQUpodDRZdkhZdS1qYkYwN1VNNTViLXFrU0dYTzlyVVBBRUw0aWd6SW5uZzFJRlBnVzdJWVkydGMycXdiVjFSc3J3Q0h3SWtEenBqX196Wi16ckxHWTFCMV9JNklUclBmM21fcUxhaTZSbHNiRG5qcnVnVll4MF81UG9iaGNRTzdNemEzV3FkakN6Y2hnalhEZFp3Z2FZM3Z3RmNyRlBaWkh6TDNCckprTWJrVGxLaG9xOVd6WlhacXhUemNfZEdXRDNidHMxWTNjT0xSdHFsUGZTWkpfQ21fdzBCZHdMZERuVVdfZFFadUQweVJxOVhUUGNVWEMtbnA0Q0JJVHRTQVVFLXd3ekVocXRKTVloMlNpbi1JRkJkcHc0cGxpblBNTXpMa0lob2czTTYzZjZaRERoSVI2akRFeXRjeGNRRWRJeEhERkI1VlhlcldmRHpCRUdRd19hMGNZQXV0ZE1TSmEtX00wTnRiQ3NwSkJpaGxPMEtJQklXR2xMb0x3WFFqaldxTGRHV05tRHhKeERFNWM4TGFKVGh2Z0dIdDdTQ3JiT1BySm5YblBSb00xd2pmR0l0cmw4YVBsSXJYLVN1cjNBZ2E1NlFfeGFKeTJhNUNiV0ZaNk5scW15SWRicXFEMEpjTm5oV2FrOV9raGpGLVphWFlKeHRfd1RHQjF6ZUhHcWdCYjhidXl0ekM1OHZCYUZucTdBR0lWWTR6NWMyVGg2ek1UZmk3cVhyYk1XWkstOTdfUkcybw==","email":"infra@growin.co.kr"},"registry.redhat.io":{"auth":"fHVoYy1wb29sLThhNTg0YWI5LWE1ZDQtNGY5OS05MDgxLTI3OTYyOTAxYzc1NzpleUpoYkdjaU9pSlNVelV4TWlKOS5leUp6ZFdJaU9pSXlPRFUyWldJNFlXRXdOakUwTmpFd1lURTRNelZtTVdVek0yVTVabVF5TkNKOS5nSXdncDFscFVFSnNiYkdnXzU2RmZGal83X3pEQ1Ria1hEVVpJQTg2bW5tdW01ejJmTGNYRmZKc3VaOTJqbDRkYWJSaU5FNTNPQmhPdVVQeHRXcGl2VkJmdjN5NlpPb1NGSzJRSEdTa3VrYmFGY2h4bnJyQUpodDRZdkhZdS1qYkYwN1VNNTViLXFrU0dYTzlyVVBBRUw0aWd6SW5uZzFJRlBnVzdJWVkydGMycXdiVjFSc3J3Q0h3SWtEenBqX196Wi16ckxHWTFCMV9JNklUclBmM21fcUxhaTZSbHNiRG5qcnVnVll4MF81UG9iaGNRTzdNemEzV3FkakN6Y2hnalhEZFp3Z2FZM3Z3RmNyRlBaWkh6TDNCckprTWJrVGxLaG9xOVd6WlhacXhUemNfZEdXRDNidHMxWTNjT0xSdHFsUGZTWkpfQ21fdzBCZHdMZERuVVdfZFFadUQweVJxOVhUUGNVWEMtbnA0Q0JJVHRTQVVFLXd3ekVocXRKTVloMlNpbi1JRkJkcHc0cGxpblBNTXpMa0lob2czTTYzZjZaRERoSVI2akRFeXRjeGNRRWRJeEhERkI1VlhlcldmRHpCRUdRd19hMGNZQXV0ZE1TSmEtX00wTnRiQ3NwSkJpaGxPMEtJQklXR2xMb0x3WFFqaldxTGRHV05tRHhKeERFNWM4TGFKVGh2Z0dIdDdTQ3JiT1BySm5YblBSb00xd2pmR0l0cmw4YVBsSXJYLVN1cjNBZ2E1NlFfeGFKeTJhNUNiV0ZaNk5scW15SWRicXFEMEpjTm5oV2FrOV9raGpGLVphWFlKeHRfd1RHQjF6ZUhHcWdCYjhidXl0ekM1OHZCYUZucTdBR0lWWTR6NWMyVGg2ek1UZmk3cVhyYk1XWkstOTdfUkcybw==","email":"infra@growin.co.kr"},"bastion.mj.growin.co.kr:5000":{"auth":"YWRtaW46YWRtaW4=","email":"mj@growin.co.kr"}}}'
sshKey: '$(cat /root/.ssh/id_rsa.pub)'
additionalTrustBundle: |
$(cat ${CRT} | sed 's/^/  /g')
imageContentSources:
- mirrors:
  - ${BASTION_HOSTNAME}.${ClusterName}.${DomainName}:5000/okd4/openshift
  source: quay.io/openshift/okd
- mirrors:
  - ${BASTION_HOSTNAME}.${ClusterName}.${DomainName}:5000/okd4/openshift
  source: quay.io/openshift/okd-content
#---
#apiVersion: operator.openshift.io/v1alpha1
#kind: ImageContentSourcePolicy
#metadata:
#  name: example
#spec:
#  repositoryDigestMirrors:
#  - mirrors:
#    - bastion.mj.growin.co.kr:5000/okd4/openshift
#    source: quay.io/openshift/okd
#  - mirrors:
#    - bastion.mj.growin.co.kr:5000/okd4/openshift
#    source: quay.io/openshift/okd-content

EOF
if [ -d ${OKD_HOME} ];then
rm -rf ${OKD_HOME}
fi
mkdir ${OKD_HOME}/
cp ${HTTP_HOME}/install-config.yaml ${OKD_HOME}/
chown apache. -R ${HTTP_HOME}/
