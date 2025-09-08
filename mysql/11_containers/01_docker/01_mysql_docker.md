# Provisionando o MySQL no Docker
Para instalar o Docker, siga as instruções [desse](https://github.com/tavaresdb/devops/blob/main/docker/install/install.md) tutorial. Quanto ao uso do MySQL no Docker, pra fins de testes, segue um exemplo:

```bash
# Provisionamento do MySQL
docker run --name mysql-latest \
-p 3306:3306 -p 33060:33060 \
-e MYSQL_ROOT_HOST=% -e MYSQL_ROOT_PASSWORD='learning_mysql' \
-d mysql/mysql-server:latest

# Conexão com o container MySQL
docker exec -it mysql-latest mysql -uroot -plearning_mysql

# Interrupção e inicialização do MySQL
docker stop mysql-latest
docker start mysql-latest

# Análise de logs
docker logs mysql-latest

# Remoção do container MySQL
docker stop mysql-latest
docker rm mysql-latest

# Checagem dos containers em execução
docker ps

# Implantação do MySQL com parâmetros customizados
docker run --name mysql-latest \
-p 3306:3306 -p 33060:33060 \
-e MYSQL_ROOT_HOST=% -e MYSQL_ROOT_PASSWORD='learning_mysql' \
-d mysql/mysql-server:latest \
--innodb_buffer_pool_size=256M \
--innodb_flush_method=0_DIRECT

# Implantação do MySQL com uma versão especifica (Obs.: Avaliar disponibilidade em https://hub.docker.com)
docker run --name mysql-5.7.31 \
-p 3307:3306 -p 33061:33060 \
-e MYSQL_ROOT_HOST=% -e MYSQL_ROOT_PASSWORD='learning_mysql' \
-d mysql/mysql-server:5.7.31

docker exec -it mysql-5.7.31 mysql -uroot -plearning_mysql

# Implantação de outras distribuições do MySQL
docker run --name maria-latest \
-p 3308:3306 \
-e MYSQL_ROOT_HOST=% -e MYSQL_ROOT_PASSWORD='learning_mysql' \
-d mariadb:latest

docker run --name ps-latest \
-p 3309:3306 -p 33063:33060 \
-e MYSQL_ROOT_HOST=% -e MYSQL_ROOT_PASSWORD='learning_mysql' \
-d percona/percona-server:latest \
--innodb_buffer_pool_size=256M \
--innodb_flush_method=0_DIRECT
```

# Referência
- Livro Learning MySQL: Get a Handle on Your Data (2nd Edition), por Vinicius M Grippa e Sergey Kuzmichev - Pg. 93-96