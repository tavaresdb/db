# Utilitário mysqlpump
Utilitário empacotado com as versões 5.7 e posterior que melhora o `mysqldump` em várias áreas, principalmente em torno de desempenho e usabilidade, entretanto o mesmo é obsoleto a partir da versão 8.0.34 e tende a ser removido em versões futuras.

```bash
# Exemplo
mysqlpump -uroot -p --compress-output=zlib --include-databases=sakila,db1,db2 --parallel-schemas=4:db1,db2 --default-parallelism=2 > pump.out

zlib_decompress pump.out pump.sql

mysql -uroot -p < pump.sql
```

> - Diferente do `mysqldump`, o comportamento padrão do `mysqlpump` é realizar o backup de todos os bancos de dados, exceto se especificarmos os desejados, conforme tutorial acima.
> - Bancos de dados internos não são incluídos, tais como `performance_schema`, `information_schema` e `sys`. Para incluí-los, é necessário especificar a opção `--databases` ou `--include-databases`.
> - O `mysqlpump` exporta usuários com comandos `CREATE USER` e `GRANT`, em vez de `INSERT` no banco de dados `mysql`, mas esses comandos podem ser omitidos se as opções `--include-users` ou `--users` forem especificadas.

# Referências
- Curso MySQL 8.0 for Database Administrators, https://mylearn.oracle.com/ou/course/mysql-80-for-database-administrators/76889
- Livro Learning MySQL: Get a Handle on Your Data (2nd Edition), por Vinicius M Grippa e Sergey Kuzmichev - Pg. 637-640