# Importação e exportação de dados

## Inserção de dados a partir de um arquivo .csv
O comando abaixo importará os dados de um arquivo .csv para uma tabela no MySQL:

```sql
LOAD DATA INFILE '/var/lib/mysql-files/NASA_Facilities.csv'
INTO TABLE facilities FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
IGNORE 1 LINES
(center, center_search_status, facility, facility_url, occupied, status, url_link, @var_record_date, @var_last_update, country, contact, phone, location, city, state, zipcode)
SET record_date = IF(
  CHAR_LENGTH(@var_record_date)=0, NULL,
  STR_TO_DATE(@var_record_date, '%m/%d/%Y %h:%i:%s %p')
),
last_update = IF(
  CHAR_LENGTH(@var_last_update)=0, NULL,
  STR_TO_DATE(@var_last_update, '%m/%d/%Y %h:%i:%s %p')
);
```

> Pode ser útil executar antes a instrução `SELECT @@secure_file_priv`. Se definido um diretório, o MySQL irá limitar as operações de importação e exportação neste local. Para fins de teste, após baixar [este](https://github.com/learning-mysql-2nd/learning-mysql-2nd/blob/main/ch07/NASA_Facilities.csv) arquivo, o mesmo pode ser movido para o diretório retornado pela variável `secure_file_priv`.

## Exportação de dados para um arquivo .csv
```sql
SELECT *
  FROM table_name
  INTO OUTFILE '/var/lib/mysql-files/file.csv'
FIELDS TERMINATED BY ',' ENCLOSED BY '"';
```

# Referência
- Livro Learning MySQL: Get a Handle on Your Data (2nd Edition), por Vinicius M Grippa e Sergey Kuzmichev - Pg. 447-463