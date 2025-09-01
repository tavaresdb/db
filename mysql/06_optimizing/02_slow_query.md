# Slow Query Log
Para auditar as operações lentas no MySQL, considere habilitar as seguintes variáveis:

```bash
[mysqld]
slow_query_log = ON                      # Ativa a coleta de operações lentas
long_query_time = 1                      # Determina o threshold de operações lentas em segundos
slow_query_log_file = hostname-slow.log  # Determina a localização do arquivo de log de operações lentas
log_queries_not_using_indexes = OFF      # Se necessário, audite operações que não utilizam índices, independente do tempo de execução
log_slow_admin_statements = OFF          # Se necessário, audite operações administrativas lentas
```

Para facilitar a análise, podemos utilizar o utilitário `mysqldumpslow`, que irá sumarizar os dados do slow query log e facilitará a identificação das operações mais demoradas ou das mais frequentes acima do tempo desejado. Por exemplo:

```bash
mysqldumpslow -s 't' -t '10' host_name-slow.log # 10 operações com maior tempo de execução
mysqldumpslow -s 'c' -t '5' host_name-slow.log # 5 operações mais frequentes
```

> - O parâmetro `-a` remove as máscaras dos valores, mas acaba inutilizando o agrupamento.
> - Alternativamente, caso conte com o Percona Toolkit, o diagnóstico pode ser realizado com o utilitário `pt-query-digest`.