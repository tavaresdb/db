// [Artigo em construção, carece desenvolvimento]
// Após alguns ajustes do time na app, como adequação do batch size, e da ativação do parâmetro tcmallocAggressiveMemoryDecommit, a solução como um todo se portou melhor.
// Refinando o tamanho do disco e do oplog.

Escrita massiva no MongoDB pode gerar os seguintes impactos:

## Caching:

O MongoDB usa um mecanismo de cache para armazenar em memória os dados frequentemente acessados. Durante uma carga massiva os novos dados podem ocupar o espaço no cache, forçando o MongoDB a remover dados existentes do cache. Isso pode levar a mais leituras diretamente do disco, causando um aumento na carga de trabalho.

## Uso de SWAP:

Se a carga massiva de dados exceder a capacidade da memória física disponível, o sistema operacional poderá usar SWAP para alocar dados temporariamente.

E também discutimos algumas estratégias para mitigar tais problemas:

## Evitar Problemas de Memória:

Para evitar problemas de memória é essencial garantir que o tamanho do conjunto de dados e a carga de trabalho se alinhem com os recursos disponíveis no sistema (RAM).

Considerar aumentar a capacidade de RAM do servidor se possível, para que o MongoDB possa manter mais dados em cache.

## Configurações do MongoDB:

Existem configurações no MongoDB que podemos ajustar para otimizar o comportamento durante cargas massivas. Por exemplo, a configuração writeConcern pode ser ajustada para compromissos mais flexíveis durante operações de gravação intensivas.

## Sharding:

Se a escalabilidade horizontal for uma opção, considere a fragmentação (sharding) dos dados para distribuir a carga entre vários servidores.

Outro ponto, considerando que o processamento é em lote (batch processing), para inserir dados no MongoDB de maneira eficiente e não agressiva, existem algumas estratégias que também devemos considerar. Aqui estão algumas sugestões:

## Operações em Lote (Bulk Operations):

Utilize as operações em lote do MongoDB, como o Bulk Write Operations, para enviar várias operações de gravação em uma única solicitação.

As operações em lote reduzem a sobrecarga de comunicação entre o cliente e o servidor, melhorando a eficiência.

## Tamanho Adequado para Lotes (Batch Size):

Ajuste o tamanho dos lotes de dados que você está inserindo de acordo com as características do seu ambiente. Considere também a cadência.

Experimente diferentes tamanhos de lote para encontrar um equilíbrio entre o desempenho e a carga no sistema.

## Utilize o Modo "Unordered" no Bulk:

Se a ordem das operações não for crítica para o seu caso de uso, você pode usar o modo "unordered" nas operações em lote. Isso permite que as operações sejam executadas em paralelo, melhorando o desempenho.

## Otimize o Tamanho do Documento:

Evite documentos extremamente grandes. Tamanhos grandes de documentos podem impactar negativamente o desempenho durante as operações de leitura e gravação.

## Utilize Operações de Upsert:

Se aplicável ao seu caso, considere usar operações de upsert (update + insert). Isso pode reduzir a necessidade de verificar a existência de um documento antes de realizar a inserção.

Obs.: Itens tachados significa que já foram discutidos em conjunto com o DEV.

E por fim, precisamos considerar também o quão nocivo pode ser trabalhar com dados binários. Nesse teste de carga alguns dados eram binários. Combinaremos com o DEV como o banco de dados se comportará com dados textuais.

Obs.: Creio que qualquer mudança nesse sentido não trará resultados significativos, entretanto faz sentido ver se há alguma mudança significativa no uso dos recursos computacionais.

Aqui estão alguns pontos que devem ser considerados ao lidar com dados binários em um cenário de processamento massivo:

Tamanho dos Documentos.

Eficiência de Índices e Consultas.

## Transferência de Rede:

Avaliar se o desempenho e a largura de banda são afetados.

Pode ser útil otimizar a transferência de dados, por exemplo, usando compressão.

## Cache e Memória:

O uso extensivo de dados binários pode aumentar os requisitos de memória, impactando o desempenho do cache.