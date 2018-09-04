#!/bin/bash

if [ $# -ne 2 ]
then
  echo "Error calling $0: Version not specified."
  printf "\nUsage: $0 versionName versionNumber\n"
  printf "\nExample: $0 8.1-QAT 8.1.0.0\n"
  exit 1
fi

VERSION=$1
VERSIONID=$2

echo "[INFO] VERSION=$VERSION"
echo "[INFO] VERSIONID=$VERSIONID"

echo "[INFO] Getting binary files to temp folder and unzipping them into pentaho structure..."

for i in $@ ; do
	arg=$i
	if [[ $PREV = "true" ]];
	then 
		version=$i;
	fi
	PREV=false
	if [[ $arg = "-v" ]];
	then
		PREV=true;
	fi
done

echo "[INFO] Creating pentaho structural folders..."

mkdir /pentaho/
mkdir /pentaho/design-tools/
mkdir /pentaho/licenses/
mkdir /temp/

latest=$(cat /scripts/latest.txt)

wget http://10.177.176.213/hosted/$VERSION/$latest/pad-ee-$VERSIONID-$latest.zip -P /temp/
unzip /temp/pad-ee-$VERSIONID-$latest.zip -d /pentaho/design-tools/
wget http://10.177.176.213/hosted/$VERSION/$latest/pentaho-server-ee-$VERSIONID-$latest.zip -P /temp/
unzip /temp/pentaho-server-ee-$VERSIONID-$latest.zip -d /pentaho/
wget http://10.177.176.213/hosted/$VERSION/$latest/paz-plugin-ee-$VERSIONID-$latest.zip -P /temp/
unzip /temp/paz-plugin-ee-$VERSIONID-$latest.zip -d /pentaho/pentaho-server/pentaho-solutions/system/
wget http://10.177.176.213/hosted/$VERSION/$latest/pdi-ee-client-$VERSIONID-$latest.zip -P /temp/
unzip /temp/pdi-ee-client-$VERSIONID-$latest.zip -d /pentaho/design-tools/
wget http://10.177.176.213/hosted/$VERSION/$latest/pir-plugin-ee-$VERSIONID-$latest.zip -P /temp/
unzip /temp/pir-plugin-ee-$VERSIONID-$latest.zip -d /pentaho/pentaho-server/pentaho-solutions/system/
wget http://10.177.176.213/hosted/$VERSION/$latest/pme-ee-$VERSIONID-$latest.zip -P /temp/
unzip /temp/pme-ee-$VERSIONID-$latest.zip -d /pentaho/design-tools/
wget http://10.177.176.213/hosted/$VERSION/$latest/prd-ee-$VERSIONID-$latest.zip -P /temp/
unzip /temp/prd-ee-$VERSIONID-$latest.zip -d /pentaho/design-tools/
wget http://10.177.176.213/hosted/$VERSION/$latest/psw-ee-3.15-QAT-$latest.zip -P /temp/
unzip /temp/psw-ee-3.14-QAT-$latest.zip -d /pentaho/design-tools/
wget http://10.177.176.213/hosted/$VERSION/$latest/pdd-plugin-ee-$VERSIONID-$latest.zip -P /temp/
unzip /temp/pdd-plugin-ee-$VERSIONID-$latest.zip -d /pentaho/pentaho-server/pentaho-solutions/system/

echo "[INFO] Deleting downloads and temp folder..."
rm -R /temp/

echo "[INFO] Finished installing binaries."

