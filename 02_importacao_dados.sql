USE teste_intuitive_care;

LOAD DATA LOCAL INFILE 'C:/Repository/IC-3-TESTE-BANCO-DE-DADOS/recursos/Relatorio_cadop.csv'
INTO TABLE stg_operadoras
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Repository/IC-3-TESTE-BANCO-DE-DADOS/recursos/consolidado.csv'
INTO TABLE stg_despesas_consolidadas
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Repository/IC-3-TESTE-BANCO-DE-DADOS/recursos/despesas_agregadas.csv'
INTO TABLE stg_despesas_agregadas
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

INSERT INTO operadoras(
registro_ans,
cnpj,
razao_social,
modalidade,
uf
)
SELECT 
	TRIM(registro_operadora),
	TRIM(cnpj),
	TRIM(razao_social),
	TRIM(modalidade),
	TRIM(uf)
FROM stg_operadoras
WHERE TRIM(registro_operadora) <> ''
AND TRIM(cnpj) <> ''
AND TRIM(razao_social) <> ''
AND TRIM(modalidade) <> ''
AND TRIM(uf) <> '';

INSERT INTO despesas_consolidadas(
operadora_id,
ano,
trimestre,
valor_despesas
)
SELECT
	o.id,
	CAST(TRIM(s.ano) AS UNSIGNED),
	CAST(LEFT(TRIM(s.trimestre),1) AS UNSIGNED),
	CAST(TRIM(s.valor_despesas) AS DECIMAL(18,2))
FROM stg_despesas_consolidadas s
JOIN operadoras o
	ON o.cnpj = TRIM(s.cnpj)
WHERE TRIM(s.ano) <> ''
AND TRIM(s.trimestre) <> ''
AND TRIM(s.valor_despesas) <> '';

INSERT INTO despesas_agregadas(
operadora_id,
total_despesas,
media_despesas_trimestre,
desvio_padrao
)
SELECT
	o.id,
	CAST(TRIM(s.total_despesas) AS DECIMAL(18,2)),
	CAST(TRIM(s.media_despesas_trimestre) AS DECIMAL(18,2)),
	CAST(TRIM(s.desvio_padrao)AS DECIMAL(18,2))
FROM stg_despesas_agregadas s 
JOIN operadoras o
	ON o.registro_ans = TRIM(s.registro_ans)
WHERE TRIM(s.total_despesas) <> ''
AND TRIM(s.media_despesas_trimestre) <> ''
AND TRIM(s.desvio_padrao) <> '';