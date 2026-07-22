# Banco de Dados e Análise de Despesas da ANS

Este projeto corresponde à etapa de banco de dados e análise de um teste técnico para estágio.

Os scripts criam uma estrutura no MySQL, importam arquivos CSV relacionados às operadoras de planos de saúde e executam consultas analíticas sobre as despesas registradas.

## Sobre o projeto

O objetivo desta etapa é armazenar e analisar os dados produzidos nas etapas anteriores do teste.

O projeto utiliza três arquivos CSV:

* `Relatorio_cadop.csv`, com os dados cadastrais das operadoras;
* `consolidado.csv`, com as despesas separadas por operadora e trimestre;
* `despesas_agregadas.csv`, com os totais, médias e desvios padrão calculados anteriormente.

Foram implementados scripts para:

* criar o banco de dados e suas tabelas;
* importar os arquivos CSV;
* tratar e converter os dados antes de inseri-los nas tabelas finais;
* relacionar despesas e operadoras;
* executar as três consultas analíticas solicitadas.

## Funcionalidades implementadas

* Criação do banco `teste_intuitive_care`;
* Configuração do banco para utilizar `utf8mb4`;
* Criação de tabelas de staging para receber os dados brutos;
* Criação de tabelas finais normalizadas;
* Definição de chaves primárias e estrangeiras;
* Definição de restrições para evitar CNPJs, Registros ANS e períodos duplicados;
* Criação de índices para UF, período e total de despesas;
* Importação dos três arquivos CSV com `LOAD DATA LOCAL INFILE`;
* Remoção de espaços extras com `TRIM`;
* Conversão de anos e trimestres para números;
* Conversão de valores monetários para `DECIMAL`;
* Relacionamento das despesas consolidadas com operadoras pelo CNPJ;
* Relacionamento das despesas agregadas com operadoras pelo Registro ANS;
* Consulta das cinco operadoras com maior crescimento percentual;
* Consulta dos cinco estados com maiores despesas totais;
* Cálculo da média de despesas por operadora em cada UF;
* Contagem das operadoras acima da média geral em pelo menos dois trimestres.


## Estrutura do projeto

```text
.
├── recursos/
│   ├── Relatorio_cadop.csv
│   ├── consolidado.csv
│   └── despesas_agregadas.csv
├── 01_criacao_tabelas.sql
├── 02_importacao_dados.sql
├── 03_queries_analiticas.sql
└── README.md
```

### `01_criacao_tabelas.sql`

Cria o banco de dados, as tabelas de staging, as tabelas finais, as chaves e os índices.

### `02_importacao_dados.sql`

Importa os CSVs para as tabelas de staging e transfere os registros tratados para as tabelas finais.

### `03_queries_analiticas.sql`

Contém as três consultas solicitadas para análise das despesas.

### `recursos/`

Contém os arquivos CSV usados pelos scripts de importação.

## Como executar

### Pré-requisitos

* MySQL 8.0 instalado;
* MySQL Workbench ou outro cliente capaz de executar scripts MySQL;
* Permissão para criar bancos e tabelas;
* Opção `LOCAL INFILE` habilitada.

### 1. Abrir a conexão com o MySQL

Abra o MySQL Workbench e conecte-se à instância local do MySQL.

### 2. Habilitar o `LOCAL INFILE`

Verifique o estado da configuração:

```sql
SHOW GLOBAL VARIABLES LIKE 'local_infile';
```

Caso o resultado esteja como `OFF`, execute com um usuário que possua permissão administrativa:

```sql
SET GLOBAL local_infile = 1;
```

No MySQL Workbench, também pode ser necessário editar a conexão e adicionar o seguinte valor na aba `Advanced`, no campo `Others`:

```text
OPT_LOCAL_INFILE=1
```

Depois de alterar a conexão, feche e abra novamente o MySQL Workbench.

### 3. Ajustar os caminhos dos CSVs

Abra o arquivo `02_importacao_dados.sql` e altere os caminhos usados nos comandos `LOAD DATA LOCAL INFILE`.

Exemplo:

```sql
LOAD DATA LOCAL INFILE
'C:/Repository/IC-3-TESTE-BANCO-DE-DADOS/recursos/Relatorio_cadop.csv'
```

