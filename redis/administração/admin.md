# Comandos administrativos

## Retorna se a conexão está ativa
```bash
PING
```

## Lista as conexões client
```bash
CLIENT LIST
```

## Encerramento de conexão
```bash
CLIENT KILL ID 99
CLIENT KILL ADDR 127.0.0.1:51167
CLIENT KILL TYPE slave
```

## Recupera a configuração atual
```bash
CONFIG GET
```

## Define uma nova configuração em tempo de execução
```bash
CONFIG SET something
```

## Persiste no arquivo redis.conf a configuração atual
```bash
CONFIG REWRITE
```

## Configura autenticação
```bash
CONFIG SET REQUIREPASS R3d1$
CONFIG REWRITE
```

Obs.: A autenticação também pode ser configurada através do arquivo redis.conf, sendo o parâmetro requirepass.

## Realiza autenticação
```bash
AUTH R3d1$
```

## Retorna informações e estatísticas do servidor Redis
https://redis.io/commands/info/

```bash
INFO
INFO memory
INFO cpu
```

## Retorna o número de chaves existentes no banco de dados
```bash
DBSIZE
```

## Monitoramento das operações correntes no servidor Redis (O processo gera um custo adicional a máquina)
```bash
MONITOR
```

## Monitoramento das operações lentas no servidor Redis
```bash
SLOWLOG GET
SLOWLOG GET 10
```

## Encerramento do servidor Redis
```bash
SHUTDOWN [SAVE | NOSAVE]
```

Obs.: A opção SAVE força o Redis a salvar todos os dados no arquivo dump.rdb, mesmo que a persistência não esteja habilitada. A opção NOSAVE impede que o Redis persista os dados no disco, mesmo com a persistência habilitada.

## Throubleshooting
Avaliando a proporção de acertos/erros de cache (Hit/Miss):
```bash
redis-cli INFO stats | grep keyspace
```

Essa opção varrerá o conjunto de dados em busca de chaves grandes e fornecerá informações sobre elas:
```bash
redis-cli —bigkeys
```

Além de relatar as maiores chaves, essa opção relatará o tamanho médio:
```bash
redis-cli —memkeys
```

Logfile:
Localize a diretiva logfile no arquivo redis.conf e defina o local de armazenamento, como por exemplo /var/log/redis/redis.log.
Caso haja o interesse de usar um servidor de log remoto, descomente os parâmetros syslog-enabled, syslog-ident e syslog-facility e garanta que syslog-enabled seja definido como yes. Na sequência, reinicie o servidor Redis.

## Observabilidade
https://grafana.com/grafana/plugins/redis-datasource/