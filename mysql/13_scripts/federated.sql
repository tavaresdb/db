-- Avalie se a engine federated está disponível. Caso não, pode ser necessário adequar o my.cnf, adicionando a variável: federated = ON (Alteração requer reinicialização).
-- https://www.percona.com/blog/overview-of-mysql-alternative-storage-engines/

SELECT * FROM information_schema.engines WHERE engine = 'federated';

CREATE TABLE db.stg_local (
  id INT(10) NOT NULL AUTO_INCREMENT,
  name VARCHAR(256) NOT NULL,
  dateHour TIMESTAMP NOT NULL,
  PRIMARY KEY (id)
) ENGINE=FEDERATED CONNECTION="mysql://fed_user:pAssw0rd@192.168.10.1/db/tbl_remote";

START TRANSACTION;
INSERT INTO db.tbl_local SELECT * FROM db.stg_local WHERE id BETWEEN 1 and 1000;
COMMIT;