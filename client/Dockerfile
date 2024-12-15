FROM openjdk:11-slim

# Instala pacotes necessários
RUN apt-get update && apt-get install -y \
    krb5-user \
    curl \
    jq \
    dnsutils \
    net-tools \
    netcat \
    && rm -rf /var/lib/apt/lists/*

# Baixa e descompacta o Kafka
ENV KAFKA_VERSION=3.5.1
ENV SCALA_VERSION=2.13
RUN curl -fSL "https://archive.apache.org/dist/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz" | tar -xzf - -C /opt \
 || (echo "Falha no download do Kafka. Verifique a URL ou versão." && exit 1)

RUN mv /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION} /opt/kafka

# Adiciona o Kafka ao PATH
ENV PATH=$PATH:/opt/kafka/bin

# Copia os arquivos necessários
COPY . /etc/kafka-client/

RUN chmod +x /etc/kafka-client/init-client.sh

# Baixa o script wait-for-it diretamente do GitHub
RUN curl -fSL https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh -o /usr/local/bin/wait-for-it && \
    chmod +x /usr/local/bin/wait-for-it

ENTRYPOINT ["wait-for-it", "kafka-broker:9092", "--", "/etc/kafka-client/init-client.sh"]
