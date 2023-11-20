#!/bin/bash
#Custom image with custom cloud-fp
# Script to build the JDK17 S2I builder images containing the built cloud FP and EAP 8 in a local maven repository
# 1) Build the cloud FPs
# 2) Call this script
# 3) The JDK17 image is built.

function usage() {
echo " "
echo "Usage:"
echo "  * First Build EAP S2I builder docker images, EAP cloud feature-pack and EAP maven plugin, download an EAP 8 builder maven repo (eg: jboss-eap-8.0.0.GA-redhat-99999-maven-repository.zip)."
echo "  * Then call: sh ./build-custom-image.sh <path to built cloud FP repo> <path to maven repo zip>"
echo " "
exit 1
}
if [ ! -d "$1" ]; then
  echo "ERROR: EAP cloud FP src repo is missing or doesn't exist"
  usage
fi

if [ ! -f "$2" ]; then
  echo "ERROR: Zipped builder maven repository is missing or doesn't exist"
  usage 
fi

SCRIPT_DIR=$(dirname $0)
tmpPath=/tmp/custom-cloud-image
rm -rf $tmpPath
mkdir -p $tmpPath
mkdir -p $tmpPath/docker/

echo "Unzip the maven repo to the docker build context..."
unzip "${2}" -d $tmpPath > /dev/null
repoDir=$(find $tmpPath -type d -iname "*-maven-repository")
mv $repoDir/maven-repository $tmpPath/docker/

cp ocp-settings.xml $tmpPath/docker/ocp-settings.xml
eapVersion=$(echo $tmpPath/docker/maven-repository/org/jboss/eap/wildfly-ee-galleon-pack/*/)
eapVersion=${eapVersion::-1}
eapVersion=$(basename ${eapVersion})
echo "EAP8 version is $eapVersion"

origCloudVersion=$(echo $tmpPath/docker/maven-repository/org/jboss/eap/cloud/eap-cloud-galleon-pack/*/)
origCloudVersion=${origCloudVersion::-1}
origCloudVersion=$(basename ${origCloudVersion})
echo "Original Cloud version is $origCloudVersion"

echo "Install the cloud FP into the maven repo"
pushd "${1}" > /dev/null
cloudVersion=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout)
mkdir -p $tmpPath/docker/maven-repository/org/jboss/eap/cloud/eap-cloud-galleon-pack/$cloudVersion
cp eap-cloud-galleon-pack/target/eap-cloud-galleon-pack-$cloudVersion.zip $tmpPath/docker/maven-repository/org/jboss/eap/cloud/eap-cloud-galleon-pack/$cloudVersion
popd > /dev/null

echo "Install the maven plugin and its parent into the maven repo"
pushd "${3}" > /dev/null
pluginVersion=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout)
mkdir -p $tmpPath/docker/maven-repository/org/jboss/eap/plugins/eap-maven-plugin/$pluginVersion
cp plugin/target/eap-maven-plugin-$pluginVersion.jar $tmpPath/docker/maven-repository/org/jboss/eap/plugins/eap-maven-plugin/$pluginVersion
cp plugin/pom.xml $tmpPath/docker/maven-repository/org/jboss/eap/plugins/eap-maven-plugin/$pluginVersion/eap-maven-plugin-$pluginVersion.pom

mkdir -p $tmpPath/docker/maven-repository/org/jboss/eap/plugins/eap-maven-plugin-parent/$pluginVersion
cp pom.xml $tmpPath/docker/maven-repository/org/jboss/eap/plugins/eap-maven-plugin-parent/$pluginVersion/eap-maven-plugin-parent-$pluginVersion.pom

popd > /dev/null

channelPath=$(echo $tmpPath/docker/maven-repository/org/jboss/eap/channels/eap-8.0/*/)
channelVersion=${channelPath::-1}
channelVersion=$(basename ${channelVersion})
echo "Channel version is $channelVersion"
sed -i "s|${origCloudVersion}|${cloudVersion}|" "${channelPath}/eap-8.0-${channelVersion}-manifest.yaml"


docker_file=$tmpPath/docker/Dockerfile
echo "Build JDK17 builder docker image"
cat <<EOF > $docker_file
  FROM jboss-eap-8/eap8-openjdk17-builder-openshift-rhel8:latest
  ENV PROVISIONING_MAVEN_PLUGIN_VERSION=$pluginVersion
  RUN mkdir -p /tmp/artifacts/m2
  COPY --chown=jboss:root ocp-settings.xml /home/jboss/.m2/settings.xml
  COPY --chown=jboss:root maven-repository /maven-repository
EOF
docker build -t jboss-eap-8/custom-cloud-fp-eap8-openjdk17-builder:latest $tmpPath/docker
docker system prune -f

rm -rf $tmpPath

echo "Image jboss-eap-8/custom-cloud-fp-eap8-openjdk17-builder:latest has been created"