#!/bin/bash
source src/env

sed -i "s/^#allow 192.168.0.0\/16/allow $(echo ${LOCAL_NTP_NETWORK} | sed 's/\//\\\//')/" /etc/chrony.conf
sed -i "s/^#local stratum 10/local stratum 10/" /etc/chrony.conf
sed -i "s/^pool/#pool/g" /etc/chrony.conf
sed -i "s/^server/#server/g" /etc/chrony.conf
systemctl enable --now chronyd

cat << EOF > ${HTTP_HOME}/chrony.conf
# Use public servers from the pool.ntp.org project.
# Please consider joining the pool (https://www.pool.ntp.org/join.html).
#pool 2.fedora.pool.ntp.org iburst

# Use NTP servers from DHCP.
sourcedir /run/chrony-dhcp

# Record the rate at which the system clock gains/losses time.
driftfile /var/lib/chrony/drift

# Allow the system clock to be stepped in the first three updates
# if its offset is larger than 1 second.
makestep 1.0 3

# Enable kernel synchronization of the real-time clock (RTC).
rtcsync

# Enable hardware timestamping on all interfaces that support it.
#hwtimestamp *

# Increase the minimum number of selectable sources required to adjust
# the system clock.
#minsources 2

# Allow NTP client access from local network.
#allow ${LOCAL_NTP_NETWORK}

# Serve time even if not synchronized to a time source.
#local stratum 10

# Require authentication (nts or key option) for all NTP sources.
#authselectmode require

# Specify file containing keys for NTP authentication.
keyfile /etc/chrony.keys

# Save NTS keys and cookies.
ntsdumpdir /var/lib/chrony

# Insert/delete leap seconds by slewing instead of stepping.
#leapsecmode slew

# Get TAI-UTC offset and leap seconds from the system tz database.
leapsectz right/UTC

# Specify directory for log files.
logdir /var/log/chrony

# Select which information is logged.
#log measurements statistics tracking
#
server ${BASTION_IP}
EOF

cat << EOF > ${HTTP_HOME}/registries.conf
[[registry]]
location = "quay.io/openshift/okd"
insecure = false
mirror-by-digest-only = true

[[registry.mirror]]
location = "${BASTION_HOSTNAME}.${ClusterName}.${DomainName}:5000/openshift/okd"
insecure = true


[[registry]]
location = "quay.io/openshift/okd-content"
insecure = false
mirror-by-digest-only = true

[[registry.mirror]]
location = "${BASTION_HOSTNAME}.${ClusterName}.${DomainName}:5000/openshift/okd"
insecure = true
EOF


