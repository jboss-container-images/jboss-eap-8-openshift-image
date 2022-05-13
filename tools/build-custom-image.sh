#!/bin/bash
# Script to build the JDK11 and JDK17 S2I builder images containing the built cloud FP, EAP maven plugin and EAP 8 in a local maven repository
# 1) Build the cloud FPs
# 2) Build the EAP Maven plugin
# 2) Call this script
# 3) the image jboss-eap-8-tech-preview/custom-eap8-openjdk11-builder:dev will be built.

function usage() {
echo " "
echo "Usage:"
echo "  * First Build EAP S2I builder docker images, EAP cloud feature-pack and EAP maven plugin, download an EAP 8 builder maven repo (eg: jboss-eap-8.0.0.Beta-redhat-20220408-image-builder-maven-repository.zip)."
echo "  * Then call: sh ./build-custom-image.sh <path to built cloud FP repo> <path to built EAP maven plugin repo> <path to image builder maven repo zip>"
echo " "
exit 1
}
if [ ! -d "$1" ]; then
  echo "ERROR: EAP cloud FP src repo is missing or doesn't exist"
  usage
fi

if [ ! -d "$2" ]; then
  echo "ERROR: EAP Maven plugin src repo is missing or doesn't exist"
  usage
fi

if [ ! -f "$3" ]; then
  echo "ERROR: Zipped builder maven repository is missing or doesn't exist"
  usage 
fi

SCRIPT_DIR=$(dirname $0)
tmpPath=/tmp/custom-cloud-image
rm -rf $tmpPath
mkdir -p $tmpPath
mkdir -p $tmpPath/docker/

echo "Unzip the maven repo to the docker build context..."
unzip "${3}" -d $tmpPath > /dev/null
repoDir=$(find $tmpPath -type d -iname "*-image-builder-maven-repository")
mv $repoDir/maven-repository $tmpPath/docker/

echo "Install the cloud FP into the maven repo"
pushd "${1}" > /dev/null
cloudVersion=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout)
mkdir -p $tmpPath/docker/maven-repository/org/jboss/eap/cloud/eap-cloud-galleon-pack/$cloudVersion
cp eap-cloud-galleon-pack/target/eap-cloud-galleon-pack-$cloudVersion.zip $tmpPath/docker/maven-repository/org/jboss/eap/cloud/eap-cloud-galleon-pack/$cloudVersion
popd > /dev/null

echo "Install the maven plugin and its parent into the maven repo"
pushd "${2}" > /dev/null
pluginVersion=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout)
mkdir -p $tmpPath/docker/maven-repository/org/jboss/eap/plugins/eap-maven-plugin/$pluginVersion
cp plugin/target/eap-maven-plugin-$pluginVersion.jar $tmpPath/docker/maven-repository/org/jboss/eap/plugins/eap-maven-plugin/$pluginVersion
cp plugin/pom.xml $tmpPath/docker/maven-repository/org/jboss/eap/plugins/eap-maven-plugin/$pluginVersion/eap-maven-plugin-$pluginVersion.pom

mkdir -p $tmpPath/docker/maven-repository/org/jboss/eap/plugins/eap-maven-plugin-parent/$pluginVersion
cp pom.xml $tmpPath/docker/maven-repository/org/jboss/eap/plugins/eap-maven-plugin-parent/$pluginVersion/eap-maven-plugin-parent-$pluginVersion.pom

popd > /dev/null

echo "Build JDK11 builder docker image"
docker_file=$tmpPath/docker/Dockerfile
cat <<EOF > $docker_file
  FROM jboss-eap-8-tech-preview/eap8-openjdk11-builder-openshift-rhel8:latest
  ENV PROVISIONING_MAVEN_PLUGIN_VERSION=1.0.0.Beta-redhat-SNAPSHOT
  RUN mkdir -p /tmp/artifacts/m2
  COPY --chown=jboss:root maven-repository /tmp/artifacts/m2
EOF
docker build -t jboss-eap-8-tech-preview/custom-eap8-openjdk11-builder:dev $tmpPath/docker

echo "Build JDK17 builder docker image"
cat <<EOF > $docker_file
  FROM jboss-eap-8-tech-preview/eap8-openjdk17-builder-openshift-rhel8:latest
  ENV PROVISIONING_MAVEN_PLUGIN_VERSION=1.0.0.Beta-redhat-SNAPSHOT
  RUN mkdir -p /tmp/artifacts/m2
  COPY --chown=jboss:root maven-repository /tmp/artifacts/m2
EOF
docker build -t jboss-eap-8-tech-preview/custom-eap8-openjdk17-builder:dev $tmpPath/docker

rm -rf $tmpPath

echo "Images   jboss-eap-8-tech-preview/custom-eap8-openjdk11-builder:dev and jboss-eap-8-tech-preview/custom-eap8-openjdk17-builder:dev have been created"