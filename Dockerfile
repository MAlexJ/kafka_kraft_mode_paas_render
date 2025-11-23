FROM amazoncorretto:21-alpine-jdk

RUN apk add --no-cache curl tar bash python3 util-linux

ENV KAFKA_VERSION=4.1.1
ENV SCALA_VERSION=2.13

RUN mkdir -p /opt/kafka \
  && curl -fsSL https://downloads.apache.org/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz \
  | tar -xzf - --strip-components=1 -C /opt/kafka

RUN mkdir -p /opt/kafka/config/kraft && \
    cat <<EOF > /opt/kafka/config/kraft/server.properties
process.roles=broker,controller
node.id=1
controller.quorum.voters=1@0.0.0.0:9093
listeners=PLAINTEXT://:9092,CONTROLLER://:9093
listener.security.protocol.map=PLAINTEXT:PLAINTEXT,CONTROLLER:PLAINTEXT
log.dirs=/var/lib/kafka/data
metadata.log.dir=/var/lib/kafka/metadata
auto.create.topics.enable=true
advertised.listeners=PLAINTEXT://0.0.0.0:9092
EOF

RUN mkdir -p /var/lib/kafka/data /var/lib/kafka/metadata

# Задаём фиксированный UUID для KRaft storage
ENV KAFKA_CLUSTER_ID=3f7d8c1f-5e47-4f12-8b2e-0a1c2d3e4f5b
RUN /opt/kafka/bin/kafka-storage.sh format -t $KAFKA_CLUSTER_ID -c /opt/kafka/config/kraft/server.properties

# Keep-alive
RUN mkdir -p /keepalive && echo "OK" > /keepalive/index.html

EXPOSE 8080 9092 9093

CMD python3 -m http.server 8080 & \
    /opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/kraft/server.properties
