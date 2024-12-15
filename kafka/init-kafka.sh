#!/bin/bash

export KAFKA_OPTS="-Djava.security.auth.login.config=/etc/kafka/kafka_server_jaas.conf"
kafka-server-start /etc/kafka/server.properties
