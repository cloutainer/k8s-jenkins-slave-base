<p align="right"><img src="https://cloutainer.github.io/documentation/images/cloutainer.svg?v3"></p>

# k8s-jenkins-slave-base

Base image for all k8s images.


-----
&nbsp;

### Usage

Use in Dockerfile:

```
FROM cloutainer/k8s-jenkins-slave-base:v5

COPY docker-entrypoint-hook.sh /opt/docker-entrypoint-hook.sh
RUN chmod u+rx,g+rx,o+rx,a-w /opt/docker-entrypoint-hook.sh

# ...

USER jenkins
```

Always provide a file called `docker-entrypoint-hook.sh` and copy it to `/opt/`.
It will be executed by the entrypoint before the JNLP remoting jar extablishes the connection to Jenkins.



-----
&nbsp;

### License

[MIT](https://github.com/cloutainer/k8s-jenkins-slave-base/blob/master/LICENSE) © [Bernhard Grünewaldt](https://github.com/clouless)
