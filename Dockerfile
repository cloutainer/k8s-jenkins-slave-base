FROM ubuntu:16.04

#
# USERS AND GROUPS
#
ENV HOME /home/jenkins
RUN groupadd -g 10000 jenkins && \
    useradd -c "Jenkins user" -d $HOME -u 10000 -g 10000 -m jenkins && \
    mkdir -p /home/jenkins/.jenkins && \
    mkdir -p /home/jenkins/agent && \
    chown -R jenkins:jenkins /home/jenkins/ && \
    chown jenkins:jenkins /home/jenkins/.jenkins && \
    chmod 750 /home/jenkins/ && \
    chmod -R 750 /home/jenkins/.jenkins

#
# BASE PACKAGES
#
RUN apt-get -qqy update \
    && apt-get -qqy --no-install-recommends install \
    bzip2 \
    ca-certificates \
    apt-transport-https \
    unzip \
    wget \
    curl \
    git \
    jq \
    zip \
    openjdk-8-jre \
    build-essential && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/*

#
# LET JENKINS ALTER CACERTS
#
RUN chown jenkins /etc/ssl/certs/java/cacerts

#
# KUBERNETES CLI (kubectl)
#
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin/kubectl

#
# DOCKER CLI
#
RUN curl -fsSL get.docker.com -o get-docker.sh && \
    sh get-docker.sh && \
    usermod -aG docker jenkins

#
# CLOUDFOUNDRY CLI
#
RUN wget -q -O - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | apt-key add - && \
    echo "deb http://packages.cloudfoundry.org/debian stable main" >> /etc/apt/sources.list.d/cloudfoundry-cli.list && \
    apt-get update -qqy && apt-get -qqy install cf-cli && \
    rm /etc/apt/sources.list.d/cloudfoundry-cli.list && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/*

#
# INSTALL AND CONFIGURE
#
COPY docker-entrypoint.sh /opt/docker-entrypoint.sh
RUN chmod u+rx,g+rx,o+rx,a-w /opt/docker-entrypoint.sh

#
# FIX GID ACCESS TO docker.sock
#
# (Why? Since docker.sock can have variable GID on HOST, and we need our Docker-in-Docker User to be part of that Group)
COPY docker-entrypoint.sh /opt/docker-fix-socket-permissions.sh
RUN chmod u+rx,g-rwx,o-rwx,a-w /opt/docker-fix-socket-permissions.sh && \
    echo "jenkins ALL=(ALL) NOPASSWD: /opt/docker-fix-socket-permissions.sh" >> /etc/sudoers


# VOLUMES AND ENTRYPOINT
#
VOLUME /home/jenkins/.jenkins
VOLUME /home/jenkins/agent
WORKDIR /home/jenkins
ENTRYPOINT ["/opt/docker-entrypoint.sh"]

