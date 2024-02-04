# String

## Definição de chave-valor
```bash
MSET "resultado:03-05-2015:megasena" "2, 4, 6, 8, 10, 12" "resultado:13-05-2015:megasena" "3, 6, 9, 12, 15, 18" "resultado:15-05-2015:megasena" "5, 10, 15, 20, 25, 30"
```

## Retorno do valor
```bash
MGET "resultado:03-05-2015:megasena" "resultado:13-05-2015:megasena"
```

# List
Podem agir como uma simples coleção, pilha ou fila.

Casos de uso:
- Fila de eventos;
- Armazenamento de postagens de usuários mais recentes.

## Definição de elementos em uma lista (Os dados são inseridos no início da lista, ao contrário de RPUSH, onde os dados são inseridos no fim da lista)
```bash
LPUSH "country" "Brasil" "Portugal" "EUA" "China" "Japão"
```

## Retorno do comprimento de uma lista
```bash
LLEN "country"
```

## Retorno do elemento de uma lista, com base em um índice
```bash
LINDEX "country" 0
```

## Retorno dos elementos de uma lista, com base em um intervalo
```bash
LRANGE "country" 0 -1
```

## Remoção e retorno do primeiro elemento da lista
```bash
LPOP "country"
```

Obs.: Nesse exemplo, Brasil seria removido.

## Remoção e retorno do último elemento da lista
```bash
RPOP "country"
```

Obs.: Nesse exemplo, Japão seria removido.

# Hash
Permite mapear campos e valores. São otimizados para usar a memória de forma eficiente e procurar dados rapidamente. Em um hash o nome do campo e do valor são strings, portanto um hash é um mapeamento de uma string para uma string.

## Definição de campos e seus respectivos valores no hash
```bash
HSET "movie" "title" "The Godfather" "year" 1972 "rating" 9.2 "watchers" 10000000
```

## Incremento de valor de um campo no hash
```bash
HINCRBY "movie" "watchers" 3
```

## Retorno dos valores associados aos campos especificados no hash
```bash
HMGET "movie" "title" "rating"
```

## Remove o campo de um hash
```bash
HDEL "movie" "watchers"
```

## Retorno de todos os pares chave/valor de um hash
```bash
HGETALL "movie"
```

Obs. 1: O comando HGETALL pode ser um problema caso o hash contenha muitos campos. Ele pode impactar o Redis devido a transferência desses dados através da rede. Uma boa alternativa é o comando HSCAN.
Obs. 2: É possível recuperar apenas os nomes de campo ou valores de campo de um hash com os comandos HKEYS e HVALS.

# Set
É uma coleção não ordenada de strings distintas.

Casos de uso:
- Filtragem de dados. Por exemplo, filtrando todos os voos que partem de uma determinada cidade e chegam a outra;
- Agrupamento de dados. Por exemplo, agrupando todos os usuários que visualizaram produtos semelhantes;
- Verificação de associação. Por exemplo, verificação de um usuário em uma denylist.

## Adição de membros ao conjunto (Não serão aceitos membros duplicados)
```bash
SADD "team:joaopaulo" "Palmeiras" "São Paulo" "Corinthians" "Santos" "Flamengo" "Fluminense" "Vasco" "Botafogo"
SADD "team:solange" "Palmeiras" "Cruzeiro" "Atlético-MG" "América-MG"
```

## Retorno de membros equivalentes ao comparar dois conjuntos
```bash
SINTER "team:joaopaulo" "team:solange"
```

## Retorno dos membros contidos no primeiro conjunto que não pertençam ao segundo conjunto
```bash
SDIFF "team:solange" "team:joaopaulo"
```

## Retorno de membros de um conjunto
```bash
SMEMBERS "team"
```

# Sorted Set
Sorted Set é muito semelhante ao Set, mas cada membro de um conjunto ordenado tem uma pontuação associada.
Em outras palavras, Sorted Set é uma coleção de strings distintas classificadas por pontuação. Caso a pontuação seja repetida, os membros serão ordenados em ordem alfabética.

Casos de uso:
- Uma lista de espera em tempo real para o atendimento ao cliente;
- Tabela de classificação de um jogo online exibindo os melhores jogadores.

## Adição de membros com pontuações ao conjunto ordenado (Se um membro especificado já for membro, a pontuação será atualizada e a posição será mantida, garantindo a ordem)
```bash
ZADD "user" 1 "João" 2 "Deborah" 3 "Solange" 4 "Tereza" 5 "Geraldo" 
```

## Retorno dos membros de um conjunto ordenado com base em um intervalo e com a respectiva pontuação (A ordem dos elementos é da pontuação mais baixa para a mais alta, entretanto o uso da opção REV pode alterar o modo de classificação em versões mais recentes ou o comando ZREVRANGE em versões mais antigas)
```bash
ZRANGE "user" 0 -1 WITHSCORES
```

