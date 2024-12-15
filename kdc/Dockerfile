FROM debian:latest

# Instala pacotes do Kerberos
RUN apt-get update && apt-get install -y \
    krb5-kdc \
    krb5-admin-server \
    krb5-config && \
    apt-get clean

# Define permissões padrão para evitar problemas
RUN mkdir -p /etc/krb5kdc && \
    chmod 755 /etc/krb5kdc

# Copie os arquivos de configuração para o contêiner
COPY krb5.conf /etc/krb5.conf
COPY kdc.conf /etc/krb5kdc/kdc.conf
COPY kadm5.acl /etc/krb5kdc/kadm5.acl
COPY init-kdc.sh /etc/krb5kdc/init-kdc.sh

# Certifique-se de que o script init-kdc.sh é executável
RUN chmod +x /etc/krb5kdc/init-kdc.sh

# Certifique-se de que os arquivos de configuração têm permissões corretas
RUN chmod 644 /etc/krb5.conf /etc/krb5kdc/kdc.conf /etc/krb5kdc/kadm5.acl

# Comando de inicialização
CMD ["/etc/krb5kdc/init-kdc.sh"]
