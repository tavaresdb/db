# Possíveis causas para degradação
- Consultas com longo tempo de execução (Collection Scans e uso de índices ineficientes);
- Construção de índices;
- Write contention (Contenção em gravações).

## Write contention
Quando um documento é atualizado no MongoDB, o processo segue uma abordagem chamada de copy-on-write (cópia na gravação, ou seja, uma cópia do documento será feita durante a atualização, em vez de modificar o documento original diretamente). 

Primeiro, uma nova versão do documento é preparada.

![](img/01.png)

Durante esse processo, apenas o documento original é visível para todos os aplicativos.

![](img/02.png)

Em seguida, a atualização é confirmada alternando um ponteiro em uma única operação da CPU.

![](img/03.png)

E de repente a versão antiga do documento não está mais disponível, mas a nova versão está. É assim que as coisas funcionam quando tudo está indo bem e é assim que podemos simultaneamente ler e escrever no mesmo documento. Simplesmente lemos a versão antiga enquanto a nova versão está sendo preparada e quando a nova versão estiver em vigor, as consultas serão lidas à partir disso.

Esse método, conhecido como MVCC, é como o mecanismo de armazenamento WiredTiger é capaz de obter tanto rendimento, no entanto há um problema quando você tem vários gravadores tentando atualizar o mesmo documento ao mesmo tempo. Na sequência será demonstrado o que aconteceria se três escritores tentassem atualizar simultaneamente o mesmo documento.

![](img/04.png)

Cada um deles começaria a preparar um novo documento por conta própria. Todos eles dedicam recursos do sistema à atualização, incluindo ciclos de CPU e alocação de RAM, mas apenas uma atualização pode acontecer. Talvez neste exemplo, seja a v2-3.

![](img/05.png)

O ponteiro é invertido e essas versões falham, mas essas gravações ainda precisam ocorrer. Portanto, se forem válidos, eles escreverão nesta versão do documento.

Agora, neste exemplo, duas gravações tiveram que ser repetidas.

![](img/06.png)

Imagine um cenário em que você tem 20 gravações e 19 delas precisam ser repetidas...

# Referência
https://learn.mongodb.com/courses/m312-diagnostics-and-debugging