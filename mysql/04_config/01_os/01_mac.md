# MAC (Controle de Acesso Obrigatório)
Como o MySQL é um serviço comumente usado em muitas plataformas, os sistemas MAC mais comuns, por padrão, permitem que o processo `mysqld` acesse a porta padrão do MySQL, bem como os diretórios de dados e logs padrão.

De modo geral, não há necessidade de modificar a configuração MAC, a menos que seja necessário permitir uma configuração não padrão - por exemplo, como a mudança do diretório de dados ou o número da porta TCP.

## Exemplos de ajustes no MAC para o MySQL
Veja alguns exemplos comuns de ajustes necessários quando o MySQL utiliza portas ou diretórios personalizados. Esses ajustes informam ao sistema MAC, como o SELinux, que o serviço `mysqld` tem permissão para acessar tais recursos.

### Adicione novo mapeamento de portas
Defina uma faixa de portas TCP: 33060 (X Protocol), 33061 (Group Replication) e 33062 (Porta de administração) para o tipo `mysqld_port_t`, para que o MySQL possa usá-las:

```bash
semanage port -a -t mysqld_port_t -p tcp 33060-33062
```

### Adicione novo mapeamento de arquivos
Defina o diretório `data` e seu conteúdo para o tipo `mysqld_db_t`, para que o MySQL possa acessá-los:

```bash
semanage fcontext -a -t mysqld_db_t "/data(/.*)?"
restorecon -Rv /data
```

### Desabilitando o SELinux
Você pode desabilitar temporariamente o bloqueio do SELinux definindo-o como modo permissivo. Para isso, execute o comando `setenforce 0`.

No modo permissivo, o SELinux registra acessos não autorizados em seu arquivo de log (Por padrão, em `/var/log/audit/audit.log`), mas não bloqueia o acesso. Esse modo é útil para investigar problemas que você suspeita serem causados pela configuração do SELinux. Ao retornar para o modo enforcing com `setenforce 1`, o SELinux volta a aplicar suas políticas.

> Para persistir essa configuração, de modo que o valor não seja perdido após o desligamento do servidor, ajuste o arquivo `/etc/selinux/config`, de `SELINUX=enforcing` para `SELINUX=disabled`.

# Referências
- Curso MySQL 8.0 for Database Administrators, https://mylearn.oracle.com/ou/course/mysql-80-for-database-administrators/76889
- https://dev.mysql.com/doc/refman/8.0/en/selinux.html
- https://dev.mysql.com/blog-archive/mysql-guide-to-ports/