/*

Considerações:

- Se a tabela for grande e o Full-text Search for adotado, pode ser necessário aumentar o valor da variável innodb_ft_sort_pll_degree, visto que por padrão duas threads tokenizam, classificam e inserem palavras e dados associados as tabelas de índice;
- Ao criar um índice FULLTEXT na tabela usando a sintaxe CREATE FULLTEXT INDEX, será retornado o aviso 'InnoDB rebuilding table to add column FTS_DOC_ID'. O mesmo aviso é retornado se o índice FULLTEXT for criado usando a sintaxe ALTER TABLE para uma tabela que não possui a coluna FTS_DOC_ID. Se o índice FULLTEXT for especificado via CREATE TABLE e não for especificada a coluna FTS_DOC_ID, a mesma será adicionada de forma oculta. Definir uma coluna FTS_DOC_ID por CREATE TABLE é menos custoso do que criar um índice FULLTEXT em uma tabela que já está carregada com dados. Se uma coluna FTS_DOC_ID for definida em uma tabela antes do carregamento dos dados, a tabela e seus índices não precisarão ser reconstruídos para adicionar a nova coluna. Se desempenho não for um problema ao executar o comando CREATE FULLTEXT INDEX, desconsidere a coluna FTS_DOC_ID para que o próprio InnoDB crie o objeto;
- Se houver um número considerável de exclusões, lembre-se: A exclusão de um registro que possui uma coluna indexada, sendo seu tipo FULLTEXT, pode resultar em inúmeras pequenas exclusões nas tabelas de índice auxiliares, tornando o acesso simultâneo a essas tabelas um ponto de contenção. O MySQL internamente lida com esse problema e a vantagem desse design é que as exclusões são rápidas e baratas, entretanto a desvantagem é que o tamanho do índice não é reduzido imediatamente após a exclusão dos registros e pode ser necessário executar o comando OPTIMIZE TABLE na tabela indexada com a variável innodb_optimize_fulltext_only=ON para reconstruir o índice FULLTEXT.

Links adicionais:

https://dev.mysql.com/doc/refman/8.0/en/fulltext-restrictions.html
https://dev.mysql.com/doc/refman/8.0/en/fulltext-fine-tuning.html#fulltext-rebuild-innodb-indexes
https://dev.mysql.com/doc/refman/8.0/en/fulltext-search-ngram.html

*/
USE tst_stopwords;
 
CREATE TABLE my_stopwords(value VARCHAR(30)) ENGINE = InnoDB;

INSERT INTO my_stopwords(value) VALUES ('DBMS');

CREATE TABLE articles (
  id INT UNSIGNED AUTO_INCREMENT NOT NULL PRIMARY KEY,
  title VARCHAR(200),
  body TEXT
) ENGINE = InnoDB;

INSERT INTO articles (title,body) VALUES
('MySQL Tutorial','DBMS stands for DataBase ...'),
('How To Use MySQL Well','After you went through a ...'),
('Optimizing MySQL','In this tutorial, we show ...'),
('1001 MySQL Tricks','1. Never run mysqld as root. 2. ...'),
('MySQL vs. YourSQL','In the following database comparison ...'),
('MySQL Security','When configured properly, MySQL ...');

SET GLOBAL innodb_ft_server_stopword_table = 'tst_stopwords/my_stopwords';

CREATE FULLTEXT INDEX idx ON articles(title,body);

-- Retorna 6 registros
SELECT *
  FROM articles
 WHERE MATCH (title,body) AGAINST ('MySQL' IN NATURAL LANGUAGE MODE);

-- Retorna 0 registros devido ao termo ignorado
SELECT *
  FROM articles
 WHERE MATCH (title,body) AGAINST ('DBMS' IN NATURAL LANGUAGE MODE);

-- Retorna 1 registro, pois o termo é aceito
SELECT *
  FROM articles
 WHERE MATCH (title,body) AGAINST ('Tricks' IN NATURAL LANGUAGE MODE);

INSERT INTO my_stopwords(value) VALUES ('Tricks');

-- Retorna 1 registro, pois por mais que o termo seja ignorado (Adicionado recentemente), o índice não foi reconstruído
SELECT *
  FROM articles
 WHERE MATCH (title,body) AGAINST ('Tricks' IN NATURAL LANGUAGE MODE);

OPTIMIZE TABLE articles;

-- Retorna 0 registros, pois o índice foi reconstruído e o termo agora é ignorado
SELECT *
  FROM articles
 WHERE MATCH (title,body) AGAINST ('Tricks' IN NATURAL LANGUAGE MODE);