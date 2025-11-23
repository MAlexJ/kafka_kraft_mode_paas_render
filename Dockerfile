FROM amazoncorretto:21-alpine-jdk

ENV KAFKA_VERSION=4.1.1
ENV SCALA_VERSION=2.13

RUN apk add --no-cache curl tar bash busybox

RUN mkdir -p /opt/kafka \
    && curl -fsSL https://downloads.apache.org/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz \
    | tar -xzf - --strip-components=1 -C /opt/kafka

ENV KAFKA_ENABLE_KRAFT=yes
ENV KAFKA_CFG_NODE_ID=1
ENV KAFKA_CFG_PROCESS_ROLES=controller,broker
ENV KAFKA_CFG_CONTROLLER_QUORUM_VOTERS=1@0.0.0.0:9093
ENV KAFKA_CFG_LISTENERS=PLAINTEXT://:9092,CONTROLLER://:9093
ENV KAFKA_CFG_LISTENER_SECURITY_PROTOCOL_MAP=PLAINTEXT:PLAINTEXT,CONTROLLER:PLAINTEXT
ENV KAFKA_CFG_ADVERTISED_LISTENERS=PLAINTEXT://0.0.0.0:9092
ENV KAFKA_CFG_AUTO_CREATE_TOPICS_ENABLE=true
ENV KAFKA_CFG_LOG_DIRS=/var/lib/kafka/data
ENV KAFKA_CFG_METADATA_LOG_DIR=/var/lib/kafka/metadata

RUN mkdir -p /keepalive && echo "OK" > /keepalive/index.html

EXPOSE 9092 9093 8080

CMD busybox httpd -f -p 8080 -h /keepalive & \
    /opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/kraft/server.properties
