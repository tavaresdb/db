# Opções de Configuração
O MySQL aplica as configurações na seguinte ordem de precedência:

1. Padrões pré-compilados.
2. Opções do arquivo de configuração.
   - Se múltiplos arquivos forem usados, os posteriores sobrescrevem opções dos anteriores.
3. Opções da linha de comando.
4. Variáveis persistidas.
5. Variáveis definidas dinamicamente.

# Locais dos Arquivos de Configuração
O MySQL pode ler múltiplos arquivos de configuração de diferentes locais. A maioria das instalações utiliza apenas um arquivo de configuração para simplificar. Para exibir os arquivos e a ordem de leitura, execute:

```bash
mysqld --verbose --help | grep "Default options" -A2
```

A tabela a seguir resume os caminhos possíveis e o escopo de cada arquivo:

|Nome do arquivo                                 |Escopo e propósito                                                                           |
|------------------------------------------------|---------------------------------------------------------------------------------------------|
|/etc/my.cnf, /etc/mysql/my.cnf, /usr/etc/my.cnf |Opções globais lidas por todos os programas                                                  |
|$MYSQL_HOME/my.cnf                              |Opções do servidor, lidas apenas se a variável estiver definida                              |
|~/.my.cnf                                       |Opções globais lidas por todos os programas executados por um usuário específico             |
|Extra config file                               |Arquivo opcional especificado com --defaults-extra-file                                      |
|~/.mylogin.cnf                                  |Arquivo de login seguro                                                                      |
|DATADIR/mysqld-auto.cnf                         |Arquivo de opções para variáveis persistidas                                                 |

> Caso queira validar se há problemas com o arquivo de configuração, execute o comando `mysqld --validate-config`.

# Referências
- Curso MySQL 8.0 for Database Administrators, https://mylearn.oracle.com/ou/course/mysql-80-for-database-administrators/76889
- Livro Learning MySQL: Get a Handle on Your Data (2nd Edition), por Vinicius M Grippa e Sergey Kuzmichev - Pg. 596-599