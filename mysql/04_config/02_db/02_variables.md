# innodb_buffer_pool_size
A variável `innodb_buffer_pool_size` controla o tamaho em bytes do buffer pool do InnoDB, a área de memória onde o InnoDB armazena os dados de tabelas e índices. Esta é a variável mais importante do InnoDB. Uma boa regra é definir o valor em torno de 80% do total da memória RAM de um servidor dedicado, entretanto considere sempre a capacidade do seu servidor, evitanto desperídicio para servidores com maior capacidade ou risco para servidores com menor capacidade. No geral, defina a variável `innodb_buffer_pool_size` com o maior valor possível, sem causar swappiness quando o sistema estiver executando a carga de trabalho de produção. Para maiores detalhes sobre o buffer pool, consulte [esse](https://github.com/tavaresdb/db/blob/main/mysql/01_architecture/02_innodb.md#buffer-pool) artigo.

> Se a variável `max_connections` for configurada com 5000 conexões simultâneas, pode ser uma boa adequar a variável `innodb_buffer_pool_size`, como por exemplo 50% do total da memória RAM de um servidor dedicado. Se 1000 conexões simultâneas, entre 60% e 70%. Se 151 conexões simultâneas, entre 70% e 80%.

# innodb_buffer_pool_instances
Habilitar múltiplas instâncias do buffer pool permite reduzir a contenção ao acessar a memória. Automaticamente o InnoDB cria múltiplas instâncias quando o buffer pool ultrapassa 1 GB. A variável pode ser ajustada manualmente e é importante garantir que cada instância use pelo menos 1 GB.

> Um mutex é usado para evitar acessos simultâneos concorrentes a memória. O InnoDB usa um mutex por instância do buffer pool para proteger os acessos as páginas de dados. Se você tiver muitas conexões simultâneas e um buffer pool grande, é recomendável usar múltiplas instâncias para reduzir a chance de contenção.

# innodb_log_file_size
O redo log é uma estrutura usada durante o processo de recuperação para corrigir dados escritos por transações incompletas. O objetivo principal é garantir a durabilidade, proporcionando a recuperação de refazer para transações confirmadas. Como o redo log registra todos os dados gravados no MySQL mesmo antes do `COMMIT`, ter o tamanho certo de redo log é fundamental para que o MySQL funcione corretamente. Um redo log subdimensionado pode até levar a erros nas operações. Para estimar o melhor valor para a variável `innodb_log_file_size`, realize o seguinte procedimento:

```sql
SHOW GLOBAL STATUS LIKE 'Innodb_os_log_written';
SELECT SLEEP(60);
SHOW GLOBAL STATUS LIKE 'Innodb_os_log_written';
SELECT (((3838334638 - 3836410803) / 1024 / 1024) * 60) / 2 AS 'estimated_innodb_log_file_size'; -- A divisão foi por 2, pois por padrão são criados dois arquivos de redo log
```

> Para maiores detalhes sobre o redo log, consulte [esse](https://github.com/tavaresdb/db/blob/main/mysql/01_architecture/02_innodb.md#redo) artigo.

# sync_binlog
Essa variável controlará a frequência com que o MySQL sincronizará o binary log para o disco.

- `sync_binlog = 0`: Desabilita a sincronização do binary log para o disco pelo MySQL. Em vez disso, o MySQL dependerá do sistema operacional para liberar o binary log para o disco de tempos em tempos, como faz para qualquer outro arquivo. Essa configuração fornece o melhor desempenho, mas no caso de uma falha de energia ou falha do sistema operacional é possível que o servidor tenha confirmado transações que não foram sincronizadas com o binary log.

- `sync_binlog = 1`: Habilita a sincronização do binary log para o disco antes que as transações sejam confirmadas. Essa é a configuração mais segura, mas pode ter um impacto negativo no desempenho devido ao aumento do número de gravações em disco. No caso de uma falha de energia ou falha do sistema operacional, as transações que estão faltando no binary log estão apenas em um estado preparado. Isso permite que a rotina de recuperação automática reverta as transações, o que garante que nenhuma transação seja perdida do binary log.

- `sync_binlog = N`, em que N é um valor diferente de 0 ou 1: O binary log é sincronizado com o disco após as N coletas dos grupos de confirmação do binary log. No caso de uma falha de energia ou falha do sistema operacional, é possível que o servidor tenha confirmado transações que não foram liberadas para o binary log. Essa configuração pode ter um impacto negativo no desempenho devido ao aumento do número de gravações em disco. Um valor mais alto melhora o desempenho, mas aumenta o risco de perda de dados.

> Para obter a maior durabilidade e consistência possíveis, considere essa configuração: `sync_binlog = 1` e `innodb_flush_log_at_trx_commit = 1`.

# innodb_flush_log_at_trx_commit
Controla o equilíbrio entre a conformidade rigorosa do ACID para operações de `COMMIT` e o maior desempenho possível quando as operações de I/O relacionadas a `COMMIT` são reorganizadas e feitas em lotes. Para maiores detalhes, consulte a [documentação oficial](https://dev.mysql.com/doc/refman/8.0/en/innodb-parameters.html#sysvar_innodb_flush_log_at_trx_commit).

# innodb_thread_concurrency
Por padrão, o valor é definido como 0 - o que significa que um número infinito (Até o limite de hardware) de threads pode ser aberto e executado dentro do MySQL. A recomendação usual é não alterar o valor padrão, exceto na resolução de problemas de contenção. Se a carga de trabalho for consistentemente pesada ou tiver picos ocasionais, pode ser interessante definir o valor de `innodb_thread_concurrency` usando a seguinte fórmula: `número de cores * 2`.

# Referências
- Curso MySQL 8.0 for Database Administrators, https://mylearn.oracle.com/ou/course/mysql-80-for-database-administrators/76889
- Livro Learning MySQL: Get a Handle on Your Data (2nd Edition), por Vinicius M Grippa e Sergey Kuzmichev - Pg. 697-705