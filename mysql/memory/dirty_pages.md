# Visão geral

Quando os dados são modificados em uma tabela usando o InnoDB como storage engine, as alterações são gravadas no redo log do InnoDB e o novo valor é salvo no buffer pool. Somente algum tempo depois é que a mudança será refletida nos arquivos de dados reais.
Como os dados são lidos do buffer pool, se disponível, e o redo log reside no disco, isso não afeta a persistência das alterações, mas fornece uma otimização, pois é mais rápido gravar no redo log, que é gravado em um forma sequencial, em comparação com os arquivos de dados, o que em geral requer I/O aleatório.

Os dados no buffer pool que são diferentes dos dados nos arquivos de dados correspondentes são chamados de sujos(dirty) ou modificados. Vários eventos podem acionar a liberação dos dados para os arquivos de dados, por exemplo:

- Para liberar espaço no buffer pool para ler novos dados nele.
- Para abrir espaço para mais alterações no redo log.
- Quando o MySQL é desligado porque o buffer pool está vazio após a reinicialização, para garantir que os dados atualizados sejam lidos, as páginas sujas devem ser liberadas. Em caso de falha, o processo de recuperação trata disso usando os redo logs.

A quantidade de páginas sujas geralmente é expressa como uma porcentagem; nesse caso, é a porcentagem de páginas sujas em relação ao tamanho total do buffer pool.

Existem duas opções disponíveis para limitar quanto do buffer pool pode ser usado para páginas sujas: innodb_max_dirty_pages_pct e innodb_max_dirty_pages_pct_lwm.

Em geral, você não deve usar innodb_max_dirty_pages_pct e innodb_max_dirty_pages_pct_lwm para tentar limitar a quantidade de páginas sujas. Não deveria ser um objetivo por si só ter a menor quantidade possível de páginas sujas. Forçar o número de páginas sujas a ser baixo também força o InnoDB a aumentar a atividade de liberação (flushing), o que pode afetar o desempenho.

Em circunstâncias normais, a capacidade de I/O do InnoDB e a liberação adaptativa devem ser usadas.

Como as páginas sujas também são armazenadas nos redo logs para garantir a persistência das alterações feitas nos dados, as opções para controlar a quantidade de páginas sujas no buffer pool e a utilização dos redo logs estão fortemente acopladas:

- A quantidade de páginas sujas não pode ultrapassar a capacidade dos redo logs. Na prática, o InnoDB será muito agressivo para manter a utilização de três redo logs abaixo de 75%.
- Ao configurar o InnoDB para tentar manter baixa a quantidade de páginas sujas, isso pode ajudar a evitar uma liberação agressiva devido aos redo logs ficarem muito cheios.

# Opções

## innodb_max_dirty_pages_pct

Ao contrário do que o nome da opção sugere, ela não especifica um limite superior rígido para a quantidade de páginas sujas no buffer pool do InnoDB, mas define o limite onde o InnoDB começará a liberar páginas sujas de forma agressiva. Por este motivo em servidores ocupados é possível ver a quantidade de páginas sujas sendo maior que o valor de innodb_max_dirty_pages_pct. Isso é tão projetado quanto ajuda a evitar um grande impacto desnecessário no desempenho ao liberar as páginas sujas para o disco. Na verdade, a menos que innodb_max_dirty_pages_pct esteja definido com um valor baixo e/ou o servidor esteja muito ocupado, especialmente com I/O, a quantidade de páginas sujas raramente será mais do que alguns por cento acima do valor de innodb_max_dirty_pages_pct.

Em geral, você deve considerar innodb_max_dirty_pages_pct uma válvula de segurança e, idealmente, o InnoDB nunca deve atingir essa quantidade de páginas sujas, pois a I/O induzida pela liberação afetará o desempenho. No entanto, particularmente no MySQL 5.5 e anteriores, onde os arquivos de log do InnoDB devem ter um tamanho total inferior a 4 GB, é melhor ter a liberação acionada por innodb_max_dirty_pages_pct do que uma liberação assíncrona, fazendo com que os arquivos de log do InnoDB fiquem muito cheios.

Como o conteúdo dos redo logs é liberado para os arquivos de dados como parte de um encerramento, o encerramento pode demorar muito se houver muitas páginas sujas. Para reduzir o tempo que leva um desligamento, você pode usar innodb_max_dirty_pages_pct para liberar gradualmente as páginas para os arquivos de dados, diminuindo continuamente o valor de innodb_max_dirty_pages_pct um pouco abaixo da quantidade atual de páginas sujas.

## innodb_max_dirty_pages_pct_lwm

Esta opção controla quando a pré-liberação entra em ação. Como a liberação acionada ao atingir innodb_max_dirty_pages_pct muitas vezes pode causar um impacto no desempenho, esta opção foi adicionada para permitir que o InnoDB tenha dois níveis de liberação, sendo a liberação acionada por innodb_max_dirty_pages_pct_lwm menos agressiva do que aquela acionado por innodb_max_dirty_pages_pct. Portanto, você deve definir innodb_max_dirty_pages_pct_lwm para um valor menor que innodb_max_dirty_pages_pct. Quanto menor depende da velocidade do seu armazenamento: uma margem mais baixa é boa para armazenamento rápido, uma margem mais alta para armazenamento lento: um valor 0 tem o significado especial de desabilitar completamente a pré-liberação.

# Monitoramento
A saída de SHOW STATUS GLOBAL LIKE 'Innodb_buffer_pool_%' inclui variáveis ​​de status sobre o buffer pool do InnoDB:

As cinco variáveis ​​de status têm o seguinte significado:
- Innodb_buffer_pool_pages_data/Innodb_buffer_pool_bytes_data: a quantidade de dados no buffer pool.
- Innodb_buffer_pool_pages_dirty/Innodb_buffer_pool_bytes_dirty: a quantidade de dados sujos no buffer pool.
- Innodb_buffer_pool_pages_total: a quantidade total de páginas de dados no buffer pool.

Para calcular a porcentagem atual de páginas sujas, use a fórmula:
Dirty Page Percentage = Innodb_buffer_pool_pages_dirty/Innodb_buffer_pool_pages_total * 100

# Referência
https://support.oracle.com/knowledge/Oracle%20Database%20Products/1524362_1.html