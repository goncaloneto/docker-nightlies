#!/bin/bash

if [ $# -ne 1 ]
then
  echo "Error calling $0: Version not specified."
  printf "\nUsage: $0 versionName\n"
  printf "\nExample: $0 8.1-QAT\n" 
  exit 1
fi

VERSION=$(echo $1 | sed 's/[^0-9]*//g')

echo "[INFO] This is the version number that will go on the docker image: VERSION=$VERSION"

latest=$(cat dockerfiles/scripts/latest.txt)
echo "INFO: Creating image for build number "$latest

#Check if cbf2-core image exists, if not builds it
echo "INFO: Checking if cbf2-core image exists..."
docker images cbf2-core | grep cbf2-core
if [ $? != "0" ]
then
  echo "INFO: It doesn't. Building cbf2-core docker image..."
  sudo docker build -t cbf2-core -f /home/pentaho/docker-nightlies/dockerfiles/Dockerfile-CoreCBF /home/pentaho/docker-nightlies/dockerfiles
else
  echo "INFO: It exists...skipping..."
fi
####

#Check build number
echo "INFO: Using build number - LATEST= "$latest

#Check if pentaho:latest exists to remove it
echo "INFO: Checking if there is a build in the registry..."
docker images pentaho$VERSION:latest | grep pentaho$VERSION
if [ $? == "0" ]
then
  #Delete current docker image of pentaho:latest in registry
  echo "INFO: It exists. Deleting current latest image..."
  docker rmi -f pentaho$VERSION:latest
else
  echo "INFO: It doesn't exists...skipping..."
fi
####

#Delete latest on Registry
SHA=$(curl -k -v --silent -H "Accept: application/vnd.docker.distribution.manifest.v2+json" -X GET http://localhost:5000/v2/pentaho$VERSION/manifests/latest 2>&1 | grep Docker-Content-Digest | awk '{print ($3)}')

SHA=$(echo $SHA |tr '\r' ' ')

curl -k -v --silent -X DELETE http://localhost:5000/v2/pentaho$VERSION/manifests/$SHA

#build docker image locally
echo "INFO: Building Dockerfile-Nightly..."
docker build --rm -t pentaho$VERSION -f /home/pentaho/docker-nightlies/dockerfiles/Dockerfile-Nightly /home/pentaho/docker-nightlies/dockerfiles

#Tag current latest build
echo "INFO: Tagging Latest build..."
docker tag pentaho$VERSION localhost:5000/pentaho$VERSION:latest

#Push current latest build to registry
echo "INFO: Pushing Latest to registry..."
docker push localhost:5000/pentaho$VERSION:latest

#Tag the new version with the build number as tag to keep
#echo "INFO: Tagging Latest build with build number"
#docker tag pentaho80rc 172.20.50.20:5050/pentaho80rc:$latest

#Push the new version with the build number as tag to keep
#echo "INFO: Pushing Latest build with build number"
#docker push 172.20.50.20:5050/pentaho80rc:$latest

#Tag the new version with the build number for CBF use
#echo "INFO: Tagging Latest build with build number"
#docker tag pentaho80rc 172.20.50.20:5050/baserver-ee-7.1-qat:$latest

#Push the new version with the build number for CBF use
#echo "INFO: Pushing Latest build with build number"
#docker push 172.20.50.20:5050/baserver-ee-7.1-qat:$latest

#Remove local images
echo "INFO: Deleting local registry latest image..."
docker rmi localhost:5000/pentaho$VERSION:latest

#echo "INFO: Deleting local registry latest with build number image..."
#docker rmi 172.20.50.20:5050/pentaho80rc:$latest

#echo "INFO: Deleting Latest build with build number for CBF use"
#docker rmi 172.20.50.20:5050/baserver-ee-7.1-qat:$latest

docker exec registry /bin/registry garbage-collect /etc/docker/registry/config.yml

