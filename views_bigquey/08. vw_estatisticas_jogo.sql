SELECT
    f.jogo_id,
    f.juiz_nome,
    DATE(f.data) AS data,
    TIME(f.data) AS hora,
    f.status_id,
    f.liga_id,
    CAST( f.temporada AS STRING) AS temporada,
    f.rodada,
    f.time_id,
    f.time_nome,
    f.time_logoUrl,
    CAST(f.time_vitoria AS STRING) as time_vitoria,
    f.gols,
    f.gols_primeiroTempo,
    f.gols_segundoTempo,
    f.gols_prorrogacao,
    f.gols_penalti,
    f.estadio_id,
    f.casaFora,
    s.chutes_aGol,
    s.chutes_foraDoGol,
    s.chutes_total,
    s.chutes_bloqueados,
    s.chutes_dentroDaArea,
    s.chutes_foraDaArea,
    s.faltas,
    s.escanteios,
    s.impedimentos,
    s.posseDeBola / 100 as posseDeBola,
    s.cartoes_amarelos,
    s.cartoes_vermelhos,
    s.defesasDoGoleiro,
    s.passes_total,
    s.passes_finalizados,
    s.passes_precisao,
    s.gols_esperados
FROM
    `view_soccer_analysis.vw_todos_jogos` f
LEFT JOIN
    `view_soccer_analysis.vw_estatisticas` s
ON
    f.jogo_id = s.jogo_id AND f.time_id = s.team_id;