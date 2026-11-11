# [SANDBOX] Contract-Level Dataset (athena)

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Pricing / Country Segment Pricing / Test Versions |
| Owner | Jonas Coelho |
| Created | 2026-08-03 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/5213597 |
| Archived | 2026-11-11 |

## Summary

1 data source(s) in the workbook; 1 with an Athena component (1 embedded, 0 published).

## "Historical Pricing TM1" (embedded)

- **Shape:** Join of 2 tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Used by worksheets:** TM1 Explorer
- **Structure:**

```
- LEFT JOIN on [Custom SQL Query].[company_country] = lower([Emerging Market Countries].[Country])
  - Athena Custom SQL "Custom SQL Query" -> Historical Pricing TM1.sql
  - Google Drive Excel "(2)" table Sheet1$ (as "Emerging Market Countries")
```
- **Athena tables read:** `sandbox_test.vw_contract_level`
- **SQL files:** [Historical Pricing TM1.sql](Historical%20Pricing%20TM1.sql)
