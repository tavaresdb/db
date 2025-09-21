# Utilitário mysqlshell
A função `util.dumpInstance()` permite realizar o dump de todos os bancos de dados, incluindo usuários:

```js
MySQL  JS > shell.connect("root@localhost:3306");

MySQL  localhost:3306 ssl  JS > util.dumpInstance("/tmp", {threads: 4});
```

> - Caso seja apresentada a mensagem `ERROR: definition uses DEFINER clause set to user user@localhost which can only be executed by this user or a user with SET_USER_ID or SUPER privileges (fix this with 'strip_definers' compatibility option)` ou `ERROR: definition does not use SQL SECURITY INVOKER characteristic, which is required (fix this with 'strip_definers' compatibility option)`, pode ser necessário alterar o usuário que irá realizar o dump ou adicionar no comando a opção `compatibility` com o valor `strip_definers`.

A função `util.dumpSchemas()` permite realizar o dump de um conjunto de bancos de dados:

```js
MySQL  localhost:3306 ssl  JS > util.dumpSchemas(["db1", "db2"], "/tmp", {threads: 4});
```

A função `util.dumpTables()` permite realizar o dump de um conjunto de tabelas e views específicas:

```js
MySQL  localhost:3306 ssl  JS > util.dumpTables("db1", ["tb1", "tb2"], "/tmp", {threads: 4});
```

A função `util.loadDump()` permite restaurar um dump em um banco de dados de destino:

```js
MySQL  localhost:3306 ssl  JS > util.loadDump("/tmp", {progressFile: "/tmp/restore.json", threads: 4});
```

Todas as etapas acima necessitam de armazenamento intermediário. Caso a transferência de dados deva ser direta e a versão do MySQL seja uma das mais recentes, considere as funções `util.copyInstance()`, `util.copySchemas()` e/ou `util.copyTables()`. Para maiores detalhes, consulte a [documentação oficial](https://dev.mysql.com/doc/mysql-shell/8.4/en/mysql-shell-utils-copy.html) ou [artigo](https://blogs.oracle.com/mysql/post/copy-data-directly-to-a-mysql-instance-with-mysql-shell).

# Referências
- https://dev.mysql.com/doc/mysql-shell/8.0/en/mysql-shell-utilities-dump-instance-schema.html
- https://dev.mysql.com/doc/mysql-shell/8.0/en/mysql-shell-utilities-load-dump.html