## Retorno da pontuação de um membro de um conjunto ordenado
```bash
ZSCORE "user" "Geraldo"
```

## Retorno da posição de um membro de um conjunto ordenado, da mais baixa para a mais alta
```bash
ZRANK "user" "Deborah"
```

## Retorno da posição de um membro de um conjunto ordenado, da mais alta para a mais baixa
```bash
ZREVRANK "user" "Deborah"
```

# Bitmap
Um bitmap é uma sequência de bits onde cada bit pode armazenar 0 ou 1. Os bitmaps são uma ótima correspondência para aplicativos que envolvem análise em tempo real.

## Exemplos:
- Usuários X visitaram o site no dia YYYY-MM-DD
```bash
SETBIT "visits:2015-01-01" 10 1
SETBIT "visits:2015-01-01" 15 1
SETBIT "visits:2015-01-02" 10 1
SETBIT "visits:2015-01-02" 11 1
```

- Usuário especificado visitou o site no dia informado
```bash
GETBIT "visits:2015-01-01" 10 1
GETBIT "visits:2015-01-02" 15 1
```

- Identificando o número de visitas no site no dia informado
```bash
GETCOUNT "visits:2015-01-01"
GETCOUNT "visits:2015-01-02"
```

- Identificando o total de visitas no site de acordo com o período informado e direcionando para uma chave destino
```bash
BITOP OR "total_users" "visits:2015-01-01" "visits:2015-01-02"
BITCOUNT "total_users"
```

# HyperLogLogs
Conceitualmente um HyperLogLog é um algoritmo que usa randomização para fornecer uma aproximação muito boa do número de elementos exclusivos que existem em um conjunto (No Redis, o erro padrão é de 0,81).
O mais interessante é que é executado em O(1), tempo constante, e usa uma quantidade muito pequena de memória (Até 12kB de memória por chave).

Casos de uso: Contagem do número de usuários únicos que visitaram um site, do número de termos distintos que foram pesquisados no site em uma data ou hora específica, do número de hashtags distintas que foram usadas por um usuário e o número de palavras distintas que apareceram em um livro.

## Exemplos
- Adição de strings ao HyperLogLog. O PFADD retorna 1 se a cardinalidade foi alterada e 0 se permanece a mesma
```bash
PFADD "visits:2022-01-01" "João" "Paulo" "Deborah" "Geraldo"
PFADD "visits:2022-01-01" "João" "Deborah"
PFADD "visits:2022-01-02" "Solange" "Silvia" "Vicente" "Tereza" "João" "Deborah"
```

- Retorno aproximado da cardinalidade (Quando há várias chaves especificadas, a cardinalidade aproximada retornada é com base na união de todos os elementos exclusivos)
```bash
PFCOUNT "visits:2022-01-01" "visits:2022-01-02"
```

- Mesclagem dos HyperLogLogs especificados e direcionamento para uma chave destino
```bash
PMERGE "visits:total" "visits:2022-01-01" "visits:2022-01-02"
PFCOUNT "visits:total"
```

# Transação
```bash
MULTI
SET "database" "Postgres"
GET "name"
SET "a" 1
SET "b" 2
EXEC
```

Obs.: O comando MULTI inicia a transação, os demais comandos dentro do bloco serão enfileirados e somente o último estágio, EXEC, finalizará a transação. Em casos de reversão da transação, o comando DISCARD pode ser executado.

# Outros

## Retorna o tipo de dado armazenado em uma chave
```bash
TYPE key
```

## Retorno de chaves
```bash
KEYS *
KEYS "resultado:*-05-2015:*sena"
KEYS "resultado:1?-05-2015:megasena"
KEYS "resultado:?[35]-??-????:megasena"
```

Obs.: Priorize o uso de SCAN ao invés de KEYS.

## Expiração da chave em segundos
```bash
EXPIRE "resultado:03-05-2015:megasena" 30
```

## Retorna em segundos a permanência da chave até sua expiração
```bash
TTL "resultado:03-05-2015:megasena"
```

## Exclusão de todas as chaves de todos os bancos de dados existentes
```bash
FLUSHALL
```

## Este comando bloqueia o cliente atual até que todos os comandos de gravação anteriores sejam transferidos e reconhecidos com êxito por pelo menos o número especificado de réplicas dentro do período especificado em ms (Se o tempo limite for atingido, o comando retornará mesmo que o número especificado de réplicas ainda não tenha sido atingido)
```bash
WAIT 1 10
```

### Referência:

Livro Redis Essentials: Harness the power of Redis to integrate and manage your projects efficiently, por Maxwell Dayvson Da Silva e Hugo Lopes Tavares. Páginas 14-15; 21-22; 25; 27; 33; 41; 47-48; 81.