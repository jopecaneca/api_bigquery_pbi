# Projeto de BI: Análise de Dados de Esportes com API-Sports, Google BigQuery e Power BI

## 1. Introdução

Este projeto tem como objetivo a extração de dados de partidas de futebol usando a **API-Sports**, o armazenamento e processamento desses dados no **Google BigQuery**, e a análise visual no **Power BI**. A proposta é gerar insights sobre o desempenho das equipes ao longo da temporada e prever tendências futuras com base em dados passados e estatísticas detalhadas.

## 2. Tecnologias Utilizadas

- **API-Sports:** Fonte de dados para fixtures (partidas) e estatísticas de futebol.
- **Google BigQuery:** Plataforma de armazenamento e processamento de dados em grande escala.
- **Power BI:** Ferramenta de visualização para análise de dados.
- **Python:** Automação do processo de ETL (Extração, Transformação e Carga).

## 3. Etapas do Projeto

### 3.1 Extração de Dados

A extração dos dados é feita via requisições HTTP (GET) para a API-Sports. São obtidos dados sobre partidas passadas e futuras:

- **API:** [API-Sports Documentation](https://www.api-football.com/documentation-v3)
- **EndPoints principais:**
  - **past_fixtures:** Para obter partidas passadas.
  - **future_fixtures:** Para obter partidas futuras.

Exemplo de requisição:
```
HEADERS = {
    'x-rapidapi-key': API_KEY
}

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

### 3.2 Carga de Dados no Google BigQuery
Os dados extraídos da API são armazenados no Google BigQuery, utilizando a biblioteca google.cloud.bigquery. Os dados são carregados no formato JSON e organizados em tabelas para análise posterior.

- Projeto: jopecasports
- Dataset: soccer_analysis