O caminho deve apontar para a localização real dos arquivos no computador.

No Windows, os caminhos foram escritos com `/`.

### 4. Criar o banco e as tabelas

Execute:

```text
01_criacao_tabelas.sql
```

Esse script cria o banco:

```text
teste_intuitive_care
```

Também são criadas as tabelas:

```text
stg_operadoras
stg_despesas_consolidadas
stg_despesas_agregadas
operadoras
despesas_consolidadas
despesas_agregadas
```

### 5. Importar os dados

Execute:

```text
02_importacao_dados.sql
```

O script primeiro importa os CSVs para as tabelas de staging. Depois, os dados válidos são convertidos e inseridos nas tabelas finais.

### 6. Executar as consultas

Execute:

```text
03_queries_analiticas.sql
```

Os resultados serão exibidos no próprio cliente SQL.

Esta etapa não gera um novo arquivo de saída. Os dados ficam armazenados nas tabelas do banco.

## Fluxo de funcionamento

1. O banco e as tabelas são criados pelo primeiro script.
2. Os três arquivos CSV são importados para tabelas de staging.
3. As tabelas de staging mantêm os dados recebidos inicialmente como texto.
4. Os campos obrigatórios vazios são filtrados antes da carga final.
5. Os anos, trimestres e valores monetários são convertidos para os tipos definidos nas tabelas finais.
6. Os dados cadastrais são inseridos na tabela `operadoras`.
7. As despesas consolidadas são relacionadas às operadoras pelo CNPJ.
8. As despesas agregadas são relacionadas às operadoras pelo Registro ANS.
9. As consultas analíticas utilizam as tabelas finais para calcular os resultados.

## Decisões técnicas

### Estrutura normalizada

**Escolha:** foram criadas tabelas separadas para operadoras, despesas consolidadas e despesas agregadas.

**Motivo:** os dados cadastrais de uma operadora não precisam ser repetidos em cada linha de despesa.

**Ponto positivo:** reduz a repetição de CNPJ, razão social, modalidade e UF.

**Limitação:** as consultas precisam utilizar `JOIN` para acessar dados que estão em tabelas diferentes.

### Uso de tabelas de staging

**Escolha:** os CSVs são importados primeiro para tabelas com o prefixo `stg_`.

**Motivo:** essas tabelas recebem os dados brutos antes das conversões e validações da carga final.

**Ponto positivo:** permite manter os dados originais mesmo quando uma linha não pode ser inserida na tabela final.

**Limitação:** aumenta a quantidade de tabelas e exige uma segunda etapa de inserção.

### Valores monetários com `DECIMAL`

**Escolha:** os valores financeiros são armazenados como `DECIMAL(18, 2)`.

**Motivo:** `DECIMAL` mantém duas casas decimais e evita as aproximações que podem acontecer com tipos como `FLOAT`.

**Ponto positivo:** é mais adequado para somas, médias e comparações de valores monetários.

**Limitação:** o tamanho foi definido para o volume atual dos dados e pode precisar ser revisto em outro contexto.

### Representação do período

**Escolha:** o período foi separado nas colunas `ano` e `trimestre`, ambas do tipo `INT`.

**Motivo:** os arquivos utilizados representam períodos trimestrais, e não datas e horários completos.

**Ponto positivo:** facilita filtros e agrupamentos por ano e trimestre.

**Limitação:** a estrutura não representa uma data completa e depende de valores de trimestre entre 1 e 4.

### Relacionamento entre as tabelas

**Escolha:** as tabelas de despesas armazenam o campo `operadora_id`, que referencia a tabela `operadoras`.

**Motivo:** o identificador interno evita repetir o CNPJ ou o Registro ANS em todas as despesas.

**Ponto positivo:** mantém os dados cadastrais concentrados em uma única tabela.

**Limitação:** registros sem correspondência no cadastro não entram nas tabelas finais de despesas, pois o carregamento utiliza `JOIN`.

### Índices

**Escolha:** foram criados índices para UF, período e total de despesas.

**Motivo:** esses campos são usados nos filtros, agrupamentos e ordenações das consultas analíticas.

