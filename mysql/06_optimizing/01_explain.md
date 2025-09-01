# Explain

## Formatos
- **Tradicional:** Apresenta a saída no formato tabular tradicional.
- **JSON:** Apresenta a saída no formato JSON e inclui estimativas de custo e número de linhas.
- **TREE:** Apresenta a saída em um formato semelhante a uma árvore e inclui estimativas de custo e número de linhas.

## Exemplo
```bash
mysql> EXPLAIN SELECT * FROM employees WHERE emp_no=10001\G
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: employees
   partitions: NULL
         type: const
possible_keys: PRIMARY
         key: PRIMARY
     key_len: 4
         ref: const
        rows: 1
     filtered: 100.00
        Extra: NULL
1 row in set, 1 warning (#.## sec)
```

## Saída
- **id:** Número que identifica a instrução analisada.
- **select_type:** Tipo de SELECT utilizado na consulta.
   - SIMPLE: A consulta não utiliza UNION, nem subconsultas.
   - Outros valores indicam o tipo UNION ou subconsulta.
   - Para comandos DML: INSERT, REPLACE, UPDATE e DELETE.
- **table:** Tabela associada a linha de saída.
- **partitions:** Partições que o otimizador precisa examinar para executar a consulta.
- **type:** Tipo de comparação de índice ou de junção.
- **possible_keys:** Índices que são relevantes para a consulta.
- **key:** Índice específico escolhido pelo otimizador.
- **key_len:** Tamanho em bytes das colunas usadas para pesquisar no índice.
- **ref:** Colunas (Ou const) comparadas com o índice.
- **rows:** Número estimado de linhas que o otimizador prevê que será retornado pela consulta.
- **filtered:** Porcentagem de linhas que são filtradas pela condição da tabela.
- **Extra:** Informações adicionais por consulta, fornecidas pelo otimizador ou pelo mecanismo de armazenamento.

## Valores comuns da coluna type
A coluna `type` indica o tipo de comparação utilizado pelo otimizador para acessar as linhas.

- **ALL:** Leitura completa da tabela (Full table scan).
- **index:** Leitura completa do índice (Full index scan).
- **const:** Comparação com uma chave primária ou única contra uma constante no início da consulta.
- **eq_ref:** Comparação com uma única linha referenciada (Identificada pela coluna ref) com igualdade.
- **ref:** Comparação com um ou mais valores referenciados com igualdade.
- **range:** Comparação de linhas dentro de um intervalo suportado pelo índice nomeado (Key).

## EXPLAIN ANALYZE
Permite gerar um plano para a consulta. A saída é semelhante ao formato TREE, entretanto são adicionadas estatísticas atuais, tais como: tempo para retornar a primeira linha em ms, tempo para retornar todas as linhas em ms, número de linhas retornadas pelo iterador e o número de loops. Por exemplo:

```bash
mysql> EXPLAIN ANALYZE SELECT emp_no FROM dept_manager WHERE dept_no='d001'\G
*************************** 1. row ***************************
EXPLAIN: -> Filter: (dept_manager.dept_no = 'd001') (cost=0.45 rows=2) (actual time=0.020..0.023 rows=2 loops=1)
  -> Index lookup on dept_manager using dept_no ('d001') (cost=0.45 rows=2) (actual time=0.017..0.020 rows=2 loops=1)
```

# Referência
- Curso MySQL 8.0 for Database Administrators, https://mylearn.oracle.com/ou/course/mysql-80-for-database-administrators/76889