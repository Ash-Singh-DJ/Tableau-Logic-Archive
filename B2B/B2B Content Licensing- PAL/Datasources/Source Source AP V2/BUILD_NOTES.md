# Source Source AP V2

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Content Licensing- PAL / Datasources |
| Owner | James Thomson |
| Created | 2025-11-06 |
| Last updated | 2026-04-07 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/108638150 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Join of 7 tables -- Athena + BigQuery + Google Drive Excel + Excel file
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); BigQuery; Excel file; Google Drive Excel
- **Structure:**

```
- LEFT JOIN on [Sources].[Source Code] = [Dashboard 2025-09-19].[Source Code (sc)]
  - LEFT JOIN on [Sources].[Contract ID] = [Sources1].[Contract ID]
    - LEFT JOIN on [Sources].[Source Code] = [Bands].[Source Code]
      - LEFT JOIN on [Sources].[Source Code] = [Article Views].[Source_Code]
        - LEFT JOIN on [Sources].[Source Code] = [Rights Pivot].[Source Code (sc)]
          - LEFT JOIN on [Sources].[Source Code] = [VI Score].[SourceCode]
            - Google Drive Excel "Active Sources Addressable Market" table Sources$ (as "Sources")
            - BigQuery wildcard union "VI Score"
          - Google Drive Excel "GenAI Rights 2 JT" table Rights Pivot$ (as "Rights Pivot")
        - Athena Custom SQL "Article Views" -> Article Views.sql
      - Google Drive Excel "Band Look up" table Bands$ (as "Bands")
    - Google Drive Excel "IP Level JT Copy" table Sources$ (as "Sources1")
  - Excel file "Data for Tableau Factiva Source Dashboard 2024-03-06 v2" table Dashboard 2025-09-19$ (as "Dashboard 2025-09-19")
```
- **Athena tables read:** `fact_external_db.omniture_event_fact`, `pib_event_data.pib_product_metrics`
- **SQL files:** [Article Views.sql](Article%20Views.sql)

## Connected workbooks

_No connected workbooks found._
