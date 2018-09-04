#!/bin/bash

rm ./cleanup.log

#Delete <none> images

echo "[INFO] Deleting untagged images..."

docker images --no-trunc | grep '<none>' | awk '{ print $3 }' | xargs -r docker rmi &>> cleanup.log

#Clean up dead and exited containers

echo "[INFO] Removing dead containers..."

docker ps --filter status=dead --filter status=exited -aq | xargs docker rm -v &>> cleanup.log

#Delete unused volumes

echo "[INFO] Cleaning up unused volumes..."

docker volume ls -qf dangling=true | xargs -r docker volume rm &>> cleanup.log
