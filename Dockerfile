FROM apache/kafka:4.1.1

# ------------------------------
#   KRaft Single-Node Settings
# ------------------------------
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

# ------------------------------
#   Keep-alive HTTP Server
# ------------------------------
USER root
RUN apt-get update && apt-get install -y busybox && apt-get clean
RUN mkdir -p /keepalive && echo "OK" > /keepalive/index.html

EXPOSE 9092 9093 8080

CMD busybox httpd -f -p 8080 -h /keepalive & \
    /bin/sh -c "/opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/server.properties"
