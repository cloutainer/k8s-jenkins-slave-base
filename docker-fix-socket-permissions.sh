#!/bin/bash

set -e

#
# WARNING: RUNS AS ROOT ON RUNTIME VIA SUDO !!!
#

if [ -S /var/run/docker.sock ]
then
  JENKINS_USER="jenkins"
  echo "DOCKER-ENTRYPOINT >> DOCKER-SOCK-FIX: /var/run/docker.sock does exist. Applying GID fix."
  DOCKER_SOCK_GROUP=$(ls -lap /var/run/docker.sock  | awk '{ print $4 }')
  echo "DOCKER-ENTRYPOINT >> DOCKER-SOCK-FIX: docker.sock owned by group '${DOCKER_SOCK_GROUP}'"
  re='^[0-9]+$'
  if ! [[ $DOCKER_SOCK_GROUP =~ $re ]] ; then
    # GROUP IS NOT NUMERIC => GROUP EXISTS INSIDE CONTAINER
    if groups $JENKINS_USER | grep &>/dev/null "\b${DOCKER_SOCK_GROUP}\b"; then
      echo "DOCKER-ENTRYPOINT >> DOCKER-SOCK-FIX: ${JENKINS_USER} is already part of the group. Skipping."
    else
      echo "DOCKER-ENTRYPOINT >> DOCKER-SOCK-FIX: ${JENKINS_USER} is not part of the group. Will be added."
      usermod -aG $DOCKER_SOCK_GROUP $JENKINS_USER
    fi
  else
    # GROUP IS NUMERIC => GROUP DOES NOT EXISTS INSIDE CONTAINER
    echo "DOCKER-ENTRYPOINT >> DOCKER-SOCK-FIX: ${JENKINS_USER} is not part of the group. Group will be created. User will be added."
    groupadd --gid $DOCKER_SOCK_GROUP g_$DOCKER_SOCK_GROUP
    usermod -aG g_$DOCKER_SOCK_GROUP $JENKINS_USER
  fi
else
  echo "DOCKER-ENTRYPOINT >> DOCKER-SOCK-FIX: /var/run/docker.sock does not exist. Skipping GID fix."
fi
