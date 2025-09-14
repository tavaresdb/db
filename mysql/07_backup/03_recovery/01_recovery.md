# Recuperação do InnoDB
- O InnoDB se recupera automaticamente após uma falha.

- Use o comando `CHECK TABLE` ou um programa cliente para encontrar inconsistências, incompatibilidades e outros problemas.
  - O InnoDB detecta automaticamente problemas com os dados armazenados quando você os acessa.
  - O comando `CHECK TABLE` força o InnoDB a acessar todos os dados.

- Para reparar tabelas após uma falha, reinicie o servidor utilizando a opção `--innodb_force_recovery` ou restaure as tabelas a partir de um backup.
  - Recomenda-se fazer backup do banco de dados antes de tentar reparar as tabelas.

Se a recuperação automática do InnoDB falhar, siga o seguinte procedimento:

1. Desligue o MySQL e faça backup de todos os arquivos de dados.

2. Reinicie o MySQL com `--innodb_force_recovery=1`, aumentando o valor gradualmente até que o InnoDB inicie com sucesso.
   - A opção aceita valores de 0 a 6. 0 é o valor padrão, indicando a recuperação automática padrão. Tenha cuidado ao usar valores mais altos, pois eles impedem operações `INSERT`, `UPDATE` ou `DELETE`, e podem gerar inconsistências nas tabelas recuperadas. Valores 4 ou superiores colocam o InnoDB em modo somente leitura.

3. Exporte as tabelas InnoDB e depois exclua-as enquanto a opção `--innodb_force_recovery` estiver ativada.

4. Reinicie o servidor sem a opção `--innodb_force_recovery`. Quando o servidor for iniciado, recupere as tabelas InnoDB a partir dos arquivos exportados.

> Sempre use com cautela a opção `--innodb_force_recovery`. É uma boa prática copiar o diretório de dados antes de qualquer tentativa de recuperação.

# Referência
- Curso MySQL 8.0 for Database Administrators, https://mylearn.oracle.com/ou/course/mysql-80-for-database-administrators/76889