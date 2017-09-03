#!/bin/bash

#
# WARNING: RUNS AS ROOT ON RUNTIME VIA SUDO !!!
#
CURRENT_USER=$(whoami)
DOCKER_SOCK_GROUP=$(ls -lap /var/run/docker.sock  | awk '{ print $4 }')
re='^[0-9]+$'
if ! [[ $DOCKER_SOCK_GROUP =~ $re ]] ; then
   echo "DOCKER-ENTRYPOINT >> GROUP IS NOT NUMERIC => GROUP EXISTS INSIDE CONTAINER"
  if groups $CURRENT_USER | grep &>/dev/null "\b${DOCKER_SOCK_GROUP}\b"; then
     echo "DOCKER-ENTRYPOINT >> ${CURRENT_USER} is already part of the group. Skipping."
  else
     echo "DOCKER-ENTRYPOINT >> ${CURRENT_USER} is not part of the group. Will be added."
     usermod -aG $DOCKER_SOCK_GROUP $CURRENT_USER
  fi
else
   echo "DOCKER-ENTRYPOINT >> GROUP IS NUMERIC => GROUP DOES NOT EXISTS INSIDE CONTAINER"
   groupadd --gid $DOCKER_SOCK_GROUP g_$DOCKER_SOCK_GROUP
fi

