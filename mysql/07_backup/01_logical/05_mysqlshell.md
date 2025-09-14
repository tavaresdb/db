# Utilitário mysqlshell
A função `util.dumpInstance()` permite despejar todos os banco de dados, incluindo usuários:

```js
MySQL  JS > shell.connect("root@localhost:3306");
MySQL  localhost:3306 ssl  JS > util.dumpInstance("/tmp", {ocimds: true, compatibility: ["strip_restricted_grants"], dryRun: true});
```

> - Ao definir a opção `ocimds` como `true`, as opções `DATA DIRECTORY`, `INDEX DIRECTORY` e `ENCRYPTION` nas instruções `CREATE TABLE` serão comentadas no arquivo despejado, para garantir que todas as tabelas estejam localizadas no diretório de dados do MySQL e usem a criptografia padrão. Também serão realizadas verificações para quaisquer mecanismos de armazenamento em instruções `CREATE TABLE` diferentes do InnoDB, para concessões de priviégios inadequados a usuários ou roles e para outros problemas de compatibilidade. Se alguma instrução SQL não conforme for gerada, uma exceção será gerada e o dump será interrompido. Consequentemente é recomendável definir a opção `dryRun` como `true`, pois o utilitário realizará apenas a validação e nenhum dado será despejado. Quanto a opção `strip_restricted_grants`, a mesma remove privilégios específicos restritos pelo serviço HeatWave das instruções `GRANT`, para que usuários e roles não recebam esse tipo de priviégio (Evitando assim a falha na criação do usuário). Essa opção também remove instruções `REVOKE` para bancos de dados de sistema (`mysql` e `sys`) se a conta de usuário administrativa em uma instância da OCI não tiver privilégios relevantes e, portanto, não puder removê-los.
>
> - Caso seja apresentada a mensagem `"ERROR: definition uses DEFINER clause set to user user@localhost which can only be executed by this user or a user with SET_USER_ID or SUPER privileges (fix this with 'strip_definers' compatibility option)"` ou `"ERROR: definition does not use SQL SECURITY INVOKER characteristic, which is required (fix this with 'strip_definers' compatibility option)"`, pode ser necessário alterar o usuário que irá realizar o despejo ou adicionar em compatibility a opção `strip_definers`. A opção `strip_definers` removerá a cláusula `DEFINER` de views, routines, events e triggers, para que esses objetos sejam criados com o definidor padrão (O usuário que invoca o banco de dados) e alterará a cláusula `SQL SECURITY` para views e routines para especificar `INVOKER` em vez de `DEFINER`.

A versão final ficará da seguinte forma (Podendo ser ajustado conforme necessidade):
```js
MySQL  localhost:3306 ssl  JS > util.dumpInstance("/tmp", {ocimds: true, compatibility: ["strip_restricted_grants", "force_innodb"], threads: 4});
```

A função `util.dumpSchemas()` permite despejar um conjunto de bancos de dados:

```js
MySQL  localhost:3306 ssl  JS > util.dumpSchemas(["db1", "db2"], "/tmp", {ocimds: true, compatibility: ["strip_restricted_grants", "force_innodb"], threads: 4});
```

A função `util.dumpTables()` permite despejar um conjunto de tabelas e views específicas:

```js
MySQL  localhost:3306 ssl  JS > util.dumpTables("db1", ["tb1", "tb2"], "/tmp", {ocimds: true, compatibility: ["strip_restricted_grants", "force_innodb"], threads: 4});
```

A função `util.loadDump()` permite restaurar um dump em um banco de dados de destino:

```js
MySQL  localhost:3306 ssl  JS > util.loadDump("/tmp", {progressFile: "/tmp/restore.json", threads: 4});
```

Todas as etapas acima necessitam de armazenamento intermediário. Caso a transferência de dados deva ser direta e a versão do MySQL seja uma das mais recentes, considere as funções `util.copyInstance()`, `util.copySchemas()` e/ou `util.copyTables()`. Para maiores detalhes, consulte a [documentação oficial](https://dev.mysql.com/doc/mysql-shell/8.4/en/mysql-shell-utils-copy.html) ou [artigo](https://blogs.oracle.com/mysql/post/copy-data-directly-to-a-mysql-instance-with-mysql-shell).

# Referências
- https://dev.mysql.com/doc/mysql-shell/8.0/en/mysql-shell-utilities-dump-instance-schema.html
- https://dev.mysql.com/doc/mysql-shell/8.0/en/mysql-shell-utilities-load-dump.html