FROM ubuntu:latest AS base
MAINTAINER chaoheng
#curl is for gradlew
RUN apt-get update; apt-get install -y unzip openjdk-11-jdk wget curl
ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk-amd64
#(reference from docker hub gradle) install gradle and link
ENV GRADLE_HOME /opt/gradle
ENV GRADLE_VERSION 7.4.2
RUN wget --no-verbose --output-document=gradle.zip "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip"
RUN unzip gradle.zip \
	&& rm gradle.zip \
	&& mv "gradle-${GRADLE_VERSION}" "${GRADLE_HOME}/"\
	&& ln --symbolic "${GRADLE_HOME}/bin/gradle" /usr/bin/gradle \
	&& gradle --version
#build kafka src code
ENV KAFKA_VERSION 3.2.0
RUN wget -q http://mirror.vorboss.net/apache/kafka/${KAFKA_VERSION}/kafka-${KAFKA_VERSION}-src.tgz
RUN mkdir kafka
RUN tar xzf kafka-${KAFKA_VERSION}-src.tgz -C kafka
WORKDIR /kafka/kafka-${KAFKA_VERSION}-src
RUN gradle
RUN ./gradlew clean
RUN ./gradlew jar
#run zookeeper
CMD /kafka/kafka-3.2.0-src/bin/zookeeper-server-start.sh /kafka/kafka-3.2.0-src/config/zookeeper.properties