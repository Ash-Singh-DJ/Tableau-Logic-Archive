# B2B Factiva Segments Client Insights - All Dates

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Product / Factiva / Datasources |
| Owner | Maria Peco |
| Created | 2025-07-29 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/95893387 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / zoolander_db)
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Custom SQL Query.sql
```
- **Athena tables read:** `zoolander_db.factiva_micro_user_seg_6mo`
- **SQL files:** [Custom SQL Query.sql](Custom%20SQL%20Query.sql)

## Connected workbooks

- [B2B Factiva Segments - Client Insights](../../Factiva%201P%20%26%20User%20Segmentation/B2B%20Factiva%20Segments%20-%20Client%20Insights) [B2B / B2B Product / Factiva / Factiva 1P & User Segmentation]
