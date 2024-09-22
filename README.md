# Projeto de BI: Análise de Dados de Partidas de Futebol com API-Sports, Google BigQuery e Power BI

## 1. Introdução - Visão Geral

Este projeto tem como objetivo a extração de dados de partidas de futebol da Liga dos Campeões usando a API-Sports, o armazenamento e processamento dos dados no Google BigQuery, e a realização de análises no Power BI. O foco principal é treinar habilidades de extração de dados de uma API usando Python, popular os dados em um Banco de Dados e usar SQL para o tratamento dos dados e análisar os resultados das partidas com Power BI para gerar insights sobre desempenho e tendências.

### 1.1 Fluxo de Trabalho

1. **Python - Coleta de dados via API**: Extração dos dados das partidas de futebol a API Sports.
2. **Armazenamento no Google BigQuery**: Carregamento desses dados no Google BigQuery para realizar as transformações necessárias.
3. **SQL - ETL no Google BigQuery**: As transformações dos dados foram realizadas utilizando SQL, agregando e processando os dados para análise posterior.
4. **Visualização no Power BI**: Os dados transformados no Google BigQuery são processados,visualizados e analisados no Power BI, com a criação do dashboard interativo.


## 2. Tecnologias Utilizadas

- **API-Sports:** Fonte de dados para fixtures (partidas) e estatísticas de futebol.
- **Google BigQuery:** Plataforma de armazenamento e processamento de dados.
- **Power BI:** Ferramenta de visualização para análise de dados.
- **Python:** Linguagem usada para a automação do processo de ETL (Extração, Transformação e Carga).

## 3. Etapas do Projeto

- 3.1 Extração de Dados
- 3.2 Carga para o Google BigQuery
- 3.3 ETL (Transformação)

