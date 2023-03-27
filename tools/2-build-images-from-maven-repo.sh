#!/bin/bash
# Script to build the JDK17 S2I builder images containing all EAP 8 bits in a local maven repository.

function usage() {
echo " "
echo "Usage:"
echo "  * Call: sh ./build-images-from-maven-repo.sh <path to maven repo zip>"
echo " "
exit 1
}

if [ ! -f "$1" ]; then
  echo "ERROR: Zipped builder maven repository is missing or doesn't exist"
  usage 
fi

SCRIPT_DIR=$(dirname $0)
tmpPath=/tmp/custom-cloud-image
rm -rf $tmpPath
mkdir -p $tmpPath
mkdir -p $tmpPath/docker/

echo "Unzip the maven repo to the docker build context..."
unzip "${1}" -d $tmpPath > /dev/null
repoDir=$(find $tmpPath -type d -iname "*-maven-repository")
mv $repoDir/maven-repository $tmpPath/docker/

cp ocp-settings.xml $tmpPath/docker/ocp-settings.xml
eapVersion=$(echo $tmpPath/docker/maven-repository/org/jboss/eap/wildfly-ee-galleon-pack/*/)
eapVersion=${eapVersion::-1}
eapVersion=$(basename ${eapVersion})


pluginVersion=$(echo $tmpPath/docker/maven-repository/org/jboss/eap/plugins/eap-maven-plugin/*/)
pluginVersion=${pluginVersion::-1}
pluginVersion=$(basename ${pluginVersion})

echo "EAP8 version is $eapVersion"
docker_file=$tmpPath/docker/Dockerfile
echo "Build JDK17 builder docker image"
cat <<EOF > $docker_file
  FROM jboss-eap-8/eap8-openjdk17-builder-openshift-rhel8:latest
  ENV PROVISIONING_MAVEN_PLUGIN_VERSION=$pluginVersion
  COPY --chown=jboss:root ocp-settings.xml /home/jboss/.m2/settings.xml
  COPY --chown=jboss:root maven-repository /maven-repository
EOF
docker build -t jboss-eap-8/custom-eap8-openjdk17-builder:latest $tmpPath/docker
docker system prune -f

rm -rf $tmpPath

echo "Image jboss-eap-8/custom-eap8-openjdk17-builder:latest has been created"