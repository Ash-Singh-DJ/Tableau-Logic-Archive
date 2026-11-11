# R&C SLT Due Diligence Dashboard

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Product / R&C |
| Owner | Maria Peco |
| Created | 2025-10-08 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/3438251 |
| Archived | 2026-11-11 |

## Summary

1 data source(s) in the workbook; 1 with an Athena component (1 embedded, 0 published).

## "DD Reports" (embedded)

- **Shape:** Relationship model: 2 logical tables
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / google_sheets_db)
- **Used by worksheets:** DD Report $ latest Week, DD Report YTD, DD Report YTD $, DD Report YTD Title, DD Report latest Week, DD Report latest Wk Title, DD Report latest month, DD Report latest month $, DD Report latest month title, DD Reports $ Trend, DD Reports Trend, Pct Change Latest, Pct Change Latest $, Pct Change Mth Latest, Pct Change Mth Latest $, Pct Change YTD Latest, Pct Change YTD Latest $
- **Structure:**

```
Logical table "dd_reports_2"
  - Athena Custom SQL "dd reports 2" -> DD Reports - dd reports 2.sql
Logical table "due_diligence_deli"
  - Athena Custom SQL "Custom SQL Query" -> DD Reports - Custom SQL Query.sql
```

- **Relationships:**
  - "due_diligence_deli" ↔ "dd_reports_2" on `[prior_yr_fiscal_wk] = [week_number_in_fiscal_year (Custom SQL Query1)]`
- **Athena tables read:** `google_sheets_db.due_diligence_delivered_reports_current`, `reference_external_db.date_dimension`
- **SQL files:** [DD Reports - dd reports 2.sql](DD%20Reports%20-%20dd%20reports%202.sql), [DD Reports - Custom SQL Query.sql](DD%20Reports%20-%20Custom%20SQL%20Query.sql)
