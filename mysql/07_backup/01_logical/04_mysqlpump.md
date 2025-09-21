# Utilitário mysqlpump
Utilitário empacotado com as versões 5.7 e posterior que melhora o `mysqldump` em várias áreas, principalmente em torno de desempenho e usabilidade, entretanto o mesmo é obsoleto a partir da versão 8.0.34 e tende a ser removido em versões futuras.

```bash
# Exemplo
mysqlpump -uroot -p --compress-output=zlib --include-databases=sakila,db1,db2 --parallel-schemas=4:db1,db2 --default-parallelism=2 > pump.out

zlib_decompress pump.out pump.sql

mysql -uroot -p < pump.sql
```

# Referências
- Livro Learning MySQL: Get a Handle on Your Data (2nd Edition), por Vinicius M Grippa e Sergey Kuzmichev - Pg. 637-640