- **API:** [API-Sports](https://www.api-football.com/documentation-v3)
- **Método de extração:** Requisição HTTP (GET)
- **Cabeçalho da requisição:**
    ```python
    HEADERS = {
        'x-rapidapi-key': API_KEY
    }
    ```
- **EndPoints principais:**
    - **past_fixtures:** Para obter partidas passadas.
    - **future_fixtures:** Para obter partidas futuras.
    ```python
    endpoints = [
        {
            "table": "past_fixtures",
            "path": "fixtures",
            "params": {
                "league": LEAGUE,
                "season": SEASON
            }
        },
        {
            "table": "future_fixtures",
            "path": "fixtures",
            "params": {
                "league": LEAGUE,
                "season": SEASON
            }
        }
    ]
    ```

### 3.2 Carga para o Google BigQuery

- **Projeto:** `jopecasports`
- **Dataset:** `soccer_analysis`
- **Formato dos dados:** JSON
- **Processo de carga:** Utilização da biblioteca `google.cloud.bigquery` para enviar dados para as tabelas do BigQuery.
    ```python
    from google.cloud import bigquery
    
    client = bigquery.Client(project=PROJECT_ID)
    def load_data_to_bigquery(client, dataset_name, table_name, dataframe, write_disposition):
        job_config = bigquery.LoadJobConfig(
            write_disposition=write_disposition
        )
        table_id = f"{PROJECT_ID}.{dataset_name}.{table_name}"
        load_job = client.load_table_from_dataframe(dataframe, table_id, job_config=job_config)
        load_job.result()  # Espera até que o job seja concluído
    ```

### 3.3 ETL (Transformação)

- **Transformações aplicadas:**
  - Atualização de parâmetros para cargas incrementais.
  - Filtragem de dados para carregar apenas informações novas (incremental load).
    ```python
    def incremental_params_update(table, params, last_update, now):
        if table == "past_fixtures":
            params.update({
                'from': last_update.strftime('%Y-%m-%d'),
                'to': (now - timedelta(days=1)).strftime('%Y-%m-%d')
            })
        elif table == "future_fixtures":
            params.update({
                'from': now.strftime('%Y-%m-%d')
            })
        return params
    ```

### ETL Queries no Google BigQuery

#### 1. **vw_jogos_fora**

Essa query seleciona informações de partidas onde o time jogou como visitante (fora de casa). Ela extrai dados como o nome do juiz, data da partida, status, temporada, time visitante e estatísticas de gols por períodos (primeiro tempo, segundo tempo, prorrogação, penalti).

- **Tabela de origem:** `soccer_analysis.past_fixtures`
- **Campos principais:** `jogo_id`, `juiz_nome`, `data`, `status_id`, `time_id`, `gols`, `gols_primeiroTempo`, `gols_segundoTempo`, etc.
- **Filtro:** Partidas onde o time jogou fora de casa (campo fixo `'Fora'`).

#### 2. **vw_jogos_casa**

Essa query seleciona informações de partidas onde o time jogou como mandante (casa). Ela é semelhante à `vw_jogos_fora`, mas captura os dados do time que jogou em casa.

- **Tabela de origem:** `soccer_analysis.past_fixtures`
- **Campos principais:** `jogo_id`, `juiz_nome`, `data`, `status_id`, `time_id`, `gols`, `gols_primeiroTempo`, `gols_segundoTempo`, etc.
- **Filtro:** Partidas onde o time jogou em casa (campo fixo `'Casa'`).

#### 3. **vw_jogos**

Esta query une os resultados das views `vw_jogos_casa` e `vw_jogos_fora` utilizando a cláusula `UNION ALL`, combinando as informações de todas as partidas, independente de serem jogadas em casa ou fora.

- **Tabelas de origem:** `view_soccer_analysis.vw_jogos_casa` e `view_soccer_analysis.vw_jogos_fora`
- **Resultado:** Combina os dados de todas as partidas, sejam jogadas em casa ou fora.

#### 4. **vw_status**

Essa query busca os diferentes status de uma partida (curto e longo), como por exemplo "Concluída" ou "Em andamento", evitando duplicidade de status.

- **Tabela de origem:** `soccer_analysis.past_fixtures`
- **Campos principais:** `status_id`, `status_nome`

#### 5. **vw_equipes**

Essa query seleciona informações distintas sobre as equipes, como o nome, o logo e o ID. Ela evita duplicidade de times ao usar `DISTINCT`.

- **Tabela de origem:** `view_soccer_analysis.vw_todos_jogos`
- **Campos principais:** `time_id`, `time_nome`, `time_logoUrl`

#### 6. **vw_estadios**

Essa query extrai informações distintas sobre os estádios, como o nome do estádio e a cidade. Apenas estádios com ID definido são considerados.

- **Tabela de origem:** `soccer_analysis.past_fixtures`
- **Campos principais:** `estadio_id`, `estadio_nome`, `estadio_nomeCidade`
- **Filtro:** `estadio_id IS NOT NULL`

#### 7. **vw_estatisticas**

Essa query agrupa e processa as estatísticas das partidas (como chutes a gol, posse de bola, faltas, cartões) a partir dos dados brutos na tabela `fixturesStatistics`. Os dados são processados por time e partida.

- **Tabela de origem:** `soccer_analysis.fixturesStatistics`
- **Campos principais:** `jogo_id`, `team_id`, `team_name`, `chutes_aGol`, `posseDeBola`, `passes_total`, etc.
- **Operações:** Uso de agregações (`MAX`) para capturar as estatísticas específicas, como chutes e posse de bola.

#### 8. **vw_estatisticas_jogo**

Essa query junta as estatísticas das partidas com as informações básicas de cada jogo. Utiliza um `LEFT JOIN` para conectar as estatísticas da view `vw_estatisticas` com os dados dos jogos da view `vw_todos_jogos`.

- **Tabelas de origem:** `view_soccer_analysis.vw_todos_jogos` e `view_soccer_analysis.vw_estatisticas`
- **Campos principais:** `jogo_id`, `data`, `hora`, `time_nome`, `gols`, `chutes_aGol`, `faltas`, `posseDeBola`, etc.
- **Join:** `LEFT JOIN` entre as tabelas com base no `jogo_id` e `team_id`.

### 3.4 Análise no Power BI

- **Objetivo da análise:** Visualizar os dados de partidas passadas e futuras para acompanhar o desempenho das equipes ao longo da temporada.
- **Principais métricas analisadas:**
  - Partidas jogadas.
  - Resultados das partidas (vitórias, empates, derrotas).
  - Estatísticas individuais de jogadores.
  
- **Visualizações criadas:**
  - Gráfico de linha para acompanhar a evolução dos resultados ao longo da temporada.
  - Tabelas dinâmicas para filtrar os resultados por liga, time e jogador.
  - Mapas para visualizar a distribuição das partidas por região geográfica.

## 4. Resultados

As análises permitiram identificar padrões de desempenho dos times ao longo da temporada. Com as visualizações no Power BI, foi possível gerar relatórios dinâmicos que facilitam o entendimento dos resultados e permitem prever o desempenho futuro com base nas tendências passadas.

## 5. Conclusão

Este projeto demonstrou a eficiência da integração de uma API de esportes com o Google BigQuery e Power BI para realizar análises avançadas de dados esportivos. A implementação do processo de ETL possibilitou a atualização contínua dos dados e facilitou a criação de relatórios dinâmicos para insights rápidos e precisos.

## 6. Referências

- [Documentação da API-Sports](https://www.api-football.com/documentation-v3)
- [Google BigQuery Documentation](https://cloud.google.com/bigquery/docs)
- [Power BI](https://powerbi.microsoft.com/)


