-- Avaliação do status do servidor/engine (Obs.: Se não especificado GLOBAL, o contexto será a nível de sessão)
SHOW GLOBAL STATUS;
SHOW ENGINE INNODB STATUS;

-- Monitoramento de conexões
SHOW FULL PROCESSLIST;

SHOW VARIABLES LIKE 'max_connections';
SHOW GLOBAL STATUS LIKE 'Threads_connected';
SHOW GLOBAL STATUS LIKE 'Threads_running';

-- Encerramento conexões
KILL processlist_id;

SELECT CONCAT('KILL ', id, ';')
  FROM performance_schema.processlist
 WHERE user = 'user_name';

-- Fornece informações sobre cada transação atualmente em execução dentro do InnoDB, incluindo se a transação está aguardando um bloqueio, quando a transação foi iniciada e a instrução SQL que a transação está executando, se houver
SELECT *
  FROM information_schema.innodb_trx
 ORDER
    BY trx_started;

SELECT b.user, b.command, b.time, b.state, b.info, a.*
  FROM information_schema.innodb_trx a
 INNER
  JOIN performance_schema.processlist b
    ON a.trx_mysql_thread_id = b.id
 ORDER
    BY a.trx_started;

-- Tabelas em uso
SHOW OPEN TABLES WHERE In_use > 0;

-- Identificação de bloqueios, http://nervinformatica.com.br/blog/index.php/2017/01/31/mysql-innodb-monitorando-locks/
SELECT trx.trx_mysql_thread_id,
       trx.trx_isolation_level,
       trx.trx_started,
       trx.trx_state,
       processlist.user,
       processlist.host,
       processlist.db,
       processlist.command,
       processlist.time,
       processlist.state,
       lock_waits.requesting_trx_id,
       lock_waits.blocking_trx_id,
       lock_waits.blocking_lock_id
  FROM information_schema.innodb_locks locks,
       information_schema.innodb_trx trx,
       performance_schema.processlist processlist,
       information_schema.innodb_lock_waits lock_waits
 WHERE locks.lock_trx_id = trx.trx_id
   AND trx.trx_mysql_thread_id = processlist.id;

-- Identificação de bloqueios, https://dev.mysql.com/doc/refman/5.7/en/innodb-information-schema-examples.html
SELECT w.requesting_trx_id,
       r.trx_mysql_thread_id AS requesting_process_id,
       r.trx_started AS requesting_trx_started,
       r.trx_query AS requesting_trx_query,
       r.trx_wait_started AS requesting_wait_started,
       w.blocking_trx_id, 
       b.trx_mysql_thread_id AS blocking_process_id,
       b.trx_started AS blocking_trx_started,
       b.trx_query AS blocking_trx_query,
       b.trx_wait_started AS blocking_wait_started
  FROM information_schema.innodb_lock_waits w
 INNER
  JOIN information_schema.innodb_trx r
    ON w.requesting_trx_id = r.trx_id
 INNER
  JOIN information_schema.innodb_trx b
    ON w.blocking_trx_id = b.trx_id;

-- Uma lista de transações aguardando bloqueios
SELECT trx_id, trx_requested_lock_id, trx_mysql_thread_id, trx_query
  FROM information_schema.innodb_trx
 WHERE trx_state = 'LOCK WAIT';

-- Uma lista de bloqueios em uma tabela específica
SELECT *
  FROM information_schema.innodb_locks 
 WHERE lock_table = 'schema.tabname';

-- Monitoramento de queries executadas no servidor
SELECT * 
  FROM sys.x$statement_analysis an
 WHERE an.last_seen >= '2022-04-08 08:00:00'
 ORDER
    BY last_seen DESC, total_latency DESC;

-- Avaliação do tamanho de tabela
SELECT table_schema AS 'Schema', table_name AS 'Table', ROUND((data_length + index_length) / 1024 / 1024) AS 'Size (MB)'
  FROM information_schema.tables
 ORDER
    BY 1, 3 DESC;

-- Detecção e correção de fragmentação em objetos
SELECT CONCAT(CONCAT(table_schema, '.'), table_name), data_free
  FROM information_schema.tables
 WHERE table_schema NOT IN ('information_schema', 'performance_schema', 'sys', 'mysql', 'test')
   AND data_length/1024/1024 > 100
   AND data_free*100/(data_length+index_length+data_free) > 10
   AND NOT engine = 'MEMORY';

OPTIMIZE TABLE schema.tabname;

-- Identificação de índices ineficientes
SELECT *
  FROM sys.schema_unused_indexes;

-- Avaliação do plano de execução
EXPLAIN SELECT * FROM actor;
EXPLAIN ANALYZE SELECT * FROM actor;

-- Descarregando os dados da memória para o disco e impedindo novas gravações
FLUSH TABLES WITH READ LOCK;

-- Tabela entra em modo leitura, ou seja, gravações são impedidas (Verdadeiro para sessão que emitiu o comando e demais sessões)
LOCK TABLES tabname READ;

-- Somente a sessão que emitiu o comando tem acesso completo a tabela, ninguém mais pode ler ou escrever
LOCK TABLES tabname WRITE;

-- Desbloqueio de tabelas
UNLOCK TABLES;

-- Expurgo manual dos logs binários, https://dev.mysql.com/doc/refman/5.7/en/purge-binary-logs.html
SHOW BINARY LOGS;
PURGE BINARY LOGS BEFORE 'YYYY-MM-DD HH:MM:SS';