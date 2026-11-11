# Factiva - Newsplus - User Level Metrics

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Product |
| Owner | Maria Peco |
| Created | 2025-09-17 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/3338561 |
| Archived | 2026-11-11 |

## Summary

1 data source(s) in the workbook; 1 with an Athena component (1 embedded, 0 published).

## "user_level_metrics_active (sandbox_russellt)" (embedded)

- **Shape:** Standalone table
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / sandbox_russellt)
- **Used by worksheets:** Classic Factiva ULM, New Factiva ULM, Newsplus ULM, RCFC ULM
- **Structure:**

```
- Athena table sandbox_russellt.ulm_joined (as "ulm_joined")
```
- **Athena tables read:** `sandbox_russellt.ulm_joined`
- **SQL files:** _none -- Athena is read as plain table(s), no Custom SQL_
