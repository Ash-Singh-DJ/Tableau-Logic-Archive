# Src Breakdown

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Product / Factiva |
| Owner | James Thomson |
| Created | 2025-09-25 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/137890020 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Join of 2 tables
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / sandbox_mk)
- **Structure:**

```
- LEFT JOIN on [Custom SQL Query].[source_code] = [source_db_clean].[sourcecode]
  - Athena Custom SQL "Custom SQL Query" -> Custom SQL Query.sql
  - Athena table sandbox_mk.source_db_clean (as "source_db_clean")
```
- **Athena tables read:** `pib_event_data.pib_platform_trace`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `sandbox_mk.source_db_clean`
- **SQL files:** [Custom SQL Query.sql](Custom%20SQL%20Query.sql)

## Connected workbooks

- [B2B Factiva Gen AI Article Usage](../B2B%20Factiva%20Gen%20AI%20Article%20Usage) [B2B / B2B Product / Factiva]
