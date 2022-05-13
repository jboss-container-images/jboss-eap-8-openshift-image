#!/bin/bash

function usage() {
echo " "
echo "Usage:"
echo "  * Call: sh ./run-single-behave-test.sh <feature file name>"
echo " "
exit 1
}

if [ ! -f "../builder-image/tests/features/$1" ]; then
  echo "ERROR: No feature-file provided or feature file doesn't exist"
  usage 
fi


JDK11_BUILDER_IMAGE=jboss-eap-8-tech-preview/custom-eap8-openjdk11-builder:latest
JDK17_BUILDER_IMAGE=jboss-eap-8-tech-preview/custom-eap8-openjdk17-builder:latest

tmpPath=/tmp/jboss-eap-8-images-testing

rm -rf $tmpPath
mkdir -p $tmpPath

echo "Running image behave tests in $tmpPath"
cp -r ../builder-image $tmpPath
cp -r ../modules $tmpPath
imageDir=$tmpPath/builder-image

logsDir=$tmpPath/logs
mv $imageDir/tests/ $imageDir/all-tests
mkdir -p $imageDir/tests/features
mkdir -p $logsDir

cp -r $imageDir/all-tests/features/scripts $imageDir/tests/features
featureFileName=$1
featureFile="$imageDir/tests/features/$featureFileName"
cp "$imageDir/all-tests/features/$featureFileName" "$featureFile"
logFilejdk11=$logsDir/$featureFileName.jdk11.log
logFilejdk17=$logsDir/$featureFileName.jdk17.log
pushd "$imageDir" > /dev/null
      echo "RUNNING $featureFileName with JDK11, logs redirected to $logFilejdk11"
      cekit --redhat test --image=$JDK11_BUILDER_IMAGE behave > $logFilejdk11 2>&1
      RESULT=$?
      docker system prune -f
      if [ $RESULT != 0 ]; then
        echo "ERROR for $featureFileName, check log file $logFilejdk11"
        exit 1
      fi
      echo "RUNNING $featureFileName with JDK17, logs redirected to $logFilejdk17"
      cekit --redhat test --image=$JDK17_BUILDER_IMAGE behave > $logFilejdk17 2>&1
      RESULT=$?
      docker system prune -f
      if [ $RESULT != 0 ]; then
        echo "ERROR for $featureFileName, check log file $logFilejdk17"
        exit 1
      fi
      rm "$featureFile"
popd > /dev/null

rm -rf $tmpPath