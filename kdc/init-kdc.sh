#!/bin/bash

# Inicializa o banco de dados do KDC
krb5_newrealm <<EOF
adminpassword
adminpassword
EOF

# Ajusta permissões do arquivo stash para evitar erros
chmod 644 /etc/krb5kdc/stash

# Cria os principais necessários
kadmin.local <<EOF
addprinc -randkey kafka/broker-host@EXAMPLE.COM
addprinc -randkey client/username@EXAMPLE.COM
ktadd -k /etc/krb5kdc/kafka_broker.keytab kafka/broker-host@EXAMPLE.COM
ktadd -k /etc/krb5kdc/client.keytab client/username@EXAMPLE.COM
EOF

# Copia keytabs para volumes compartilhados
mkdir -p /etc/krb5kdc/output/
cp /etc/krb5kdc/*.keytab /etc/krb5kdc/output/

# Ajusta permissões para que outros contêineres possam acessar os keytabs
chmod 644 /etc/krb5kdc/output/*.keytab

# Inicia os serviços do KDC
krb5kdc
kadmind -nofork
