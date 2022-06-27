#!/bin/bash
set -e
JDK11_BUILDER_IMAGE=jboss-eap-8-tech-preview/custom-eap8-openjdk11-builder
JDK17_BUILDER_IMAGE=jboss-eap-8-tech-preview/custom-eap8-openjdk17-builder
JDK11_RUNTIME_IMAGE=jboss-eap-8-tech-preview/eap8-openjdk11-runtime-openshift-rhel8
JDK17_RUNTIME_IMAGE=jboss-eap-8-tech-preview/eap8-openjdk17-runtime-openshift-rhel8

export IMAGE_VERSION=latest

pushd "../test" > /dev/null  
  echo "Running JDK11 extra tests"
  export IMAGE_NAME=$JDK11_BUILDER_IMAGE
  export RUNTIME_IMAGE_NAME=$JDK11_RUNTIME_IMAGE
  sh ./run

  echo "Running JDK17 extra tests"
  export IMAGE_NAME=$JDK17_BUILDER_IMAGE
  export RUNTIME_IMAGE_NAME=$JDK17_RUNTIME_IMAGE
  sh ./run
popd > /dev/null
docker system prune -f