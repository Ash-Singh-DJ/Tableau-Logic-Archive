# B2B Licensing IP Level Data

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Content Licensing- PAL / Datasources |
| Owner | Porfirio Hernandez |
| Created | 2025-07-28 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/139060355 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Structure:**

```
- Athena Custom SQL "IP Level Data" -> IP Level Data.sql
```
- **Athena tables read:** `dimension_external_db.cdb_source_docs_current`, `dimension_external_db.ip_rights_data_current`, `dimension_external_db.royalty_monthly_payment_analysis`, `dimension_external_db.royalty_monthly_carry_forward_report`, `dimension_external_db.content_volumes`, `sandbox_mk.factiva_content_value_index_ui`, `sandbox_mk.rnc_value_index`
- **SQL files:** [IP Level Data.sql](IP%20Level%20Data.sql)

## Connected workbooks

- B2B Licensing Dashboard [B2B / B2B Content Licensing- PAL]
