WITH stats_aggregated AS (
  SELECT
    SAFE_CAST(fixture AS STRING) as jogo_id,
    SAFE_CAST(team__id AS STRING) as team_id,
    team__logo as team_logo,
    team__name as team_name,
    ARRAY_AGG(STRUCT(statistics.value, statistics.type)) as stats_array
  FROM
    `soccer_analysis.fixturesStatistics`
  CROSS JOIN
    UNNEST(statistics) as statistics
  GROUP BY
    jogo_id,
    team_id,
    team_logo,
    team_name
)

SELECT
  jogo_id,
  team_id,
  team_logo,
  team_name,
  MAX(SAFE_CAST(CASE WHEN stat.type = 'Shots on Goal' THEN stat.value ELSE NULL END AS INT64)) AS chutes_aGol,
  MAX(SAFE_CAST(CASE WHEN stat.type = 'Shots off Goal' THEN stat.value ELSE NULL END AS INT64)) AS chutes_foraDoGol,
  MAX(SAFE_CAST(CASE WHEN stat.type = 'Total Shots' THEN stat.value ELSE NULL END AS INT64)) AS chutes_total,
  MAX(SAFE_CAST(CASE WHEN stat.type = 'Blocked Shots' THEN stat.value ELSE NULL END AS INT64)) AS chutes_bloqueados,
  MAX(SAFE_CAST(CASE WHEN stat.type = 'Shots insidebox' THEN stat.value ELSE NULL END AS INT64)) AS chutes_dentroDaArea,
  MAX(SAFE_CAST(CASE WHEN stat.type = 'Shots outsidebox' THEN stat.value ELSE NULL END AS INT64)) AS chutes_foraDaArea,
  MAX(SAFE_CAST(CASE WHEN stat.type = 'Fouls' THEN stat.value ELSE NULL END AS INT64)) AS faltas,
  MAX(SAFE_CAST(CASE WHEN stat.type = 'Corner Kicks' THEN stat.value ELSE NULL END AS INT64)) AS escanteios,
  MAX(SAFE_CAST(CASE WHEN stat.type = 'Offsides' THEN stat.value ELSE NULL END AS INT64)) AS impedimentos,
  MAX(SAFE_CAST(CASE WHEN stat.type = 'Ball Possession' THEN REPLACE(stat.value, '%', '') ELSE NULL END AS FLOAT64)) AS posseDeBola,  -- Assuming percentage is stored as string with '%'
  MAX(SAFE_CAST(CASE WHEN stat.type = 'Yellow Cards' THEN stat.value ELSE NULL END AS INT64)) AS cartoes_amarelos,
  MAX(SAFE_CAST(CASE WHEN stat.type = 'Red Cards' THEN stat.value ELSE NULL END AS INT64)) AS cartoes_vermelhos,
  MAX(SAFE_CAST(CASE WHEN stat.type = 'Goalkeeper Saves' THEN stat.value ELSE NULL END AS INT64)) AS defesasDoGoleiro,
  MAX(SAFE_CAST(CASE WHEN stat.type = 'Total passes' THEN stat.value ELSE NULL END AS INT64)) AS passes_total,
  MAX(SAFE_CAST(CASE WHEN stat.type = 'Passes accurate' THEN stat.value ELSE NULL END AS INT64)) AS passes_finalizados,
  MAX(SAFE_CAST(CASE WHEN stat.type = 'Passes %' THEN REPLACE(stat.value, '%', '') ELSE NULL END AS FLOAT64)) AS passes_precisao,  -- Assuming percentage is stored as string with '%'
  MAX(SAFE_CAST(CASE WHEN stat.type = 'expected_goals' THEN stat.value ELSE NULL END AS FLOAT64)) AS gols_esperados
FROM
  stats_aggregated,
  UNNEST(stats_array) as stat
GROUP BY
  jogo_id,
  team_id,
  team_logo,
  team_name