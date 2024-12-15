#!/bin/bash

echo "Iniciando validações para conexão Kerberos e Kafka..."

# Verifica se os arquivos necessários existem
if [ -f /etc/kafka-client/kafka_client_jaas.conf ]; then
    echo "Arquivo /etc/kafka-client/kafka_client_jaas.conf encontrado."
else
    echo "Erro: Arquivo kafka_client_jaas.conf não encontrado."
    exit 1
fi

if [ -f /etc/kafka-client/kafka_client_krb5.conf ]; then
    echo "Arquivo /etc/kafka-client/kafka_client_krb5.conf encontrado."
else
    echo "Erro: Arquivo kafka_client_krb5.conf não encontrado."
    exit 1
fi

if [ -f /etc/kafka-client/client.keytab ]; then
    echo "Arquivo /etc/kafka-client/client.keytab encontrado."
else
    echo "Erro: Arquivo client.keytab não encontrado."
    exit 1
fi

# Verifica a conexão com o KDC
KDC_HOSTNAME="kerberos-kdc"
KDC_PORT=88
KDC_IP=$(getent hosts $KDC_HOSTNAME | awk '{ print $1 }')

if [ -z "$KDC_IP" ]; then
    echo "Erro: Não foi possível resolver o hostname $KDC_HOSTNAME."
    echo "Substituindo o hostname pelo IP padrão: 192.168.208.2"
    KDC_IP="192.168.208.2"
fi

echo "Usando o IP do KDC: $KDC_IP"

echo "Testando conexão com o KDC em $KDC_IP:$KDC_PORT..."
if nc -z -w5 $KDC_IP $KDC_PORT; then
    echo "Conexão com KDC bem-sucedida."
else
    echo "Erro: Não foi possível conectar ao KDC em $KDC_IP:$KDC_PORT."
    exit 1
fi

# Substitui o hostname pelo IP no arquivo krb5.conf
sed -i "s/$KDC_HOSTNAME/$KDC_IP/g" /etc/kafka-client/kafka_client_krb5.conf
echo "Hostname $KDC_HOSTNAME substituído por $KDC_IP no kafka_client_krb5.conf."

# Verifica o conteúdo do arquivo keytab
# echo "Verificando o conteúdo do arquivo keytab..."
# klist -k /etc/kafka-client/client.keytab
# if [ $? -eq 0 ]; then
#     echo "Arquivo keytab válido."
# else
#     echo "Erro: Problema no arquivo keytab."
#     exit 1
# fi

# Exibe o conteúdo atualizado do krb5.conf
echo "Conteúdo atualizado do /etc/kafka-client/kafka_client_krb5.conf:"
cat /etc/kafka-client/kafka_client_krb5.conf

# Tenta rodar o kinit
echo "Tentando executar kinit..."
kinit -k -t /etc/kafka-client/client.keytab client/username@EXAMPLE.COM
if [ $? -eq 0 ]; then
    echo "kinit executado com sucesso."
else
    echo "Erro ao executar kinit. Verifique o arquivo keytab, o principal ou a configuração do Kerberos."
    exit 1
fi

# Continua com a configuração Kafka
echo "Criando tópico no Kafka..."
kafka-topics.sh --create --topic test-topic --bootstrap-server kafka-broker:9092 --partitions 1 --replication-factor 1 --command-config /etc/kafka-client/client.properties
if [ $? -eq 0 ]; then
    echo "Tópico criado com sucesso."
else
    echo "Erro ao criar o tópico no Kafka."
    exit 1
fi

echo "Produzindo mensagem no tópico..."
echo "Mensagem de teste" | kafka-console-producer.sh --topic test-topic --bootstrap-server kafka-broker:9092 --producer.config /etc/kafka-client/client.properties

echo "Consumindo mensagem do tópico..."
kafka-console-consumer.sh --topic test-topic --bootstrap-server kafka-broker:9092 --from-beginning --consumer.config /etc/kafka-client/client.properties
