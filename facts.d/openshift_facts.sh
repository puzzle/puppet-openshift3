#!/bin/sh

if which oc; then
cat <<EOF
openshift_registry_ip=`oc get svc docker-registry -n default -o json 2>/dev/null | jq -r .spec.clusterIP 2>/dev/null`
openshift_registry_version=`oc get dc/docker-registry -n default -o json 2>/dev/null |sed -ne 's/.*"image": *"[^:]\+:v\?\([0-9.]\+\).*/\1/p'`
openshift_router_version=`oc get dc/router -n default -o json 2>/dev/null |sed -ne 's/.*"image": *"[^:]\+:v\?\([0-9.]\+\).*/\1/p'`
EOF
else
cat <<EOF
openshift_registry_ip=0
openshift_registry_version=0
openshift_router_version=0
EOF
fi

if which openshift; then
cat <<EOF
openshift_version=`openshift version 2>/dev/null | sed -ne 's/openshift \+v\?\([0-9.]\+\).*/\1/p'`
EOF
else
cat <<EOF
openshift_version=0
EOF
fi
