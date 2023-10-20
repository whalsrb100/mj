#!/bin/bash

source src/env
#####################################
#              *  env *
# ClusterName=growin
# DomainName=mj.co.kr
# InverseNetwork='150.168.192'
# BOOTSTRAP_IP=192.168.150.200
# BASTION_IP=192.168.150.210
# MASTER1_IP=192.168.150.201
# MASTER2_IP=192.168.150.202
# MASTER3_IP=192.168.150.203
# WORKER1_IP=192.168.150.204
# WORKER2_IP=192.168.150.205
# WORKER3_IP=192.168.150.206
# WORKER4_IP=192.168.150.207
# BOOTSTRAP_HOSTNAME='bootstrap'
# BASTION_HOSTNAME='bastion'
# MASTER1_HOSTNAME='master1'
# MASTER2_HOSTNAME='master2'
# MASTER3_HOSTNAME='master3'
# WORKER1_HOSTNAME='worker1'
# WORKER2_HOSTNAME='worker2'
# WORKER3_HOSTNAME='worker3'
# WORKER4_HOSTNAME='worker4'
#####################################


cat << EOF > /etc/named.conf
//
// named.conf
//
// Provided by Red Hat bind package to configure the ISC BIND named(8) DNS
// server as a caching only nameserver (as a localhost DNS resolver only).
//
// See /usr/share/doc/bind*/sample/ for example named configuration files.
//

options {
	listen-on port 53 { any; };
	listen-on-v6 port 53 { any; };
	directory 	"/var/named";
	dump-file 	"/var/named/data/cache_dump.db";
	statistics-file "/var/named/data/named_stats.txt";
	memstatistics-file "/var/named/data/named_mem_stats.txt";
	secroots-file	"/var/named/data/named.secroots";
	recursing-file	"/var/named/data/named.recursing";
	allow-query     { any; };

	/*
	 - If you are building an AUTHORITATIVE DNS server, do NOT enable recursion.
	 - If you are building a RECURSIVE (caching) DNS server, you need to enable
	   recursion.
	 - If your recursive DNS server has a public IP address, you MUST enable access
	   control to limit queries to your legitimate users. Failing to do so will
	   cause your server to become part of large scale DNS amplification
	   attacks. Implementing BCP38 within your network would greatly
	   reduce such attack surface
	*/
	recursion yes;

	dnssec-enable yes;
	dnssec-validation yes;

	managed-keys-directory "/var/named/dynamic";

	pid-file "/run/named/named.pid";
	session-keyfile "/run/named/session.key";

	/* https://fedoraproject.org/wiki/Changes/CryptoPolicy */
	include "/etc/crypto-policies/back-ends/bind.config";
};

logging {
        channel default_debug {
                file "data/named.run";
                severity dynamic;
        };
};

zone "." IN {
	type hint;
	file "named.ca";
};

include "/etc/named.rfc1912.zones";
include "/etc/named.root.key";
include "/etc/named/growin.zones";
EOF
cat << EOF > /etc/named/growin.zones
zone "${ClusterName}.${DomainName}" IN {
	type master;
	file "${ClusterName}.${DomainName}.zone";
	allow-update { none; };
};
zone "${InverseNetwork}.in-addr.arpa" IN {
	type master;
	file "${ClusterName}.${DomainName}.rev";
	allow-update { none; };
};
EOF
chmod 640 /etc/named/growin.zones
chown root.named /etc/named/growin.zones
cat << EOF > /var/named/${ClusterName}.${DomainName}.rev
\$TTL 3600
@	IN SOA	@ ns3.${ClusterName}.${DomainName}. (
					1       ; serial
					900	; refresh
					600	; retry
					1D	; expire
					1H )	; minimum
	IN NS		ns.${ClusterName}.${DomainName}.
        IN A            ${BASTION_IP}
