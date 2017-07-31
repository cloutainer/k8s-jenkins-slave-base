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
# ENTRYPOINT-HOOK (CHILD IMAGE)
#
bash /opt/docker-entrypoint-hook.sh

#
# JENKINS SLAVE JNLP
#
echo "DOCKER-ENTRYPOINT >> config: JENKINS_NAME:     $JENKINS_NAME"
echo "DOCKER-ENTRYPOINT >> config: JENKINS_SECRET:   $JENKINS_SECRET"
echo "DOCKER-ENTRYPOINT >> config: JENKINS_URL:      $JENKINS_URL"
echo "DOCKER-ENTRYPOINT >> config: JENKINS_JNLP_URL: $JENKINS_JNLP_URL"

echo "DOCKER-ENTRYPOINT >> downloading jenkins-slave.jar from Jenkins"
echo "DOCKER-ENTRYPOINT >> ${JENKINS_URL}/jnlpJars/slave.jar"

curl -sSLo /tmp/jenkins-slave.jar ${JENKINS_URL}/jnlpJars/slave.jar

echo "DOCKER-ENTRYPOINT >> establishing JNLP connection with Jenkins via JNLP URL"

exec java $JAVA_OPTS -cp /tmp/jenkins-slave.jar \
            hudson.remoting.jnlp.Main -headless \
            -url $JENKINS_URL $JENKINS_SECRET $JENKINS_NAME


### remoting-3.10 is bundled with jenkins 2.71
### curl -sSLo /tmp/jenkins-slave.jar  https://repo.jenkins-ci.org/releases/org/jenkins-ci/main/remoting/3.10/remoting-3.10.jar
