#!/bin/bash

source src/env
mode=0
podman rm -f mirror-registry
if [ ${mode} -eq 0 ];then
podman run --name mirror-registry -p 5000:5000 \
-v /opt/registry/data:/var/lib/registry \
-v /opt/registry/auth:/auth \
-v /opt/registry/certs:/certs \
-e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \
-e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
-d docker.io/library/registry:2.6

elif [ ${mode} -eq 1 ];then
# No Authenticate
podman run --name mirror-registry -p 5000:5000 \
-v /opt/registry/data:/var/lib/registry:z \
-v /opt/registry/auth:/auth:z \
-v /opt/registry/certs:/certs:z \
-e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \
-e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
-d docker.io/library/registry:latest
#-d docker.io/library/registry:2

elif [ ${mode} -eq 2 ];then
# <SELINUX Enforcing or PERMISSIVE>
podman run --name mirror-registry -p 5000:5000 \
-v /opt/registry/data:/var/lib/registry:z \
-v /opt/registry/auth:/auth:z \
-e "REGISTRY_AUTH=htpasswd" \
-e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
-e "REGISTRY_HTTP_SECRET=ALongRandomSecretForRegistry" \
-e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
-v /opt/registry/certs:/certs:z \
-e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \
-e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
-d docker.io/library/registry:latest
#-d docker.io/library/registry:2

elif [ ${mode} -eq 3 ];then
# <SELINUX DISABLE>
podman run --name mirror-registry -p 5000:5000 \
-v /opt/registry/data:/var/lib/registry \
-v /opt/registry/auth:/auth \
-e "REGISTRY_AUTH=htpasswd" \
-e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
-e "REGISTRY_HTTP_SECRET=ALongRandomSecretForRegistry" \
-e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
-v /opt/registry/certs:/certs \
-e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \
-e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
-d docker.io/library/registry:latest
#-d docker.io/library/registry:2
fi
