#!/bin/bash
set -e
JDK17_BUILDER_IMAGE=jboss-eap-8/custom-eap8-openjdk17-builder
JDK17_RUNTIME_IMAGE=jboss-eap-8/eap8-openjdk17-runtime-openshift-rhel8

export IMAGE_VERSION=latest

pushd "../test" > /dev/null  

  echo "Running JDK17 extra tests"
  export IMAGE_NAME=$JDK17_BUILDER_IMAGE
  export RUNTIME_IMAGE_NAME=$JDK17_RUNTIME_IMAGE
  sh ./run
popd > /dev/null
docker system prune -f