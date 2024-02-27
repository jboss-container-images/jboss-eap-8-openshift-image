#!/bin/bash

xp=${1:-"eap8"}

if [ "$xp" = "xp5" ]; then
 echo "XP5 tests is enabled, running XP5 tests only"
 JDK17_BUILDER_IMAGE=jboss-eap-8/custom-eap8-xp5-openjdk17-builder:latest
else
 JDK17_BUILDER_IMAGE=jboss-eap-8/custom-eap8-openjdk17-builder:latest
fi

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

cekit --version 

cp -r $imageDir/all-tests/features/scripts $imageDir/tests/features
for feature in $imageDir/all-tests/features/*.feature; do
  if [ "$xp" = "xp5" ]; then
    if ! grep -q "@xp5" "$feature"; then
      continue
    fi
  fi
  if ! grep -q "#IGNORE_TEST_RUN" "$feature"; then
    featureFileName="$(basename -- $feature)"
    featureFile="$imageDir/tests/features/$featureFileName"
    cp "$feature" "$featureFile"
    logFilejdk17=$logsDir/$featureFileName.jdk17.log
    pushd "$imageDir" > /dev/null
      echo "RUNNING $featureFileName with JDK17"
      cekit --redhat test --image=$JDK17_BUILDER_IMAGE --overrides=image-jdk17-overrides.yaml behave > $logFilejdk17 2>&1
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