#!/bin/bash
set -e

echo "Building runtime and builder images"

pushd "../builder-image" > /dev/null
  echo "Building JDK11 builder image"
  cekit --redhat build docker 
  echo "Building JDK17 builder image"
  cekit --redhat build --overrides image-jdk17-overrides.yaml docker 
popd > /dev/null

pushd "../runtime-image" > /dev/null
  echo "Building JDK11 runtime image"
  cekit --redhat build docker 
  echo "Building JDK17 runtime image"
  cekit --redhat build --overrides image-jdk17-overrides.yaml docker 
popd > /dev/null

docker system prune -f
