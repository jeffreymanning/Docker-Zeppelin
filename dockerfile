FROM centos7

MAINTAINER JeffM

# prerequisites
RUN yum install -y \
  bzip2 \
  git \
  java-1.7.0-openjdk \
  java-1.7.0-openjdk-devel \
  npm \
  node \
  tar \
  unzip \
  && \
  yum clean all
  
# need minimum of maven 3.3.1, latest is 3.3.3 as of 5/5/2015 - Cinco De Mayo!!
ENV MAVEN_VERSION 3.3.3
curl -sSL http://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar xzf - -C /usr/share \
  && mv /usr/share/apache-maven-$MAVEN_VERSION /usr/share/maven \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn
ENV MAVEN_HOME /usr/share/maven

# clone the Zeppelin incubator git repo into /zeppelin
RUN git clone  https://github.com/apache/incubator-zeppelin.git /zeppelin
WORKDIR /zeppelin/incubator-zeppelin
ENV ZEPPELIN_HOME /zeppelin/incubator-zeppelin
# build zeppelin
RUN mvn install -DskipTests -Dspark.version=1.2.0

# need to connect to spark server, set the proper IP address (SPARK_MASTER_IP_ADDR) and port (SPARK_MASTER_PORT - typically 7077)
export MASTER=spark://${SPARK_MASTER_IP_ADDR}:${SPARK_MASTER_PORT}

# once debugged, run the server - makes the container "read-only"
#RUN ./bin/zeppelin-daemon.sh start

#if interactive mode, kick off the bash
/bin/bash

# 8080 and 8081 are the web mgmt ports for zeppelin
EXPOSE 8080 8081