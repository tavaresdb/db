# Usuários e privilégios
Essa seção aborda algumas informações e exemplos sobre gerenciamento de usuários e privilégios no MySQL.

## Tabelas de concessão
O MySQL lê as tabelas de concessão do banco de dados `mysql` para a memória durante a inicialização e baseia todas as decisões de controle de acesso nessas tabelas. As tabelas correspondem aos seguintes níveis de privilégio:

|Nome da tabela   |Conteúdo e privilégios                                  |
|-----------------|--------------------------------------------------------|
|user             |Contas de usuários, roles e privilégios em nível global |
|global_grants    |Privilégios globais dinâmicos                           |
|db               |Privilégios em nível de banco de dados                  |
|tables_priv      |Privilégios em nível de tabela                          |
|columns_priv     |Privilégios em nível de coluna                          |
|procs_priv       |Privilégios de stored procedures e functions            |
|proxies_priv     |Priviégios de usuários proxy                            |
|default_roles    |Roles padrão dos usuários                               |
|role_edges       |Roles atribuídas a usuários e outras roles              |
|password_history |Histórico de alterações de senha                        |

> Evite modificar o conteúdo dessas tabelas, pois erros podem impedir o acesso a instância. Se por ventura houver um cenário de exceção, onde necessite ajustar algum valor, lembre-se de recarregá-las explicitamente utilizando o comando `FLUSH PRIVILEGES`. Ao emitir comandos como `GRANT`, `REVOKE`, `SET PASSWORD` e `RENAME USER`, não há necessidade de executar o comando `FLUSH PRIVILEGES`, visto que automaticamente as alterações são feitas nas tabelas e nas cópias em memória.

## Exemplos

### Criação de usuários
Nesse primeiro exemplo, utilizando o plugin depreciado `mysql_native_password` para autenticação nativa baseada em hash de senha, o usuário **bob** é criado. A ele é atribuída a role padrão **user_role** e sua conexão exige SSL com uma cifra específica, além de limitar o uso de recursos. A expiração de senha para este usuário parmanece desativada.

```sql
CREATE USER IF NOT EXISTS 'bob'@'10.0.2.%'
IDENTIFIED WITH mysql_native_password BY 'P@ssw0rd!'
DEFAULT ROLE 'user_role'
REQUIRE SSL
AND CIPHER 'EDH-RSA-DES-CBC3-SHA'
WITH MAX_QUERIES_PER_HOUR 10
MAX_CONNECTIONS_PER_HOUR 2
MAX_USER_CONNECTIONS 1
PASSWORD EXPIRE NEVER;
```

Nesse segundo exemplo é criado o usuário **john**, entretanto a autenticação não será baseada em senha, mas sim em um certificado digital.

```sql
CREATE USER IF NOT EXISTS 'john'@'192.168.%'
REQUIRE SUBJECT = '/C=US/ST=NC/L=Durham/O=BI Dept certificate/CN=client/emailAddress=john@nonexistent.com'
AND ISSUER '/C=US/ST=NC/L=Durham/O=MySQL/CN=CA/emailAddress=ca@nonexistent.com'
AND CIPHER 'EDH-RSA-DES-CBC3-SHA';
```

E nesse terceiro exemplo é criado o usuário **app_admin**, que contará com algumas políticas de segurança, como a expiração de senha a cada 30 dias, a proibição de reutilização de senhas nos últimos 180 dias, a exigência da senha atual para alteração, o bloqueio da conta após 3 tentativas de login com falha e um tempo de bloqueio de 1 dia.

```sql
CREATE USER IF NOT EXISTS 'app_admin'@'192.168.%' IDENTIFY BY 'P@ssw0rd!' WITH PASSWORD EXPIRE INTERVAL 30 DAY
PASSWORD REUSE INTERVAL 180 DAY
PASSWORD REQUIRE CURRENT
FAILED_LOGIN_ATTEMPTS 3
PASSWORD_LOCK_TIME 1;
```

### Bloqueio de usuário
```sql
ALTER USER 'bob'@'10.0.2.%' ACCOUNT LOCK;
```

### Desbloqueio de usuário
```sql
ALTER USER 'bob'@'10.0.2.%' ACCOUNT UNLOCK;
```

### Concessão e remoção de privilégios
```sql
GRANT USAGE ON app_db.* TO 'john'@'192.168.%';
GRANT USAGE ON other_db.* TO 'john'@'192.168.%';

GRANT SELECT(id, data), INSERT(id, data) ON app_db.table_name TO 'john'@'192.168.%';

GRANT SELECT ON other_db.* TO 'john'@'192.168.%';
REVOKE SELECT ON other_db.* FROM 'john'@'192.168.%';

GRANT ALL ON other_db.* TO 'john'@'192.168.%';
REVOKE ALL ON other_db.* FROM 'john'@'192.168.%';

REVOKE ALL ON *.* FROM 'john'@'192.168.%';
```

### Avaliação de privilégios
```sql
SHOW GRANTS FOR 'john'@'192.168.%';
```

### Alteração de senha do usuário root e inicialização insegura
```bash
systemctl stop mysqld

cat /etc/my.cnf
# SERVER SECTION
# ----------------------------------------------------------------------
#
# The following options will be read by the MySQL Server. Make sure that
# you have installed the server correctly (see above) so it reads this 
# file.
[mysqld]
skip-grant-tables

systemctl start mysqld
mysql
```
```sql
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY 'P@ssw0rd!';
```
```bash
systemctl stop mysqld
cat /etc/my.cnf

# SERVER SECTION
# ----------------------------------------------------------------------
#
# The following options will be read by the MySQL Server. Make sure that
# you have installed the server correctly (see above) so it reads this 
# file.
[mysqld]
# skip-grant-tables

systemctl start mysqld
mysql -uroot -p
```

# Referências
- Curso MySQL 8.0 for Database Administrators, https://mylearn.oracle.com/ou/course/mysql-80-for-database-administrators/76889
- Livro Learning MySQL: Get a Handle on Your Data (2nd Edition), por Vinicius M Grippa e Sergey Kuzmichev - Pg. 517-539; 580-583