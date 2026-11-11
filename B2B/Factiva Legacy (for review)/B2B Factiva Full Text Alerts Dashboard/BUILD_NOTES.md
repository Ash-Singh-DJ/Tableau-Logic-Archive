# B2B Factiva Full Text Alerts Dashboard

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / Factiva Legacy (for review) |
| Owner | Maria Peco |
| Created | 2025-07-08 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/2987963 |
| Archived | 2026-11-11 |

## Summary

1 data source(s) in the workbook; 1 with an Athena component (1 embedded, 0 published).

## "Full Text Alerts usage" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Sheet 1, Sheet 1 (2), Sheet 1 (3), Sheet 1 (4)
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Full Text Alerts usage.sql
```
- **Athena tables read:** `dimension_external_db.pib_alerts`
- **SQL files:** [Full Text Alerts usage.sql](Full%20Text%20Alerts%20usage.sql)
