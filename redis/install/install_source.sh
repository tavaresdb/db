#!/usr/bin/env bash

# Pré-requisitos
apt-get update
apt-get install wget build-essential tcl-tls libssl-dev -y

# Criação de um usuário e um grupo dedicado e sem privilégios
adduser --system --group --no-create-home redis

# Criação do diretório de dados
mkdir /var/lib/redis
chown redis:redis /var/lib/redis
chmod 770 /var/lib/redis

# Criação do diretório de log
mkdir /var/log/redis
touch /var/log/redis/redis.log
chown -R redis:redis /var/log/redis/
chmod 660 /var/log/redis
chmod 640 /var/log/redis/redis.log

# Instalação do Redis
cd /tmp
wget http://download.redis.io/releases/redis-6.0.5.tar.gz
sha256sum redis-6.0.5.tar.gz

# Obs. 1: A saída do comando acima reproduzirá o seguinte resultado: 42cf86a114d2a451b898fcda96acd4d01062a7dbaaad2801d9164a36f898f596 redis-6.0.5.tar.gz
# Obs. 2: Compare o resultado com o repositório https://github.com/redis/redis-hashes, garantindo a integridade do arquivo

tar -xzvf redis-6.0.5.tar.gz
cd ./redis-6.0.5
make BUILD_TLS=yes install

# Obs.: Ao compilar o Redis com BUILD_TLS será possível a implementação do TLS no Redis

# Criação do diretório de arquivo de configuração
mkdir /etc/redis
cp redis.conf /etc/redis
touch /etc/redis/users.acl
chown -R redis:redis /etc/redis
chmod 640 /etc/redis/redis.conf
chmod 640 /etc/redis/users.acl

# Obs.: A criação do arquivo users.acl é opcional, entretanto é uma boa prática gerenciar as ACLs através de um arquivo de configuração

# Instalação de ferramentas para gerenciar o Redis
apt-get install install redis-tools -y