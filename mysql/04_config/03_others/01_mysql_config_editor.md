# Utilitário mysql_config_editor
Especificar uma senha na linha de comando no formato `mysql -u root -p password` não é recomendado. Por conveniência, poderíamos colocá-la em um grupo [client] no arquivo de configuração, mas a senha seria armazenada em texto simples, facilmente visível para qualquer pessoa com acesso de leitura ao arquivo.

O utilitário `mysql_config_editor` permite armazenar credenciais de autenticação em um arquivo de login criptografado chamado `.mylogin.cnf` (Alternativamente pode ser definido outro nome para o arquivo, através da variável de ambiente `MYSQL_TEST_LOGIN_FILE`). A localização do arquivo é o diretório home do usuário atual em sistemas Linux e UNIX. O arquivo pode ser lido pelo cliente MySQL para obter as credenciais de autenticação ao se conectar a um servidor MySQL. O método de criptografia é reversível, então não é possível garantir que as credenciais sejam tão seguras quanto se fossem armazenadas com permissões de leitura restritas no arquivo. No entanto, o recurso facilita evitar o uso de senhas em texto puro na linha de comando ou nos arquivos de configuração do MySQL.


## Adição de credencial no mysql_config_editor
```bash
mysql_config_editor set --login-path=login_path_name --host=ip_address --port=3306 --user=username --password
```

## Visualização de credenciais no mysql_config_editor
```bash
mysql_config_editor print --all

mysql_config_editor print --login-path=login_path_name
```

## Conexão MySQL com Login Path
```bash
mysql --login-path=login_path_name
```

# Referência
- Curso MySQL 8.0 for Database Administrators, https://mylearn.oracle.com/ou/course/mysql-80-for-database-administrators/76889