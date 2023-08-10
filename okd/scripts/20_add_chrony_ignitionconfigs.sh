#!/bin/bash
source src/env

# Set Timezone : Asia/Seoul
SetTimeZone="Asia/Seoul"

BOOTSTRAP_JQ="${OKD_HOME}/jq_bootstrap.ign"
WORKER_JQ="${OKD_HOME}/jq_worker.ign"
MASTER_JQ="${OKD_HOME}/jq_master.ign"

cp -a ${OKD_HOME}/bootstrap.ign ${OKD_HOME}/bootstrap.ign_backup
cp -a ${OKD_HOME}/worker.ign ${OKD_HOME}/worker.ign_backup
cp -a ${OKD_HOME}/master.ign ${OKD_HOME}/master.ign_backup

cat ${OKD_HOME}/bootstrap.ign | jq '.' > ${BOOTSTRAP_JQ}
cat ${OKD_HOME}/worker.ign | jq '.' > ${MASTER_JQ}
cat ${OKD_HOME}/master.ign | jq '.' > ${WORKER_JQ}


#sed -i "/\"files\":/a\{\"overwrite\":true,\"path\":\"\/etc\/chrony.conf\",\"user\":{\"name\":\"root\"},\"contents\":{\"source\":\"data:text/plain;charset=utf-8;base64,$(echo "$(cat ${HTTP_HOME}/chrony.conf)" | base64 -w0)\"},\"mode\":420},{\"overwrite\":true,\"path\":\"\/etc\/containers\/registries.conf\",\"user\":{\"name\":\"root\"},\"contents\":{\"source\":\"data:text/plain;charset=utf-8;base64,$(echo "$(cat ${HTTP_HOME}/registries.conf)" | base64 -w0)\"},\"mode\":384}," ${BOOTSTRAP_JQ}
#sed -i "$(expr $(cat -n ${BOOTSTRAP_JQ} | grep \"mode\" | tail -n1 | awk '{print $1}') \+ 2)a\,\"links\":[{\"overwrite\":true,\"path\":\"\/etc\/localtime\",\"user\":{\"name\":\"root\"},\"group\":{\"name\":\"root\"},\"target\":\"..\/usr\/share\/zoneinfo\/$(echo ${SetTimeZone} | sed 's/\//\\\//g')\",\"hard\":false}]" ${BOOTSTRAP_JQ}

#sed -i "/^}/i\,\"storage\":{\"files\":[{\"overwrite\":true,\"path\":\"\/etc\/chrony.conf\",\"user\":{\"name\":\"root\"},\"contents\":{\"source\":\"data:text/plain;charset=utf-8;base64,$(echo "$(cat ${HTTP_HOME}/chrony.conf)" | base64 -w0)\"},\"mode\":420},{\"overwrite\":true,\"path\":\"\/etc\/containers\/registries.conf\",\"user\":{\"name\":\"root\"},\"contents\":{\"source\":\"data:text/plain;charset=utf-8;base64,$(echo "$(cat ${HTTP_HOME}/registries.conf)" | base64 -w0)\"},\"mode\":384}],\"links\": [{\"overwrite\":true,\"path\":\"/etc/localtime\",\"user\":{\"name\":\"root\"},\"group\":{\"name\":\"root\"},\"target\":\"../usr/share/zoneinfo/Asia/Seoul\",\"hard\":false}]}" ${WORKER_JQ}
#sed -i "/^}/i\,\"storage\":{\"files\":[{\"overwrite\":true,\"path\":\"\/etc\/chrony.conf\",\"user\":{\"name\":\"root\"},\"contents\":{\"source\":\"data:text/plain;charset=utf-8;base64,$(echo "$(cat ${HTTP_HOME}/chrony.conf)" | base64 -w0)\"},\"mode\":420},{\"overwrite\":true,\"path\":\"\/etc\/containers\/registries.conf\",\"user\":{\"name\":\"root\"},\"contents\":{\"source\":\"data:text/plain;charset=utf-8;base64,$(echo "$(cat ${HTTP_HOME}/registries.conf)" | base64 -w0)\"},\"mode\":384}],\"links\": [{\"overwrite\":true,\"path\":\"/etc/localtime\",\"user\":{\"name\":\"root\"},\"group\":{\"name\":\"root\"},\"target\":\"../usr/share/zoneinfo/Asia/Seoul\",\"hard\":false}]}" ${MASTER_JQ}

sed -i "/\"files\":/a\{\"overwrite\":true,\"path\":\"\/etc\/chrony.conf\",\"user\":{\"name\":\"root\"},\"contents\":{\"source\":\"data:text/plain;charset=utf-8;base64,$(echo "$(cat ${HTTP_HOME}/chrony.conf)" | base64 -w0)\"},\"mode\":420}," ${BOOTSTRAP_JQ}
sed -i "$(expr $(cat -n ${BOOTSTRAP_JQ} | grep \"mode\" | tail -n1 | awk '{print $1}') \+ 2)a\,\"links\":[{\"overwrite\":true,\"path\":\"\/etc\/localtime\",\"user\":{\"name\":\"root\"},\"group\":{\"name\":\"root\"},\"target\":\"..\/usr\/share\/zoneinfo\/$(echo ${SetTimeZone} | sed 's/\//\\\//g')\",\"hard\":false}]" ${BOOTSTRAP_JQ}

sed -i "/^}/i\,\"storage\":{\"files\":[{\"overwrite\":true,\"path\":\"\/etc\/chrony.conf\",\"user\":{\"name\":\"root\"},\"contents\":{\"source\":\"data:text/plain;charset=utf-8;base64,$(echo "$(cat ${HTTP_HOME}/chrony.conf)" | base64 -w0)\"},\"mode\":420}],\"links\": [{\"overwrite\":true,\"path\":\"/etc/localtime\",\"user\":{\"name\":\"root\"},\"group\":{\"name\":\"root\"},\"target\":\"../usr/share/zoneinfo/Asia/Seoul\",\"hard\":false}]}" ${WORKER_JQ}
sed -i "/^}/i\,\"storage\":{\"files\":[{\"overwrite\":true,\"path\":\"\/etc\/chrony.conf\",\"user\":{\"name\":\"root\"},\"contents\":{\"source\":\"data:text/plain;charset=utf-8;base64,$(echo "$(cat ${HTTP_HOME}/chrony.conf)" | base64 -w0)\"},\"mode\":420}],\"links\": [{\"overwrite\":true,\"path\":\"/etc/localtime\",\"user\":{\"name\":\"root\"},\"group\":{\"name\":\"root\"},\"target\":\"../usr/share/zoneinfo/Asia/Seoul\",\"hard\":false}]}" ${MASTER_JQ}

cat ${BOOTSTRAP_JQ} | jq -c '.' > ${OKD_HOME}/bootstrap.ign
cat ${WORKER_JQ} | jq -c '.' > ${OKD_HOME}/worker.ign
cat ${MASTER_JQ} | jq -c '.' > ${OKD_HOME}/master.ign

rm -f ${BOOTSTRAP_JQ}
rm -f ${WORKER_JQ}
rm -f ${MASTER_JQ}


chown apache. -R ${HTTP_HOME}
echo 'Please distrubete bootstrap, master'
