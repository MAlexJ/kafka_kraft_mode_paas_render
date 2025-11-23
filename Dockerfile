# ------------------------------
# Base image: Amazon Corretto 21 Alpine
# ------------------------------
FROM amazoncorretto:21-alpine-jdk

# ------------------------------
# Install required tools
# ------------------------------
RUN apk add --no-cache curl tar bash python3

# ------------------------------
# Download and extract Kafka 4.1.1
# ------------------------------
ENV KAFKA_VERSION=4.1.1
ENV SCALA_VERSION=2.13
RUN mkdir -p /opt/kafka \
    && curl -fsSL https://downloads.apache.org/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz \
    | tar -xzf - --strip-components=1 -C /opt/kafka

# ------------------------------
# Configure KRaft single-node
# ------------------------------
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

# ------------------------------
# Initialize KRaft storage
# ------------------------------
RUN mkdir -p /var/lib/kafka/data /var/lib/kafka/metadata
RUN /opt/kafka/bin/kafka-storage.sh format -t $(uuidgen) -c /opt/kafka/config/kraft/server.properties

# ------------------------------
# Keep-alive HTTP server
# ------------------------------
RUN mkdir -p /keepalive && echo "OK" > /keepalive/index.html

EXPOSE 8080 9092 9093

# ------------------------------
# Start keep-alive + Kafka
# ------------------------------
CMD python3 -m http.server 8080 & \
    /opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/kraft/server.properties
