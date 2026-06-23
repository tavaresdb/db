# Comandos administrativos

## Status do cluster
```bash
nodetool status
```

## Lista dos snapshots
```bash
nodetool listsnapshots
```

## Limpeza de um snapshot
```bash
nodetool clearsnapshot -t 'snapshot_name'
```

## Análise do progresso de compactação
```bash
nodetool compactionstats
```

## Identificação do número corrente de compactadores
```bash
nodetool getconcurrentcompactors
```

## Definição do número de compactadores correntes
```bash
nodetool setconcurrentcompactors 2
```

## Retorna estatísticas de uma tabela
```bash
nodetool tablehistograms <keyspace> <table>
nodetool tablestats <keyspace>.<table>
```