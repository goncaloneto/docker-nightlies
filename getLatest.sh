#!/bin/bash

if [ $# -ne 2 ]
then
  echo "Error calling $0: Version not specified."
  printf "\nUsage: $0 versionName versionNumber\n"
  printf "\nExample: $0 8.1-QAT 8.1.0.0\n"
  printf "\nWhere 8.1-QAT is the name of the folder at build.pentaho and 8.1.0.0 is the build number as it appear in the file names to donwload (e.g. pdi-ee-client-8.1.0.1-399).\n"
  exit 1
fi


VERSION=$1
VERSIONID=$2

echo "[INFO] Version name: $1"
echo "[INFO] Version number: $2"

echo "INFO: Getting build.info..."
wget http://build.pentaho.com/hosted/$VERSION/latest/build.info -P .;

if [ $? -ne 0 ]; then
  echo "Error getting: http://build.pentaho.com/hosted/$VERSION/latest/build.info"
  echo ""
  echo "Please make sure you have access to build.pentaho.com and that the version name passed as argument is valid."
  echo "Version: $VERSION"
  exit 1
fi

if [ ! -f dockerfiles/scripts/version.txt ] ; then
  touch dockerfiles/scripts/version.txt
fi

echo "$1" > dockerfiles/scripts/version.txt
echo "$2" >> dockerfiles/scripts/version.txt

build=$(cat build.info | head -n 1)
latest=$(cat dockerfiles/scripts/latest.txt)

echo "INFO: Last built was number: "$latest
echo "INFO: Latest build is number: "$build

rm build.info
echo "$build" > dockerfiles/scripts/latest.txt

if [ "$build" != "$latest" ]
then
  echo "INFO: There's a new latest build: "$build
  chmod +x ./buildNightly.sh
  echo "INFO: Cleaning up..."
  ./cleanup.sh 
  echo "INFO: EXECUTING buildNightly.sh..."
  ./buildNightly.sh $VERSION
fi
