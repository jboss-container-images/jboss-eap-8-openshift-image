#!/bin/bash
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
for feature in $imageDir/all-tests/features/*.feature; do
  if ! grep -q "#IGNORE_TEST_RUN" "$feature"; then
    featureFileName="$(basename -- $feature)"
    featureFile="$imageDir/tests/features/$featureFileName"
    cp "$feature" "$featureFile"
    logFilejdk11=$logsDir/$featureFileName.jdk11.log
    logFilejdk17=$logsDir/$featureFileName.jdk17.log
    pushd "$imageDir" > /dev/null
      echo "RUNNING $featureFileName with JDK11"
      cekit --redhat test --image=$JDK11_BUILDER_IMAGE behave > $logFilejdk11 2>&1
      RESULT=$?
      docker system prune -f
      if [ $RESULT != 0 ]; then
        echo "*** ERROR for $featureFileName, check log file $logFilejdk11"
        testError=true
      fi
      echo "RUNNING $featureFileName with JDK17"
      cekit --redhat test --image=$JDK17_BUILDER_IMAGE behave > $logFilejdk17 2>&1
      RESULT=$?
      docker system prune -f
      if [ $RESULT != 0 ]; then
        echo "*** ERROR for $featureFileName, check log file $logFilejdk17"
        testError="true"
      fi
      rm "$featureFile"
    popd > /dev/null
  fi
done

if [ -n "$testError" ]; then
  echo "ERROR: check logs"
  exit 1
else
  echo "SUCCESS"
  #rm -rf $tmpPath
fi