$(echo ${BOOTSTRAP_IP} | cut -d '.' -f4)     IN PTR          ${BOOTSTRAP_HOSTNAME}.${ClusterName}.${DomainName}.
$(echo ${MASTER1_IP} | cut -d '.' -f4)     IN PTR          ${MASTER1_HOSTNAME}.${ClusterName}.${DomainName}.
$(echo ${MASTER2_IP} | cut -d '.' -f4)     IN PTR          ${MASTER2_HOSTNAME}.${ClusterName}.${DomainName}.
$(echo ${MASTER3_IP} | cut -d '.' -f4)     IN PTR          ${MASTER3_HOSTNAME}.${ClusterName}.${DomainName}.
EOF
for i in $(seq 1 ${WORKER_NUM});do
  WORKER_HOSTNAME=$(eval echo \$WORKER${i}_HOSTNAME)
  WORKER_IP=$(eval echo \$WORKER${i}_IP)
  if [ ${WORKER_HOSTNAME} ];then
    if [ ${WORKER_IP} ];then
      echo "$(echo ${WORKER_IP} | cut -d '.' -f4)     IN PTR          ${WORKER_HOSTNAME}.${ClusterName}.${DomainName}." >> /var/named/${ClusterName}.${DomainName}.rev
    fi
  fi
done

cat << EOF >> /var/named/${ClusterName}.${DomainName}.rev
$(echo ${BASTION_IP} | cut -d '.' -f4)     IN PTR          api.${ClusterName}.${DomainName}.
$(echo ${BASTION_IP} | cut -d '.' -f4)     IN PTR          api-int.${ClusterName}.${DomainName}.
EOF
chmod 640 /var/named/${ClusterName}.${DomainName}.rev
chown root.named /var/named/${ClusterName}.${DomainName}.rev
cat << EOF > /var/named/${ClusterName}.${DomainName}.zone
\$TTL 3600
@ IN SOA @ ns.${ClusterName}.${DomainName}. (
                                1         ; serial
                                900       ; refresh
                                600       ; retry
                                10        ; expire
                                1H )      ; minimum
@             IN NS ns.${ClusterName}.${DomainName}.
@             IN A ${BASTION_IP}
ns            IN A ${BASTION_IP}
lb            IN A ${BASTION_IP}

${BASTION_HOSTNAME}       IN A ${BASTION_IP}
${BOOTSTRAP_HOSTNAME}     IN A ${BOOTSTRAP_IP}
${MASTER1_HOSTNAME}       IN A ${MASTER1_IP}
${MASTER2_HOSTNAME}       IN A ${MASTER2_IP}
${MASTER3_HOSTNAME}       IN A ${MASTER3_IP}
EOF

for i in $(seq 1 ${WORKER_NUM});do
  WORKER_HOSTNAME=$(eval echo \$WORKER${i}_HOSTNAME)
  WORKER_IP=$(eval echo \$WORKER${i}_IP)
  if [ ${WORKER_HOSTNAME} ];then
    if [ ${WORKER_IP} ];then
      echo "${WORKER_HOSTNAME}       IN A ${WORKER_IP}" >> /var/named/${ClusterName}.${DomainName}.zone
    fi
  fi
done

cat << EOF >> /var/named/${ClusterName}.${DomainName}.zone
etcd-0-okd    IN A ${MASTER1_IP}
etcd-1-okd    IN A ${MASTER2_IP}
etcd-2-okd    IN A ${MASTER3_IP}
__etcd-server-ssl.__tcp.${ClusterName}.${DomainName}. IN SRV 0 10 2380 etcd-0-okd.${ClusterName}.${DomainName}
__etcd-server-ssl.__tcp.${ClusterName}.${DomainName}. IN SRV 0 10 2380 etcd-1-okd.${ClusterName}.${DomainName}
__etcd-server-ssl.__tcp.${ClusterName}.${DomainName}. IN SRV 0 10 2380 etcd-2-okd.${ClusterName}.${DomainName}
api           IN A ${BASTION_IP}
api           IN A ${BASTION_IP}
api-int       IN A ${BASTION_IP}
*.apps        IN A ${BASTION_IP}
EOF
chmod 640 /var/named/${ClusterName}.${DomainName}.zone
chown root.named /var/named/${ClusterName}.${DomainName}.zone
systemctl enable --now named
