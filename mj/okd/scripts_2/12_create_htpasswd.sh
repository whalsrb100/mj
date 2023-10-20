#!/bin/bash
source src/env
/usr/bin/htpasswd -bBc /opt/registry/auth/htpasswd ${HTPASS_USER} ${HTPASS_PW}
