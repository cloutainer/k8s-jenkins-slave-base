#!/bin/bash

#
# WARNING: RUN AS ROOT ON RUNTIME VIA SUDO !!!
#

DOCKER_SOCK_GROUP=$(ls -lap /var/run/docker.sock  | awk '{ print $4 }')
DOCKER_SOCK_GID=$(getent group $DOCKER_SOCK_GROUP | awk -F  ":" '{ print $3 }')

