#FROM quay.io/openshift/origin-jenkins-agent-base:4.2.0
FROM image-registry.openshift-image-registry.svc:5000/openshift/jenkins-agent-maven:latest
MAINTAINER null@null.null

# Labels consumed by Red Hat build service
LABEL com.redhat.component="jenkins-agent-maven-j11-rhel7-container" \
      name="openshift4/jenkins-agent-maven-j11-rhel7" \
      version="4" \
      architecture="x86_64" \
      io.k8s.display-name="Jenkins Agent Maven" \
      io.k8s.description="The jenkins agent maven image has the maven tools on top of the jenkins worker base image." \
      io.openshift.tags="openshift,jenkins,agent,maven"

ENV MAVEN_VERSION=3.5 \
    BASH_ENV=/usr/local/bin/scl_enable \
    ENV=/usr/local/bin/scl_enable \
    PROMPT_COMMAND=". /usr/local/bin/scl_enable" \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

# Install 
RUN INSTALL_PKGS="java-11-openjdk-devel java-1.8.0-openjdk-devel" && \
    yum install -y $INSTALL_PKGS && \
    rpm -V  java-11-openjdk-devel java-1.8.0-openjdk-devel && \
    yum clean all -y && \
    mkdir -p $HOME/.m2

# When bash is started non-interactively, to run a shell script, for example it
# looks for this variable and source the content of this file. This will enable
# the SCL for all scripts without need to do 'scl enable'.
ADD contrib/bin/scl_enable /usr/local/bin/scl_enable
ADD contrib/bin/configure-agent /usr/local/bin/configure-agent
ADD ./contrib/settings.xml $HOME/.m2/

RUN chown -R 1001:0 $HOME && \
    chmod -R g+rw $HOME

USER 1001
