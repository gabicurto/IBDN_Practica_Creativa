# ZooKeeper

FROM openjdk:8-jdk
WORKDIR /main

RUN apt-get update && \
    apt-get upgrade -y && \
    apt install -y nano python3

# ZooKeeper
RUN wget https://archive.apache.org/dist/zookeeper/zookeeper-3.8.1/apache-zookeeper-3.8.1-bin.tar.gz && \
    tar -xvzf apache-zookeeper-3.8.1-bin.tar.gz && \
    rm apache-zookeeper-3.8.1-bin.tar.gz

# Kafka
RUN wget https://archive.apache.org/dist/kafka/3.4.0/kafka_2.12-3.4.0.tgz && \
    tar -xzf kafka_2.12-3.4.0.tgz && \
    rm kafka_2.12-3.4.0.tgz

# Cloning repository with data and trained models
RUN apt-get install git -y && \
    git clone https://github.com/Big-Data-ETSIT/practica_creativa && \
    mv practica_creativa/* . && \
    rm -r practica_creativa

# Start ZooKeeper
WORKDIR /main/kafka_2.12-3.4.0
CMD ./bin/kafka-topics.sh --create --bootstrap-server localhost:9092 --replication-factor 1 --partitions 1 --topic flight_delay_classification_request --if-not-exists && \
    sleep 123456789