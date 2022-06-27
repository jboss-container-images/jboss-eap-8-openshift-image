#!/bin/bash
# Script to build the JDK11 and JDK17 S2I builder images containing all EAP 8 bits in a local maven repository.

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
echo "EAP8 version is $eapVersion"


echo "Add cloud and datasources FP to org.jboss.eap.channels:eap-8.0-beta:1.0.0.Beta-redhat-00001"
cat <<EOF >> $tmpPath/docker/maven-repository/org/jboss/eap/channels/eap-8.0-beta/1.0.0.Beta-redhat-00001/eap-8.0-beta-1.0.0.Beta-redhat-00001-channel.yaml
  - groupId: "org.jboss.eap.cloud"
    artifactId: "eap-cloud-galleon-pack"
    version: "$eapVersion"
  - groupId: "org.jboss.eap"
    artifactId: "eap-datasources-galleon-pack"
    version: "$eapVersion"
EOF

echo "Build JDK11 builder docker image"
docker_file=$tmpPath/docker/Dockerfile
cat <<EOF > $docker_file
  FROM jboss-eap-8-tech-preview/eap8-openjdk11-builder-openshift-rhel8:latest
  RUN mkdir -p /tmp/artifacts/m2
  COPY --chown=jboss:root ocp-settings.xml /home/jboss/.m2/settings.xml
  COPY --chown=jboss:root maven-repository /maven-repository
EOF
docker build -t jboss-eap-8-tech-preview/custom-eap8-openjdk11-builder:latest $tmpPath/docker

echo "Build JDK17 builder docker image"
cat <<EOF > $docker_file
  FROM jboss-eap-8-tech-preview/eap8-openjdk17-builder-openshift-rhel8:latest
  RUN mkdir -p /tmp/artifacts/m2
  COPY --chown=jboss:root ocp-settings.xml /home/jboss/.m2/settings.xml
  COPY --chown=jboss:root maven-repository /maven-repository
EOF
docker build -t jboss-eap-8-tech-preview/custom-eap8-openjdk17-builder:latest $tmpPath/docker
docker system prune -f

rm -rf $tmpPath

echo "Images   jboss-eap-8-tech-preview/custom-eap8-openjdk11-builder:latest and jboss-eap-8-tech-preview/custom-eap8-openjdk17-builder:latest have been created"