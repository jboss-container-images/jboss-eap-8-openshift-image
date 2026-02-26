#!/bin/bash
set -e
tmpPath=$1
jdkVersion=$2
# get zipped repository
latestEAP=$(curl -s https://eap-prod-share.usersys.redhat.com/eap/ | egrep -o 8.1.[0-9]+.GA-CR[0-9]+\(\\.[0-9]+\)? | sort -Vr | head -1)
latestXP=$(curl -s https://jenkins-csb-eap-prod.dno.corp.redhat.com/job/Tiers-pipeline/job/XP-test-pipeline/lastSuccessfulBuild/artifact/ | egrep -o jboss-eap-xp-6.0.[0-9]+.GA-CR[0-9]+\(\\.[0-9]+\)? | sort -Vr | head -1)
echo Latest EAP repos version $latestEAP
echo Latest XP repository $latestXP 
wget https://eap-prod-share.usersys.redhat.com/eap/$latestEAP-candidate/jboss-eap-$latestEAP-maven-repository.zip
wget https://eap-prod-share.usersys.redhat.com/eap/$latestEAP-candidate/jboss-eap-$latestEAP-mrrc-only-maven-repository.zip
wget https://jenkins-csb-eap-prod.dno.corp.redhat.com/job/Tiers-pipeline/job/XP-test-pipeline/lastSuccessfulBuild/artifact/$latestXP-maven-repository.zip
echo "Unzip the maven repo to the docker build context..."
unzip "${WORKSPACE}/jboss-eap-$latestEAP-maven-repository.zip" -d $tmpPath/repo > /dev/null
unzip "${WORKSPACE}/jboss-eap-$latestEAP-mrrc-only-maven-repository.zip" -d $tmpPath/mrrc > /dev/null
unzip "${WORKSPACE}/$latestXP-maven-repository.zip" -d $tmpPath/xp > /dev/null

repoDir=$(find $tmpPath/repo -type d -iname "*-maven-repository")
repoMrrcDir=$(find $tmpPath/mrrc -type d -iname "*-maven-repository")
repoXpDir=$(find $tmpPath/xp -type d -iname "*-maven-repository")

mv $repoDir/maven-repository $tmpPath/docker
mkdir -p $tmpPath/docker/maven-repository/org/jboss/eap/plugins
mv $repoMrrcDir/maven-repository/org/jboss/eap/plugins/* $tmpPath/docker/maven-repository/org/jboss/eap/plugins
cp -r $repoXpDir/maven-repository/* $tmpPath/docker/maven-repository

cp tools/ocp-settings.xml $tmpPath/docker/ocp-settings.xml

eapVersion=$(echo $tmpPath/docker/maven-repository/org/jboss/eap/wildfly-ee-galleon-pack/*/)
eapVersion=${eapVersion::-1}
eapVersion=$(basename ${eapVersion})

eapXpVersion=$(echo $tmpPath/docker/maven-repository/org/jboss/eap/xp/wildfly-galleon-pack/*/)
eapXpVersion=${eapXpVersion::-1}
eapXpVersion=$(basename ${eapXpVersion})

pluginVersion=$(echo $tmpPath/docker/maven-repository/org/jboss/eap/plugins/eap-maven-plugin/*/)
pluginVersion=${pluginVersion::-1}
pluginVersion=$(basename ${pluginVersion})

echo "EAP8.1 version is $eapVersion"
echo "XP6 version is $eapXpVersion"

docker_file=$tmpPath/docker/Dockerfile
echo "Create JDK $jdkVersion custom builder docker file"
cat <<EOF > $docker_file
  FROM jboss-eap-8/eap81-open$jdkVersion-builder-openshift-rhel9:latest
  ENV PROVISIONING_MAVEN_PLUGIN_VERSION=$pluginVersion
  COPY --chown=jboss:root ocp-settings.xml /home/jboss/.m2/settings.xml
  COPY --chown=jboss:root maven-repository /maven-repository
EOF
echo "Generated docker file:"
cat $docker_file

/bin/python -m venv cekit
. ./cekit/bin/activate
export KEYTAB=~/keytab-eap-qe-ci
export DOCKER_HOST=unix:///var/run/podman/podman.sock
export CONTAINER_HOST=unix:///var/run/podman/podman.sock
podman system prune -af
docker pull registry.access.redhat.com/ubi9/ubi-minimal:latest
pip install cekit docker docker-squash python-docker odcs behave lxml gssapi requests_gssapi
export REQUESTS_CA_BUNDLE=/etc/ssl/certs/2022-IT-Root-CA.pem
cd builder-image
kinit eap-qe-ci -k -t ${KEYTAB}

if [ $jdkVersion = "jdk21" ]; then
  overrides="--overrides image-jdk21-overrides.yaml"
fi

cekit --redhat build $overrides podman

docker build -t jboss-eap-8/custom-eap81-open$jdkVersion-builder:latest $tmpPath/docker
docker system prune -f

# retag the images for the tests, the localhost/ prefix is replaced with docker.io/
~/tag.sh
cd ${WORKSPACE}/builder-image
kinit eap-qe-ci -k -t ${KEYTAB}; cekit --redhat test --image=jboss-eap-8/custom-eap81-open$jdkVersion-builder:latest behave
