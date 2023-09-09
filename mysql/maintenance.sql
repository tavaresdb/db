-- Ref.: http://youdidwhatwithtsql.com/mysql-database-maintenance-stored-procedure-update/1738/

USE db_maintenance;

CREATE TABLE `tb_maintenance_table_excludes` (
  `database_name` VARCHAR(128),
  `table_name` VARCHAR(128),
  PRIMARY KEY (`database_name`, `table_name`)
);

CREATE TABLE `tb_maintenance_log` (
  `id` INT(10) unsigned NOT NULL AUTO_INCREMENT,
  `db` VARCHAR(128) NOT NULL,
  `statement` VARCHAR(1024) NOT NULL,
  `started` DATETIME DEFAULT NULL,
  `finished` DATETIME DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_started` (`started`)
);

DELIMITER $$

DROP PROCEDURE IF EXISTS `prc_maintenance`$$

CREATE PROCEDURE `prc_maintenance`(p_mode TINYINT, p_database VARCHAR(128))
BEGIN
    -- Declare variables
    DECLARE done TINYINT;
    DECLARE my_table VARCHAR(128);
    DECLARE is_partitioned TINYINT;

    -- Declare cursor for table names
    DECLARE table_cursor CURSOR FOR
     SELECT t.table_name,
            IF(t.CREATE_OPTIONS LIKE '%partitioned%', 1, 0) AS is_partitioned
       FROM information_schema.tables t
      WHERE t.table_schema = p_database
        AND NOT EXISTS (SELECT *
                          FROM tb_maintenance_table_excludes t2
                         WHERE t2.database_name = t.table_schema
                           AND t2.table_name = t.table_name)
        AND t.table_type = 'BASE TABLE';
    
    -- Declare NOT FOUND handler
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    SET done = 0;

    -- Open the cursor
    OPEN table_cursor;

    table_loop: LOOP
     FETCH table_cursor INTO my_table, is_partitioned;
     IF (done = 1) THEN
       LEAVE table_loop;
     END IF;

     IF (is_partitioned = 0) THEN
       IF(p_mode = 1) THEN -- Optimize
         SET @q = CONCAT('OPTIMIZE TABLE ', p_database, '.', my_table);
       ELSE -- Analyze
         SET @q = CONCAT('ANALYZE TABLE ', p_database, '.', my_table);
       END IF;

     -- Start log statement
     INSERT INTO tb_maintenance_log (db, statement, started)
     VALUES (p_database, @q, NOW());

     SET @id = LAST_INSERT_ID();

     PREPARE stmt FROM @q;
     EXECUTE stmt;

     -- End log statement
     UPDATE tb_maintenance_log
        SET finished = NOW()
      WHERE id = @id;

     ELSE -- Partitioned tables
     BEGIN

     -- Declare variables
     DECLARE var_partition_name VARCHAR(255);
     DECLARE partitions_done TINYINT;
     
     -- Declare cursor for table names
     DECLARE partition_cursor CURSOR FOR
     SELECT partition_name
       FROM information_schema.partitions
      WHERE table_schema = p_database
        AND table_name = my_table;

     -- Declare NOT FOUND handler
     DECLARE CONTINUE HANDLER FOR NOT FOUND SET partitions_done = 1;

     SET partitions_done = 0;

     -- Open the cursor
     OPEN partition_cursor;

     partition_loop: LOOP
      FETCH partition_cursor INTO var_partition_name;
      IF (partitions_done = 1) THEN
        LEAVE table_loop;
      END IF;

      IF (p_mode = 1) THEN -- Optimize
        SET @q = CONCAT('ALTER TABLE ', p_database, '.', my_table, ' OPTIMIZE PARTITION ', var_partition_name);
      ELSE -- Analyze
        SET @q = CONCAT('ALTER TABLE ', p_database, '.', my_table, ' ANALYZE PARTITION ', var_partition_name);
      END IF;

      -- Start log statement
      INSERT INTO tb_maintenance_log (db, statement, started)
      VALUES (p_database, @q, NOW());

      SET @id = LAST_INSERT_ID();

      PREPARE stmt FROM @q;
      EXECUTE stmt;

      -- End log statement
      UPDATE tb_maintenance_log
         SET finished = NOW()
       WHERE id = @id;

     END LOOP partition_loop;

     -- Close the cursor
     CLOSE partition_cursor;
     END;
     END IF;

    END LOOP table_loop;

    -- Close the cursor
    CLOSE table_cursor;

    -- Purge old records from the tb_maintenance_log table
    DELETE
      FROM tb_maintenance_log
     WHERE started < DATE_SUB(NOW(), INTERVAL 15 DAY);

END$$

DELIMITER ;

GRANT SELECT, INSERT, UPDATE, DELETE ON `db_maintenance`.* TO 'usr_maintenance'@'%';
GRANT EXECUTE ON PROCEDURE `db_maintenance`.`prc_maintenance` TO 'usr_maintenance'@'%';

# Run OPTIMIZE TABLE
CALL `prc_maintenance`(1, 'db_1');
CALL `prc_maintenance`(1, 'db_2');
# Run ANALYZE TABLE
CALL `prc_maintenance`(2, 'db_1');
CALL `prc_maintenance`(2, 'db_2');
