#!/bin/bash
#Ultra custom image with custom cloud-fp, custom eap maven-plugin, custom wildfly maven plugin.
# Script to build the JDK17 S2I builder image containing the built cloud FP, EAP maven plugin and EAP 8 in a local maven repository
# 1) Build the cloud FPs
# 2) Build the EAP Maven plugin
# 2) Call this script
# 3) the image jboss-eap-8/custom-eap8-openjdk17-builder:dev will be built.

function usage() {
echo " "
echo "Usage:"
echo "  * First Build EAP S2I builder docker images, EAP cloud feature-pack and EAP maven plugin, download an EAP 8 builder maven repo (eg: jboss-eap-8.0.0.GA-redhat-99999-maven-repository.zip)."
echo "  * Then call: sh ./build-custom-image.sh <path to built cloud FP repo> <path to built EAP maven plugin repo> <path to maven repo zip>"
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
repoDir=$(find $tmpPath -type d -iname "*-maven-repository")
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

echo "Install the custom WildFly maven plugin and its parent into the maven repo"
pushd "${4}" > /dev/null
wfpluginVersion=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout)
mkdir -p $tmpPath/docker/maven-repository/org/wildfly/plugins/wildfly-maven-plugin/$wfpluginVersion
cp plugin/target/wildfly-maven-plugin-$wfpluginVersion.jar $tmpPath/docker/maven-repository/org/wildfly/plugins/wildfly-maven-plugin/$wfpluginVersion
cp plugin/pom.xml $tmpPath/docker/maven-repository/org/wildfly/plugins/wildfly-maven-plugin/$wfpluginVersion/wildfly-maven-plugin-$wfpluginVersion.pom

mkdir -p $tmpPath/docker/maven-repository/org/wildfly/plugins/wildfly-plugin-core/$wfpluginVersion
cp core/target/wildfly-plugin-core-$wfpluginVersion.jar $tmpPath/docker/maven-repository/org/wildfly/plugins/wildfly-plugin-core/$wfpluginVersion
cp core/pom.xml $tmpPath/docker/maven-repository/org/wildfly/plugins/wildfly-plugin-core/$wfpluginVersion/wildfly-plugin-core-$wfpluginVersion.pom


mkdir -p $tmpPath/docker/maven-repository/org/wildfly/plugins/wildfly-maven-plugin-parent/$wfpluginVersion
cp pom.xml $tmpPath/docker/maven-repository/org/wildfly/plugins/wildfly-maven-plugin-parent/$wfpluginVersion/wildfly-maven-plugin-parent-$wfpluginVersion.pom

popd > /dev/null

echo "Install channel org.jboss.eap.channels:eap-8.0:1.0.0.Final-redhat-00001"
mkdir -p $tmpPath/docker/maven-repository/org/jboss/eap/channels/eap-8.0/1.0.0.Final-redhat-00001
cp  $tmpPath/docker/maven-repository/org/jboss/eap/wildfly-ee-galleon-pack/8.0.0.GA-redhat-99999/wildfly-ee-galleon-pack-8.0.0.GA-redhat-99999-channel.yaml $tmpPath/docker/maven-repository/org/jboss/eap/channels/eap-8.0/1.0.0.Final-redhat-00001/eap-8.0-1.0.0.Final-redhat-00001-channel.yaml
cat <<EOF >> $tmpPath/docker/maven-repository/org/jboss/eap/channels/eap-8.0/1.0.0.Final-redhat-00001/eap-8.0-1.0.0.Final-redhat-00001-channel.yaml
  - groupId: "org.jboss.eap.cloud"
    artifactId: "eap-cloud-galleon-pack"
    version: "$cloudVersion"
  - groupId: "org.jboss.eap"
    artifactId: "eap-datasources-galleon-pack"
    version: "8.0.0.GA-redhat-99999"
EOF

echo "Generate local maven metadata to resolve latest channel"
local_metadata_file=$tmpPath/docker/maven-repository/org/jboss/eap/channels/eap-8.0/maven-metadata-local.xml
cat <<EOF > $local_metadata_file
<?xml version="1.0" encoding="UTF-8"?>
<metadata>
  <groupId>org.jboss.eap.channels</groupId>
  <artifactId>eap-8.0</artifactId>
  <versioning>
    <release>1.0.0.Final-redhat-00001</release>
    <versions>
      <version>1.0.0.Final-redhat-00001</version>
    </versions>
  </versioning>
</metadata>
EOF

echo "Build JDK17 builder docker image"
cat <<EOF > $docker_file
  FROM jboss-eap-8/eap8-openjdk17-builder-openshift-rhel8:latest
  ENV PROVISIONING_MAVEN_PLUGIN_VERSION=$pluginVersion
  RUN mkdir -p /tmp/artifacts/m2
  COPY --chown=jboss:root maven-repository /tmp/artifacts/m2
EOF
docker build -t jboss-eap-8/custom-eap8-openjdk17-builder:dev $tmpPath/docker

rm -rf $tmpPath

echo "Image jboss-eap-8/custom-eap8-openjdk17-builder:dev has been created"