#!/bin/bash
# Script to build the JDK17 S2I builder images containing XP5 incremental bits in a local maven repository.

function usage() {
echo " "
echo "Usage:"
echo "  * Call: sh ./2.1-build-xp-images-from-maven-repo.sh <path to xp maven repo zip>"
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
mv $tmpPath/maven-repository $tmpPath/docker/

xpVersion=$(echo $tmpPath/docker/maven-repository/org/jboss/eap/xp/wildfly-galleon-pack/*/)
xpVersion=${xpVersion::-1}
xpVersion=$(basename ${xpVersion})

echo "XP5 version is $xpVersion"
cp ocp-settings.xml $tmpPath/docker/ocp-settings.xml
docker_file=$tmpPath/docker/Dockerfile
echo "Build JDK17 builder docker image"
cat <<EOF > $docker_file
  FROM registry.redhat.io/jboss-eap-8/eap8-openjdk17-builder-openshift-rhel8:latest
  COPY --chown=jboss:root ocp-settings.xml /home/jboss/.m2/settings.xml
  COPY --chown=jboss:root maven-repository /maven-repository
EOF
docker build -t jboss-eap-8/custom-eap8-xp5-openjdk17-builder:latest $tmpPath/docker
docker system prune -f

rm -rf $tmpPath

echo "Image jboss-eap-8/custom-eap8-xp5-openjdk17-builder:latest has been created"