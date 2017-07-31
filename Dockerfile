FROM ubuntu:16.04

#
# USERS AND GROUPS
#
ENV HOME /home/jenkins
RUN groupadd -g 10000 jenkins && \
    useradd -c "Jenkins user" -d $HOME -u 10000 -g 10000 -m jenkins && \
    mkdir /home/jenkins/.jenkins/ && \
    chown -R jenkins:jenkins /home/jenkins/ && \
    chown jenkins:jenkins /home/jenkins/.jenkins && \
    chown jenkins:jenkins /home/jenkins/.jenkins && \
    chmod 750 /home/jenkins/ && \
    chmod 750 /home/jenkins/.jenkins

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
# VOLUMES AND ENTRYPOINT
#
VOLUME /home/jenkins/.jenkins
WORKDIR /home/jenkins
ENTRYPOINT ["/opt/docker-entrypoint.sh"]

