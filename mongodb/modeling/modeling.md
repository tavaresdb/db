# Modelagem de dados
Regra de ouro: [i]"Dados que são acessados juntos, devem permanecer juntos".

## Metodologia ref. modelagem de dados
### Workload

- Identificar as entidades e quantificar o número de itens que serão gerados;

- Determinar as operações de leitura e gravação associadas às entidades com base em como o aplicativo funcionará;

- Identificar a frequência das operações de leitura e gravação.

### Relationships

- 1:1 - Normalmente a relação é construída via subdocumento, entretanto é importante considerar algumas diretrizes, como as que serão mencionadas à seguir. O [vídeo](https://fast.wistia.net/embed/iframe/wbfgot8mvy) também poderá trazer uma maior clareza;

- 1:N - Normalmente a relação é construída via array de documentos, entretanto é importante considerar algumas diretrizes, como as que serão mencionadas à seguir. O [vídeo](https://fast.wistia.net/embed/iframe/qwoalb2egn) também poderá trazer uma maior clareza;

- N:N - Normalmente duas coleções compartilham um atributo em comum, sendo este atributo um array de referências (Isso pode ser feito do lado 'pai' ou 'filho'). O [vídeo](https://fast.wistia.net/embed/iframe/nvtv0gplkh) também poderá trazer uma maior clareza, além das diretrizes mencionadas logo abaixo.


|Diretriz                   |Pergunta                                                                                            |Incorporar|Referenciar|
|---------------------------|----------------------------------------------------------------------------------------------------|----------|-----------|
|Simplicidade               |Manter as informações juntas levaria a um modelo de dados e código mais simples?                    |Sim       |Não        |
|Vão Juntas                 |As informações têm um relacionamento "tem-um", "contém" ou semelhante?                              |Sim       |Não        |
|Atomicidade da Query       |O aplicativo consulta as informações juntas?                                                        |Sim       |Não        |
|Complexidade de Atualização|As informações são atualizadas em conjunto?                                                         |Sim       |Não        |
|Arquivamento               |As informações devem ser arquivadas ao mesmo tempo?                                                 |Sim       |Não        |
|Cardinalidade              |Existe uma alta cardinalidade (atual ou crescente) no lado 'filho' do relacionamento?               |Não       |Sim        |
|Duplicação de Dados        |A duplicação de dados seria muito complicada e indesejada de gerenciar?                             |Não       |Sim        |
|Tamanho do Documento       |O tamanho combinado das informações consumiria muita memória ou tráfego pela rede para o aplicativo?|Não       |Sim        |
|Crescimento do Documento   |A parte incorporada (embedded) crescerá sem limites?                                                |Não       |Sim        |
|Carga de Trabalho          |As informações são escritas em momentos diferentes em uma carga de trabalho com muita gravação?     |Não       |Sim        |
|Individualidade            |Para o lado ‘filho' do relacionamento, as peças podem existir por si mesmas, sem um 'pai’?          |Não       |Sim        |

![](img/modeling.png)

### Padrões de Design de Esquema (Design Patterns)
- [Building with Patterns: A Summary](https://www.mongodb.com/blog/post/building-with-patterns-a-summary/)
- [Building with Patterns: The Polymorphic Pattern](https://www.mongodb.com/developer/products/mongodb/polymorphic-pattern/)
- [Building With Patterns: The Computed Pattern](https://www.mongodb.com/blog/post/building-with-patterns-the-computed-pattern/)
- [Building with Patterns: The Approximation Pattern](https://www.mongodb.com/blog/post/building-with-patterns-the-approximation-pattern/)
- [Building with Patterns: The Extended Reference Pattern](https://www.mongodb.com/blog/post/building-with-patterns-the-extended-reference-pattern/)
- [Building with Patterns: The Schema Versioning Pattern](https://www.mongodb.com/blog/post/building-with-patterns-the-schema-versioning-pattern/)
- [Single-Collection Designs in MongoDB with Spring Data](https://www.mongodb.com/developer/languages/java/java-single-collection-springpart1/)
- [Building with Patterns: The Subset Pattern](https://www.mongodb.com/blog/post/building-with-patterns-the-subset-pattern/)
- [Building with Patterns: The Bucket Pattern](https://www.mongodb.com/blog/post/building-with-patterns-the-bucket-pattern/)
- [Building With Patterns: The Outlier Pattern](https://www.mongodb.com/blog/post/building-with-patterns-the-outlier-pattern/)
- [A Summary of Schema Design Anti-Patterns and How to Spot Them](https://www.mongodb.com/developer/products/mongodb/schema-design-anti-pattern-summary/)

## Leitura complementar
- [A Comprehensive Guide To Data Modeling](https://www.mongodb.com/resources/basics/databases/data-modeling/)
- [Data Modeling](https://www.mongodb.com/pt-br/docs/manual/data-modeling/)
- [Embedded Data Versus References](https://www.mongodb.com/pt-br/docs/manual/data-modeling/concepts/embedding-vs-references/)
- [Schema Validation](https://www.mongodb.com/pt-br/docs/manual/core/schema-validation/)
- [Document Validation for Polymorphic Collections](https://www.mongodb.com/developer/products/mongodb/polymorphic-document-validation/)