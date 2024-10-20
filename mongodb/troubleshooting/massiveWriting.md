# Escrita massiva
Escrita massiva no MongoDB pode gerar os seguintes impactos:

**Caching:** O MongoDB usa um mecanismo de cache para armazenar em memória os dados frequentemente acessados. Durante uma carga massiva os novos dados podem ocupar o espaço no cache, forçando o MongoDB a remover dados existentes do cache. Isso pode levar a mais leituras diretamente do disco, causando um aumento na carga de trabalho.

**Uso de SWAP:** Se a carga massiva de dados exceder a capacidade da memória física disponível, o sistema operacional poderá usar SWAP para alocar dados temporariamente.

**Transferência de Rede:** Avaliar se o desempenho e a largura de banda são afetados. Pode ser útil otimizar a transferência de dados, por exemplo, usando compressão.

Para mitigar esses impactos, considere as seguintes estratégias:

**Evitar Problemas de Memória:** Para evitar problemas de memória é essencial garantir que o tamanho do conjunto de dados e a carga de trabalho se alinhem com os recursos computacionais disponíveis. Considere aumentar a memória do servidor, para que o MongoDB possa manter mais dados em cache.

**Configurações do MongoDB:** Existem configurações no MongoDB que podemos ajustar para otimizar o comportamento durante cargas massivas. Por exemplo, a configuração writeConcern pode ser ajustada para compromissos mais flexíveis durante operações de gravação intensivas. A ativação do parâmetro tcmallocAggressiveMemoryDecommit também pode ser interessante, conforme demonstrado [neste artigo](https://tech.oyorooms.com/mongodb-out-of-memory-kill-process-mongodb-using-too-much-memory-solved-44e9ae577bed). É importante também dimensionar corretamente o oplog, para que as operações sejam retidas por um tempo suficiente.

Obs.: À partir da versão 8 o parâmetro tcmallocAggressiveMemoryDecommit torna-se depreciado. O motivo disso é que nessa nova versão há melhorias no TCMalloc que usa caches por CPU, em vez de caches por thread, para reduzir a fragmentação de memória, tornando o banco de dados mais resiliente a cargas de trabalho de alto estresse. Para maiores detalhes, consule a [documentação oficial](https://mongodb.com/docs/upcoming/administration/tcmalloc-performance/#std-label-tcmalloc-performance).

**Sharding:** Se a escalabilidade horizontal for uma opção, considere a fragmentação (sharding) dos dados para distribuir a carga entre vários servidores.

Outro ponto, caso o processamento seja em lote (batch processing), para inserir dados no MongoDB de maneira eficiente e não agressiva, existem algumas estratégias que também devemos considerar. Aqui estão algumas sugestões:

**Operações em Lote (Bulk Operations):** Utilize as operações em lote do MongoDB, como o Bulk Write Operations, para enviar várias operações de gravação em uma única solicitação. As operações em lote reduzem a sobrecarga de comunicação entre o cliente e o servidor, melhorando a eficiência.

**Tamanho Adequado para Lotes (Batch Size):** Ajuste o tamanho dos lotes de dados que você está inserindo de acordo com as características do seu ambiente. Considere também a cadência. Experimente diferentes tamanhos de lote para encontrar um equilíbrio entre o desempenho e a carga no sistema.

**Utilize o Modo "Unordered" no Bulk:** Se a ordem das operações não for crítica para o seu caso de uso, você pode usar o modo "unordered" nas operações em lote. Isso permite que as operações sejam executadas em paralelo, melhorando o desempenho.

**Otimize o Tamanho do Documento:** Evite documentos extremamente grandes. Tamanhos grandes de documentos podem impactar negativamente o desempenho durante as operações de leitura e gravação.

**Utilize Operações de Upsert:** Se aplicável ao seu caso, considere usar operações de upsert. Isso pode reduzir a necessidade de verificar a existência de um documento antes de realizar a inserção.