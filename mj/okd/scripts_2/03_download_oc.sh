#!/bin/bash
source src/env
######################################
# Ver="4.12.0-0.okd-2023-04-16-041331"
# Ver="4.7.0-0.okd-2021-03-21-094146"
# Ver="4.7.0-0.okd-2021-03-07-090821"
# Ver="4.7.0-0.okd-2021-03-06-124908"
# Ver="4.7.0-0.okd-2021-02-25-144700"
## Ver="4.6.0-0.okd-2021-02-14-205305"
# Ver="4.6.0-0.okd-2021-01-23-132511"
# Ver="4.6.0-0.okd-2021-01-17-185703"
# Ver="4.6.0-0.okd-2020-12-12-135354"
# Ver="4.6.0-0.okd-2020-11-27-200126"
# Ver="4.5.0-0.okd-2020-10-15-235428"
# Ver="4.5.0-0.okd-2020-10-03-012432"
######################################

function EXEC(){
CMD="${1}"
expect -c "
set timeout 5
spawn ${CMD}
expect 'password:'
	send \"growin\"
expect eof
"
}

#Ver="4.6.0-0.okd-2021-02-14-205305"
Ver="4.12.0-0.okd-2023-04-16-041331"
if [ "$(echo ${ONPREMIS} | tr [:upper:] [:lower:])" == "true" ];then
  echo "[ ONPREMIS=\"true\" ] Can not down load openshift-client, openshift-install programs."
  REMOTEUSER="root"
  REMOTEADDR="2.5.10.1"
  REMOTEPATH="/data/mj_tmp/oc"
  ClientFileName="openshift-client-linux-${Ver}.tar.gz"
  InstallFileName="openshift-install-linux-${Ver}.tar.gz"
  rsync -avrP ${REMOTEUSER}@${REMOTEADDR}:${REMOTEPATH}/${Ver}/{${ClientFileName},${InstallFileName}} ./
 
  #EXEC "ssh -l ${REMOTEUSER} ${REMOTEADDR} cat ${REMOTEPATH}/${Ver}/${ClientFileName} | tar -C /usr/local/bin/ -xfz -"
  #EXEC "ssh -l ${REMOTEUSER} ${REMOTEADDR} cat ${REMOTEPATH}/${Ver}/${InstallFileName} | tar -C /usr/local/bin/ -xfz -"
else
  # openshift-client
  wget https://github.com/openshift/okd/releases/download/${Ver}/openshift-client-linux-${Ver}.tar.gz
  tar xf openshift-client-linux-${Ver}.tar.gz -C /usr/local/bin/
  # openshift-install
  wget https://github.com/openshift/okd/releases/download/${Ver}/openshift-install-linux-${Ver}.tar.gz
  tar xf openshift-install-linux-${Ver}.tar.gz -C /usr/local/bin/
fi
exit 0
