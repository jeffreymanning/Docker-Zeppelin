FROM centos:centos7

MAINTAINER JeffM

# prerequisites
RUN yum -y clean all
RUN yum -y update
RUN yum install -y \
  bzip2 \
  git \
  java-1.7.0-openjdk \
  java-1.7.0-openjdk-devel \
  npm \
  node \
  tar \
  unzip \
  hostname \
  net-tools 
 
# need minimum of maven 3.3.1, latest is 3.3.3 as of 5/5/2015 - Cinco De Mayo!!
ENV MAVEN_VERSION 3.3.3
RUN \
  curl -sSL http://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.zip -o apache-maven-$MAVEN_VERSION-bin.zip && \
  unzip apache-maven-$MAVEN_VERSION-bin.zip && \ 
  mv apache-maven-$MAVEN_VERSION /usr/share/maven && \
  ln -s /usr/share/maven/bin/mvn /usr/bin/mvn
ENV MAVEN_HOME /usr/share/maven

# clone the Zeppelin incubator git repo into /zeppelin
RUN git clone  https://github.com/apache/incubator-zeppelin.git /zeppelin
WORKDIR /zeppelin
ENV ZEPPELIN_HOME /zeppelin
ENV ZEPPELIN_CONF $ZEPPELIN_HOME/conf


# build zeppelin
#RUN mvn clean package -Pspark-1.2 -Dhadoop.version=2.2.0 -Phadoop-2.2 -DskipTests
#RUN mvn clean package -Pspark.version=1.2 -DskipTests
#RUN mvn clean package -DskipTests
# build for cluster mode
#RUN mvn install -DskipTests -Dspark.version=1.3.0 -Dhadoop.version=2.6.0
# RUN mvn install -DskipTests -Dspark.version=1.3.0
RUN mvn install -DskipTests -Pspark-1.3 -Phadoop-2.6
# need to connect to spark server, set the proper IP address (SPARK_MASTER_IP_ADDR) and port (SPARK_MASTER_PORT - typically 7077)

ENV SPARK_MASTER_IP_ADDR 172.20.1.103
ENV SPARK_MASTER_PORT 7077
ENV MASTER=spark://${SPARK_MASTER_IP_ADDR}:${SPARK_MASTER_PORT}

# once debugged, run the server - makes the container "read-only"
#RUN ./bin/zeppelin-daemon.sh start



# 8080 and 8081 are the web mgmt ports for zeppelin
EXPOSE 8080 8081


CMD ["/bin/bash"]
