# Como o Redis gerencia a memória?
O Redis nem sempre libera memória para o sistema operacional quando as chaves são removidas. Isso não é algo específico do Redis, mas é como a maioria das implementações malloc() funcionam. Por exemplo, se preenchermos uma instância com 5 GB de dados e, em seguida, removermos o equivalente a 2 GB de dados, o Resident Set Size provavelmente permanecerá inalterado, ou seja, ainda estará em torno de 5 GB - mesmo que o Redis afirme que a memória do usuário esteja em torno de 3 GB. Isso acontece porque o alocador subjacente não consegue liberar memória facilmente.

Outro ponto importante, devemos provisionar a memória com base no pico de uso de memória. Se a carga de trabalho exigir 10 GB de vez em quando, mesmo que na maioria das vezes 5 GB possam bastar, precisaremos provisionar 10 GB.

Todavia os alocadores são inteligentes e são capazes de reutilizar pedaços livres de memória. Por exemplo, após liberarmos 2 GB de um conjunto de dados de 5 GB e adicionarmos novas chaves, iremos ver o RSS (Resident Set Size) permanecer estável e não crescer mais, a medida que adicionamos mais 2 GB de chaves. O alocador está basicamente tentando reutilizar os 2 GB de memória previamente liberados.

# Melhores práticas de gerenciamento de memória

## Proporção de uso da memória do sistema operacional
A métrica de proporção de uso de memória do sistema operacional permite medir o uso de memória de uma instância em relação a memória do sistema operacional. Se essa métrica exceder 80%, isso pode indicar que a instância está sob pressão de memória. Se você não fizer nada e o uso da memória continuar a crescer, haverá risco de falha em uma instância devido a memória insuficiente. Essa métrica pode exceder 80% devido a fragmentação da memória ou operações com uso intensivo de memória.

Se a proporção de uso de memória do sistema operacional continuar a crescer drasticamente, avalie a possibilidade de escalonar a instância e/ou diminuir o `maxmemory` e/ou ativar o `activedefrag`.

## Configuração do maxmemory
Dependendo da métrica de proporção de uso de memória do sistema, talvez seja necessário diminuir o limite do `maxmemory` para que seja possível lidar melhor com picos de carga de trabalho.

## Desfragmentação ativa
A desfragmentação ativa permite que um servidor Redis compacte os espaços deixados entre pequenas alocações e desalocações de dados na memória, permitindo assim recuperar a memória - há uma pequena troca, aumentando o uso de CPU.

A fragmentação é um processo natural que acontece com todos os alocadores (Mas nem tanto com Jemalloc, felizmente) e certas cargas de trabalho. Normalmente era necessário reiniciar o servidor para diminuir a fragmentação ou eliminar todos os dados e criá-los novamente, porém graças a este recurso implementado no Redis 4.0, este processo pode acontecer em tempo de execução de forma "quente" enquanto o servidor está em execução.

Basicamente, quando a fragmentação ultrapassar um determinado nível, o Redis começará a criar novas cópias dos valores em regiões de memória contíguas, explorando certos recursos específicos do Jemalloc e, ao mesmo tempo, liberará as cópias antigas dos dados. Este processo, repetido de forma incremental para todas as chaves, fará com que a fragmentação volte aos valores normais.

Pontos importantes para considerar:
- Este recurso está desabilitado por padrão e só funciona se você compilou o Redis com Jemalloc.
- Você nunca precisará ativar esse recurso se não tiver problemas de fragmentação.
- Depois de experimentar a fragmentação, você pode ativar esse recurso quando necessário com o comando `CONFIG SET activedefrag yes`. Os parâmetros de configuração são capazes de ajustar o comportamento do processo de desfragmentação. Se você não tiver certeza do que eles significam, é uma boa ideia deixar os padrões inalterados. Abaixo, a imagem lista a relação dos parâmetros envolvidos.

![](img/01.png)

**Obs.:** Vale considerar também o uso do comando [MEMORY PURGE](https://redis.io/commands/memory-purge/), como alternativa.

# Referências
- https://redis.io/docs/management/optimization/memory-optimization/#memory-allocation
- https://cloud.google.com/memorystore/docs/redis/memory-management-best-practices
- https://redis.io/docs/management/config-file/