#!/bin/bash

OPENSHIFT_VERSION=`rpm -q --queryformat '%{version}' openshift`
OPENSHIFT_VENDOR=`rpm -q --queryformat '%{vendor}' openshift`

if [[ "$OPENSHIFT_VENDOR" == "Red Hat"* ]]; then
  OPENSHIFT_PRODUCT="ose"
else
  OPENSHIFT_PRODUCT="origin"
fi

docker save -o ${OPENSHIFT_PRODUCT}-${OPENSHIFT_VERSION}-docker-images.tar \
openshift/${OPENSHIFT_PRODUCT}-haproxy-router:v${OPENSHIFT_VERSION} \
openshift/${OPENSHIFT_PRODUCT}-deployer:v${OPENSHIFT_VERSION} \
openshift/${OPENSHIFT_PRODUCT}-sti-builder:v${OPENSHIFT_VERSION} \
openshift/${OPENSHIFT_PRODUCT}-docker-builder:v${OPENSHIFT_VERSION} \
openshift/${OPENSHIFT_PRODUCT}-pod:v${OPENSHIFT_VERSION} \
openshift/${OPENSHIFT_PRODUCT}-docker-registry:v${OPENSHIFT_VERSION}
