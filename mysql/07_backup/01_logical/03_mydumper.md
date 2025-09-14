# Utilitário mydumper
A principal diferença entre esse método e o `mysqldump` é que `mydumper` e `myloader` permitem despejar e restaurar dados em paralelo, melhorando o tempo do dump e, especialmente, o tempo da restauração. Para obter maiores detalhes sobre o projeto, acesse [esse](https://github.com/mydumper/mydumper) repositório.

Sobre a instalação e uso dos utilitários, segue exemplo:

```bash
# Instalação do mydumper
release=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/mydumper/mydumper/releases/latest | cut -d'/' -f8)
yum install https://github.com/mydumper/mydumper/releases/download/${release}/mydumper-${release:1}.el7.x86_64.rpm

mydumper --version
myloader --version

# Dump de todos os bancos de dados, exceto mysql, sys e test, com 4 threads simultâneas, garantia de consistência transacional, inclusão de triggers, stored procedures, functions e events, e compressão do arquivo no formato .gzip
mydumper --regex '^(?!(mysql\.|sys\.|test\.))' --threads=4 --user=root --password='P@ssw0rd!' --host=ip_address --port=3306 --trx-consistency-only --triggers --routines --events --compress --outputdir /bkp --logfile /tmp/log.out --verbose=2

# Restauração dos dados
myloader --user=root --password='P@ssw0rd!' --threads=4 --host=ip_address --port=3306 --directory=/bkp --overwrite-tables --verbose 3
```

# Referência
- Livro Learning MySQL: Get a Handle on Your Data (2nd Edition), por Vinicius M Grippa e Sergey Kuzmichev - Pg. 824-826