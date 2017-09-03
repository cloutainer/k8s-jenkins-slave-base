#!/bin/bash

set -e

#
# UMASK
#
umask u+rxw,g+rwx,o-rwx

#
# USER
#
RUNAS=$(whoami)
echo "DOCKER-ENTRYPOINT >> running as user: ${RUNAS}"

#
# FIX DOCKER SOCKET
#
sudo /opt/docker-fix-socket-permissions.sh

#
# IMPORT KUBERNETES ca.crt (OPTIONAL)
#
if [ -n "$KUBERNETES_CA_BASE64" ]
then
  echo $KUBERNETES_CA_BASE64 | base64 --decode > /tmp/kube-ca.crt
  echo "DOCKER-ENTRYPOINT >> KUBERNETES_CA_BASE64 ENV VAR > importing kubernetes ca certificate to java keystore."
  cat /tmp/kube-ca.crt
  keytool -importcert -keystore /etc/ssl/certs/java/cacerts -alias kubernetes -file /tmp/kube-ca.crt -storepass changeit -noprompt
else
  echo "DOCKER-ENTRYPOINT >> KUBERNETES_CA_BASE64 ENV VAR > not set. SKIPPING importing of kubernetes ca certificate."
fi

#
# ENTRYPOINT-HOOK (CHILD IMAGE)
#
echo "DOCKER-ENTRYPOINT >> starting entrypoint hook"
source /opt/docker-entrypoint-hook.sh
# reload session and make docker main group! now "docker ps" works!!!
newgrp - docker

#
# JENKINS SLAVE JNLP
#
echo "DOCKER-ENTRYPOINT >> config: JENKINS_NAME:     $JENKINS_NAME"
echo "DOCKER-ENTRYPOINT >> config: JENKINS_SECRET:   $JENKINS_SECRET"
echo "DOCKER-ENTRYPOINT >> config: JENKINS_URL:      $JENKINS_URL"
echo "DOCKER-ENTRYPOINT >> config: JENKINS_JNLP_URL: $JENKINS_JNLP_URL"

if [ -n "$REMOTING_JAR_URL" ]
then
  echo "DOCKER-ENTRYPOINT >> downloading jenkins-slave.jar from USER SPECIFIED URL"
  echo "DOCKER-ENTRYPOINT >> ${REMOTING_JAR_URL}"
  curl -sSLko /tmp/jenkins-slave.jar $REMOTING_JAR_URL
else  
  echo "DOCKER-ENTRYPOINT >> downloading jenkins-slave.jar from Jenkins"
  echo "DOCKER-ENTRYPOINT >> ${JENKINS_URL}/jnlpJars/slave.jar"
  curl -sSLko /tmp/jenkins-slave.jar ${JENKINS_URL}/jnlpJars/slave.jar
fi  

echo "DOCKER-ENTRYPOINT >> establishing JNLP connection with Jenkins via JNLP URL"

exec java $JAVA_OPTS -cp /tmp/jenkins-slave.jar \
            hudson.remoting.jnlp.Main -headless \
            -workDir /home/jenkins/agent/ \
            -url $JENKINS_URL $JENKINS_SECRET $JENKINS_NAME
