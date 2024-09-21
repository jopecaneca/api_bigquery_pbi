SELECT DISTINCT
    estadio_id,
    estadio_nome,
    estadio_nomeCidade
FROM (
    SELECT 
        CAST(fixture__venue__id AS STRING) as estadio_id, 
        fixture__venue__name as estadio_nome, 
        fixture__venue__city as estadio_nomeCidade
    FROM
        `soccer_analysis.past_fixtures`
)
WHERE
    estadio_id IS NOT NULL