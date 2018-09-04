# docker-nightlies

## Requirements

* Currently, the scripts frequently reference the path: `/home/pentaho/docker-nightlies` - Therefore, the `docker-nightlies` folder should have be placed in that location. 
* Docker should be installed in the machina that's acting as server (the one with the registry) and in the one acting as client.
* A registry needs to be running on the server side.
* The server's ip should be added to the deamon's insecure registry on clients.

### CloudStack 

* Specifically when dealing with CloudStack VMs, the server needs to have a dedicated disk that will store all docker related files/data. That is described bellow. Scroll down to *CloudStack Environment* for more detail. 

## Files

#### _nightly-hourly-runner_

Executes `getLatest.sh` every hour.

#### _getLatest.sh_

Checks if there's a new build in build.pentaho.com - does this by comparing the `build.info` version that it downloads from the build page with the latest build number that is stored in `/home/pentaho/docker-nightlies/dockerfiles/scripts/latest.txt`. Note: if for some reason the latest build wasn't installed (e.g. because of an error downloading the binary files) the build number in `latest.txt` won't change back to the previous and during that day it won't try to install the current build again because it will assume that it already has the latest one.

#### _buildNightly.sh_

Purpose:
* Build `cbf2-core` docker image if it doesn't exists;
* Build pentaho docker image;
  * If it already exists locally removes it;
  * Removes it from the registry also;
* Pushes the new one to the registry;
* Executes docker's garbage-collector.

## Troubleshooting

If an error occurs when **deleting an image from the docker registry** it means the registry config file was changed. Move the `config.yml` file, located at the root of the project to `/etc/docker/registry`. That files has a flag that allows deleting the images from the registry (`delete: enable: true`).

#### _cleanup.sh_

Purpose:
* Delete untagged images;
* Remove dead containers;
* Delete unused volumes.

#### _Dockerfile-Nightly_

Pentaho docker file. `cbf2-core` is built from `ubuntu` and pentaho docker image is built from cbf2-core.
Adds the `getBinaries.sh` file to the image to be run inside the container (that means the pentaho files will be downloaded once the image is pulled).

#### _getBinaries.sh_

Downloads pentaho binary files to be manual installed when the image is pulled. 

## Server Restart

Steps to took when server is restarted: 
* Start the docker registry container:
  * docker ps -a (copy the container ID);
  * docker start {containerID};
* run _nightly-hourly-runner_ via VNC.

## CloudStack Environment

Since the disk space in CloudStack's VM is limited, I added a dedicated volume to be used by docker. 
Steps I took: 
* Added a new volume (1TB) on cloudstack;
* Set the volume to be auto mounted in `/mnt/xvda3`;
* Edited the docker.service to use the folder `/mnt/xvda3` to store data. (https://linuxconfig.org/how-to-move-docker-s-default-var-lib-docker-to-another-directory-on-ubuntu-debian-linux)

When **restarting the server in CloudStack** ensure the 1TB disk is mounted in the right place, otherwise docker will start creating files in that directory and the main disk will be full. 

## Licenses 

When there are new licenses they should be added to the licenses folder. The licenses will be added to pentaho when a new build is installed. 

