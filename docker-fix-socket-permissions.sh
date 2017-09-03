#!/bin/bash

set -e

#
# WARNING: RUNS AS ROOT ON RUNTIME VIA SUDO !!!
#

if [ -S /var/run/docker.sock ]
then
  # WARN: We could chgroup the socket BUT the chgrp will reach up to the docker host and render docker unusable or make unsafe on host!
  #       Therefore we try to change the GID of the existing docker group inside the container, so that the IDs match
  JENKINS_USER="jenkins"
  echo "DOCKER-ENTRYPOINT >> DOCKER-SOCK-FIX: /var/run/docker.sock does exist. Applying GID fix."
  DOCKER_SOCK_GROUP=$(ls -lap /var/run/docker.sock  | awk '{ print $4 }')
  echo "DOCKER-ENTRYPOINT >> DOCKER-SOCK-FIX: docker.sock owned by group '${DOCKER_SOCK_GROUP}'"
  if [[ $DOCKER_SOCK_GROUP =~ ^-?[0-9]+$ ]]
  then
    # GROUP IS NUMERIC => no group that already has this id assigned
    groupmod -g $DOCKER_SOCK_GROUP docker
    echo "DOCKER-ENTRYPOINT >> DOCKER-SOCK-FIX: changing existing docker group to new GID"
  else
    # GROUP IS NOT NUMERIC => some group exists with that id
    echo "DOCKER-ENTRYPOINT >> DOCKER-SOCK-FIX: skipping. already a group with that id!"
  fi
else
  echo "DOCKER-ENTRYPOINT >> DOCKER-SOCK-FIX: /var/run/docker.sock does not exist. Skipping GID fix."
fi
