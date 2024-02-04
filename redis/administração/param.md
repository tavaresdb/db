# Configurações do Redis
- maxclients: Limite de conexões simultâneas (Default, 10000);
- maxmemory: Definição do uso total de memória em bytes (Boa prática, 75% da RAM);
- tcp-backlog: Definição do tamanho da fila de conexão (Default, 511). Caso o número de conexões seja elevado, pode ser necessário trabalhar com um valor diferente do padrão. Além dessa configuração, pode ser necessário adequar os parâmetros de kernel, como somaxconn e tcp_max_syn_backlog;
- slowlog-log-slower-than: Permite registrar consultas que excedem o tempo de execução especificado em ms;
- slowlog-max-len: Define o tamanho do log lento, ou seja, o mais antigo é removido da fila.

# Configurações do SO
vm.swappiness=0                         # turn off swapping
net.ipv4.tcp_sack=1                     # enable selective acknowledgements
net.ipv4.tcp_timestamps=1               # needed for selective acknowledgements
net.ipv4.tcp_window_scaling=1           # scale the network window
net.ipv4.tcp_congestion_control=cubic   # better congestion algorithm
net.ipv4.tcp_syncookies=1               # enable syn cookies
net.ipv4.tcp_tw_recycle=1               # recycle sockets quickly
net.ipv4.tcp_max_syn_backlog=NUMBER     # backlog setting
net.core.somaxconn=NUMBER               # up the number of connections per port
net.core.rmem_max=NUMBER                # up the receive buffer size
net.core.wmem_max=NUMBER                # up the buffer size for all connections

Obs.: Caso o número de conexões estimado seja alto, os parâmetros acima devem ser avaliados.

echo 'never' > /sys/kernel/mm/transparent_hugepage/enabled

### Referência:
https://developer.redis.com/operate/redis-at-scale/talking-to-redis/initial-tuning