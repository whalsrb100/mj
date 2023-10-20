#!/bin/bash
source src/env
mkdir -p /opt/registry/{auth,data,certs}
rm -f /etc/pki/ca-trust/source/anchors/{$(basename ${KEY}),$(basename ${CRT})} ${CRT} ${KEY}

/usr/bin/openssl req -newkey rsa:4096 -nodes -sha256 \
-x509 -days 3650 \
-keyout ${KEY} \
-out ${CRT} \
-subj "/C=KR/ST=Seoul/L=City/O=SelfSign/OU=Cloud/CN=${BASTION_HOSTNAME}.${ClusterName}.${DomainName}/emailAddress=${E_MAIL}" \
-addext "subjectAltName = DNS:bastion.mj.growin.co.kr"
ls -l $CRT $KEY

/usr/bin/cp -a ${KEY} ${CRT} /etc/pki/ca-trust/source/anchors/
/usr/bin/update-ca-trust
