# Swapiness
A memória swap é uma área do disco que o computador utiliza como memória quando o espaço na memória RAM está se esgotando. Já swapiness é o quão frequente o Linux utilizará a memória swap. O padrão de swapiness é 60, o que significa que o sistema operacional passará a considerar o swap quando a memória livre representar 60% do total.

Desabilitar o swap não é recomendável, pois a falta de memória RAM pode forçar o Linux a executar um OOM Killer (Out of memory Killer) que procurará os "melhores" processos a serem removidos para manter o sistema operacional estável, liberando a maior quantidade de memória RAM com a menor intervenção possível. Quase sempre o "melhor" processo é o `mysqld` e sua terminação imediata pode trazer problemas.

Sendo assim, é recomendável que a configuração do swapiness seja baixa, mas lembre-se que a configuração ideal dependerá também da memória RAM disponível. Por exemplo, 10% de 256 GB são 25 GB, já 10% de 1 GB são somente 100 MB. Na sequência segue um exemplo de como configurar o Linux para utilizar swap somente quando existir apenas 10% da memória livre:

```bash
sysctl vm.swappiness                        # Exibe o valor atual do parâmetro
sysctl -w vm.swappiness=10                  # Altera temporariamente o valor do parâmetro
echo 'vm.swappiness=10' >> /etc/sysctl.conf # Persiste a alteração do parâmetro, de modo que o valor não seja perdido após uma reinicialização do servidor
```

# Referência
- Treinamento MySQL com Alta Performance e Alta Disponibilidade, https://4linux.com.br/cursos/treinamento/mysql-com-alta-performance-e-alta-disponibilidade