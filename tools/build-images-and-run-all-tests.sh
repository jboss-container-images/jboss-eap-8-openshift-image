function usage() {
echo " "
echo "Usage:"
echo "  * Call: sh ./build-images-and-run-all-tests.sh <path to maven repo zip>"
echo " "
exit 1
}

if [ ! -f "$1" ]; then
  echo "ERROR: Zipped builder maven repository is missing or doesn't exist"
  usage 
fi

sh ./1-build-images.sh
sh ./2-build-images-from-maven-repository.sh $1
sh ./3-run-behave-tests.sh
sh ./4-run-extra-tests.sh