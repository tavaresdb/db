# Utilitário mysqldump

## Dump completo
```bash
mysqldump -uroot -p --all-databases --triggers --routines --events > dump.sql
```

> - Por padrão, triggers são despejados no arquivo, mesmo que a opção não seja especificada. Caso não haja interesse em despejar triggers, especifique a opção `--skip-triggers`.
> - Como o MySQL suporta motores não transacionais, por padrão é imposto bloqueio nas gravações, garantindo consistência no dump dos bancos de dados. Pode ser necessário adotar a opção `--single-transaction` ao despejar objetos transacionais, tornando o dump mais suave, entretanto ao decorrer do processo instruções DDL não deverão ser emitidas.
> - Caso necessite recuperar no arquivo informações sobre o binary log e sua posição, emita no dump a opção `--source-data=2`. Agora, caso lide com GTIDs (Global Transaction Identifier), atente-se a [essa](https://github.com/tavaresdb/db/blob/main/mysql/07_backup/01_logical/02_mysqldump.md#informa%C3%A7%C3%B5es-complementares) observação.
> - Caso haja interesse em compactar o arquivo, considere esse exemplo: `mysqldump -uroot -p --all-databases --routines --events | gzip > dump.sql.gz`.

## Dump do banco de dados
```bash
mysqldump -uroot -p sakila > /tmp/sakila_data.sql
mysqldump -uroot -p --no-data sakila > /tmp/sakila_nodata.sql
```

## Dump da tabela
```bash
mysqldump -uroot -p sakila category > /tmp/tbl_category.sql
mysqldump -uroot -p sakila actor --where="actor_id > 195" > /tmp/tbl_actor.sql
```

## Restauração completa
```bash
mysql -uroot -p < dump.sql
```

## Restauração do banco de dados
```bash
mysql -uroot -p -e "CREATE DATABASE sakila_tmp"
mysql -uroot -p sakila_tmp < /tmp/sakila_data.sql
```

## Dump, transmissão do arquivo pela rede e restauração em outro servidor
O dump abaixo contará com as seguintes opções:

- `nice -5`: Irá aumentar a prioridade de CPU do processo (Prioridade mais alta).
- `--all-databases`: Exportará todos os bancos de dados.
- `--single-transaction`: Garantirá consistência do despejo (Útil para InnoDB).
- `--routines`: Incluirá stored procedures e functions.
- `--events`: Incluirá eventos do agendador de eventos.
- `--source-data=2`: Irá inserir um comentário no dump com o arquivo/posição do binary log atual, necessário para iniciar a replicação a partir dessa posição.
- `--flush-logs`: Forçará a rotação do binary log antes do dump (Gerará novo binary log).
- `--log-error=/tmp/donor.log`: Os erros do `mysqldump` serão registrados nesse arquivo.
- `--verbose=TRUE`: Exibirá os detalhes do processo.

Por fim o dump será transmitido para o outro servidor via SSH, onde será processado imediatamente pela outra instância MySQL, ou seja, os dados são importados diretamente sem a necessidade de mantê-los localmente, visto que a saída é redirecionada em um arquivo.

```bash
mysql -uroot -p -e "SHOW BINARY LOG STATUS\G" && nice -5 mysqldump -uroot -p --all-databases --single-transaction --routines --events --source-data=2 --flush-logs --log-error=/tmp/donor.log --verbose=TRUE | ssh mysql@destination_ip_address mysql -uroot -p 1> /tmp/receiver.log 2>&1
```

## Informações complementares
A opção `--set-gtid-purged` controla a inclusão da instrução `SET @@GLOBAL.gtid_purged` no dump, utilizada em replicações com GTID. Essa instrução ajusta o `gtid_purged` no servidor de destino para refletir os GTIDs aplicados no servidor de origem, garantindo consistência entre eles. O valor padrão é `AUTO`, podendo ser configurado como `OFF`, `ON` ou `COMMENTED`. É importante ter cautela ao usar essa opção em dumps parciais, pois podem ser incluídos GTIDs que não correspondem a dados realmente exportados, dificultando comparações entre servidores ou ocasionando falhas em restaurações subsequentes, como esta: `@@GLOBAL.GTID_PURGED cannot be changed: the added gtid set must not overlap with @@GLOBAL.GTID_EXECUTED`.

# Referência
- Livro Learning MySQL: Get a Handle on Your Data (2nd Edition), por Vinicius M Grippa e Sergey Kuzmichev - Pg. 88; 625-637
- https://dev.mysql.com/doc/refman/8.0/en/mysqldump.html#option_mysqldump_set-gtid-purged