**Ponto positivo:** podem ajudar o banco a localizar os dados utilizados nas consultas.

**Limitação:** índices ocupam espaço adicional e também precisam ser atualizados durante inserções.

### Operadoras sem todos os períodos na Query 1

**Escolha:** somente operadoras com dados no primeiro e no último trimestre analisado participam do cálculo de crescimento.

**Motivo:** o crescimento percentual precisa de um valor inicial e um valor final comparáveis.

**Ponto positivo:** evita considerar um período ausente como zero e evita divisão por zero.

**Limitação:** operadoras com dados em apenas um dos períodos são retiradas do resultado.

### Estratégia da Query 3

**Escolha:** uma subconsulta calcula a média geral de cada trimestre. Depois, cada despesa é comparada com a média do mesmo período.

**Motivo:** essa estrutura evita criar uma consulta diferente para cada trimestre.

**Ponto positivo:** mantém a consulta dividida em etapas que podem ser identificadas no próprio SQL.

**Limitação:** a consulta possui subconsultas e agrupamentos, sendo mais complexa que as outras duas consultas.

## Tratamento de inconsistências

### Campos obrigatórios vazios

Os dados são importados normalmente para as tabelas de staging.

Antes da inserção nas tabelas finais, condições como esta são utilizadas:

```sql
WHERE TRIM(campo) <> ''
```

Linhas sem os campos obrigatórios não são inseridas nas tabelas finais.

Essa abordagem mantém o dado bruto na staging, mas evita utilizá-lo nas análises.

### Espaços extras

Foi utilizado `TRIM` para remover espaços no início e no final dos campos antes das comparações e inserções.

### Campos numéricos recebidos como texto

As tabelas de staging armazenam ano, trimestre e valores como `VARCHAR`.

Na transferência para as tabelas finais, foi utilizado `CAST`.

Exemplo:

```sql
CAST(TRIM(valor_despesas) AS DECIMAL(18, 2))
```

### Formato do trimestre

Valores como:

```text
4º Trimestre
```

são convertidos para o número `4` por meio de:

```sql
CAST(LEFT(TRIM(trimestre), 1) AS UNSIGNED)
```

### Registros sem correspondência cadastral

As despesas consolidadas são relacionadas às operadoras pelo CNPJ.

As despesas agregadas são relacionadas pelo Registro ANS.

Como os scripts utilizam `JOIN`, registros sem uma correspondência na tabela `operadoras` não são inseridos nas tabelas finais de despesas.

### Encoding

Os comandos de importação utilizam:

```sql
CHARACTER SET utf8mb4
```

Isso permite carregar razões sociais e outras informações com acentos.

## Limitações atuais

* Os caminhos dos arquivos CSV estão escritos diretamente no script de importação e precisam ser ajustados em outro computador.
* O uso de `LOAD DATA LOCAL INFILE` depende da configuração do servidor e do cliente MySQL.
* Os scripts de carga foram preparados para execução em um banco vazio. Executá-los novamente pode causar erros de duplicidade por causa das restrições `UNIQUE`.
* A Query 1 utiliza diretamente o 3º trimestre de 2025 como período inicial e o 1º trimestre de 2026 como período final.
* O trimestre é identificado pelo primeiro caractere do texto. A conversão depende de formatos como `1º Trimestre` até `4º Trimestre`.
* Strings numéricas não vazias, mas com formato inválido, não possuem uma validação específica antes do `CAST`.
* Os dados cadastrais completos permanecem na staging. A tabela final `operadoras` mantém somente Registro ANS, CNPJ, razão social, modalidade e UF.

## Possíveis melhorias

* Uma possível melhoria seria permitir a configuração dos caminhos dos CSVs sem editar diretamente o script.
* O projeto poderia identificar automaticamente o primeiro e o último trimestre disponíveis na Query 1.
* Uma possível melhoria seria validar explicitamente textos numéricos antes de executar o `CAST`.
* Os scripts de importação poderiam ser adaptados para permitir novas execuções sem gerar duplicidades.
* Poderia ser criado um script separado para limpar ou recriar o banco durante os testes.

## Autor

Ronaldo Dutra Filho
