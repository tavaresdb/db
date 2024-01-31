# Opções de Persistência de Dados
- Snapshotting;
- Append-only file (AOF).

No arquivo redis.conf, ajuste os seguintes parâmetros caso opte por snapshot:
```
dbfilename my_backup_file.rdb
dir /backup
save 60 1000
```

No arquivo redis.conf, ajuste os seguintes parâmetros caso opte por AOF:
```
appendonly yes
appendfilename "my_aof_file.aof"
appendfsync [always | everysec | no]
```

Observações:
- A persistência de dados pode afetar o desempenho;
- O parâmetro save funciona da seguinte forma: O primeiro argumento define com que frequência o Redis deve despejar os dados para o disco e o segundo argumento define uma condição, que é o número de chaves modificadas, ou seja, no exemplo acima o dump ocorrerá caso 1000 ou mais chaves tenham sido modificadas no intervalo definido, que foi de 60 segundos;
- Perceba que a opção snapshotting pode acarretar em perda de dados. Avalie se essa situação é aceitável ou não. Caso não, opte por AOF, pois cada gravação será direcionada ao disco;
- Os possíveis valores para sincronização são os seguintes: always (Sincroniza a cada gravação, sendo a mais segura; O cliente receberá a confirmação somente após ter sido gravado no arquivo AOF), everysec (Política padrão, sincronizando as gravações a cada segundo) e no (O Redis registrará no descritor de arquivos, porém não forçará o SO a liberar os dados no disco. O Linux costuma despejar os dados para o disco a cada 30 segundos);
- Caso opte pelo AOF, à medida que os arquivos AOF aumentam de tamanho, o servidor Redis reescreve periodicamente em um formato compactado. Esse arquivo compactado contém o conjunto mínimo de comandos necessários para reconstruir o conjunto de dados no momento em que o arquivo foi criado.

## Referência:
https://redis.io/docs/management/persistence/