# B2B Internal Usage Factiva Search Terms - Int search terms

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Product / Factiva / Datasources |
| Owner | Maria Peco |
| Created | 2025-07-29 |
| Last updated | 2026-05-05 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/121447637 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Custom SQL Query.sql
```
- **Athena tables read:** `pib_event_data.pib_platform_trace`
- **SQL files:** [Custom SQL Query.sql](Custom%20SQL%20Query.sql)

## Connected workbooks

- [B2B Internal User Factiva Search Terms](../../../../Factiva%20Legacy%20%28for%20review%29/B2B%20Internal%20User%20Factiva%20Search%20Terms) [B2B / Factiva Legacy (for review)]
