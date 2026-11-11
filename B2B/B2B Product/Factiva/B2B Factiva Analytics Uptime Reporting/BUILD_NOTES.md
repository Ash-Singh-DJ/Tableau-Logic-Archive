# B2B Factiva Analytics Uptime Reporting

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Product / Factiva |
| Owner | Maria Peco |
| Created | 2025-06-23 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/2916527 |
| Archived | 2026-11-11 |

## Summary

1 data source(s) in the workbook; 1 with an Athena component (1 embedded, 0 published).

## "New Relic2" (embedded)

- **Shape:** Relationship model: 2 logical tables (with joins inside) -- Athena + Excel file
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Excel file
- **Used by worksheets:** 2 Overall Uptime %, 2 Table, 2 Total Down Minutes Adjusted, 2 Total Down Minutes1, 2 Total Minutes, 2 Trend chart, O Overall Uptime % , O Table , O Total Down Minutes, O Total Minutes, O Trend chart, Overall Uptime %, Sheet 10, Sheet 11 (2), Sheet 22, Sheet 30, Sheet 8, Sheet 8 (2), Table, Total Down Minutes, Total Minutes, Trend Chart, text
- **Structure:**

```
Logical table "NR"
  - LEFT JOIN on [Full Date].[ymd] = [Maintenence].[date]
    - LEFT JOIN on [Full Date].[ymd] = [Downtime].[ymd] AND [Full Date].[fa] = [Downtime].[synthetic_monitor_name]
      - Athena Custom SQL "Full Date" -> New Relic2 - Full Date.sql
      - Athena Custom SQL "Downtime" -> New Relic2 - Downtime.sql
    - Excel file "Maintenence XL version2" table Sheet1$ (as "Maintenence")
Logical table "Overall downtime"
  - LEFT JOIN on [Custom SQL Query].[ymd3] = [Maintenence2].[date]
    - Athena Custom SQL "Custom SQL Query" -> New Relic2 - Custom SQL Query.sql
    - Excel file "Maintenence XL version2" table Sheet1$ (as "Maintenence2")
```

- **Relationships:**
  - "NR" ↔ "Overall downtime" on `[ymd] = [ymd3]`
- **Athena tables read:** `reference_external_db.date_dimension`, `new_relic_db.new_relic_synthetics`
- **SQL files:** [New Relic2 - Full Date.sql](New%20Relic2%20-%20Full%20Date.sql), [New Relic2 - Downtime.sql](New%20Relic2%20-%20Downtime.sql), [New Relic2 - Custom SQL Query.sql](New%20Relic2%20-%20Custom%20SQL%20Query.sql)
