# Operações DDL online
Para maiores detalhes, consulte:

- Documentação Oficial MySQL, [Online DDL Operations](https://dev.mysql.com/doc/refman/8.0/en/innodb-online-ddl-operations.html) e [ALTER TABLE Statement](https://dev.mysql.com/doc/refman/8.0/en/alter-table.html).
- Artigo do Lefred, [MySQL InnoDB’s Instant Schema Changes](https://lefred.be/content/mysql-innodbs-instant-schema-changes-what-dbas-should-know/).
- Artigo do Mydbops, [An Overview of DDL Algorithm’s in MySQL](https://www.mydbops.com/blog/ddl-algorithms-in-mysql).

Os valores possíveis para `ALGORITHM` são:
- **COPY**: Altera o esquema da tabela existente criando uma nova tabela temporária com o esquema alterado - DML simultâneo não é suportado. Após migrar os dados completamente para a nova tabela temporária, ele troca e remove a tabela antiga.
- **INPLACE**: Executa operações in-place na tabela original e evita a cópia e reconstrução da tabela, sempre que possível - um bloqueio exclusivo de metadados na tabela pode ser realizado brevemente durante as fases de preparação e execução da operação e normalmente DML simultâneo é suportado.
- **INSTANT**: Esse recurso realiza alterações instantâneas e in-place na tabela e permite DML simultâneo com melhor capacidade de resposta e disponibilidade em ambientes críticos de produção - um bloqueio exclusivo de metadados na tabela pode ser realizado brevemente durante a fase de execução da operação. Se `ALGORITHM` não for especificado, o servidor tentará primeiro o algoritmo **INSTANT**. Se isso não for possível, o servidor tentará o algoritmo **INPLACE**. E se isso não for possível, o servidor tentará o algoritmo **COPY**.

Os valores possíveis para `LOCK` são:
- **DEFAULT**: Tenta ser o mais permissível possível.
- **NONE**: Permite leitura e escrita, se suportado.
- **SHARED**: Permite somente leitura, se suportado.
- **EXCLUSIVE**: Nenhuma operação é permitida.