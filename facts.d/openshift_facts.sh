#!/bin/sh 

cat <<EOF
openshift_registry_ip=`oc get svc docker-registry -n default -o json | jq -r .spec.clusterIP`
#openshift_version=`openshift version 2>/dev/null | sed -ne 's/openshift \+v\?\([0-9.]\+\).*/\1/p'`
#openshift_registry_version=`oc get dc/docker-registry -n default -o json 2>/dev/null |sed -ne 's/.*"image": *"[^:]\+:v\?\([0-9.]\+\).*/\1/p'`
#openshift_router_version=`oc get dc/router -n default -o json 2>/dev/null |sed -ne 's/.*"image": *"[^:]\+:v\?\([0-9.]\+\).*/\1/p'`
EOF
