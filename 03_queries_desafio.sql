USE teste_intuitive_care;

-- Query 1:

SELECT 
    o.razao_social,
    inicio.valor_despesas AS despesa_inicial,
    fim.valor_despesas AS despesa_final,
    ROUND(
        ((fim.valor_despesas - inicio.valor_despesas)
        / inicio.valor_despesas) * 100,
        2
    ) AS crescimento_percentual
FROM despesas_consolidadas AS inicio
JOIN despesas_consolidadas AS fim
    ON inicio.operadora_id = fim.operadora_id
JOIN operadoras AS o
    ON o.id = inicio.operadora_id
WHERE inicio.ano = 2025
  AND inicio.trimestre = 3
  AND fim.ano = 2026
  AND fim.trimestre = 1
  AND inicio.valor_despesas > 0
ORDER BY crescimento_percentual DESC
LIMIT 5;

-- Query 2:

SELECT 
    o.uf,
    ROUND(SUM(da.total_despesas), 2) AS total_despesas_uf,
    ROUND(AVG(da.total_despesas), 2) AS media_despesas_por_operadora
FROM despesas_agregadas AS da
JOIN operadoras AS o
    ON o.id = da.operadora_id
GROUP BY o.uf
ORDER BY total_despesas_uf DESC
LIMIT 5;

-- Query 3:

SELECT COUNT(*) AS quantidade_operadoras
FROM (
    SELECT
        dc.operadora_id
    FROM despesas_consolidadas AS dc
    JOIN (
        SELECT 
            ano,
            trimestre,
            AVG(valor_despesas) AS media_trimestre
        FROM despesas_consolidadas
        GROUP BY ano, trimestre
    ) AS medias
        ON medias.ano = dc.ano
       AND medias.trimestre = dc.trimestre
    WHERE dc.valor_despesas > medias.media_trimestre
    GROUP BY dc.operadora_id
    HAVING COUNT(*) >= 2
) AS operadoras_acima_media;