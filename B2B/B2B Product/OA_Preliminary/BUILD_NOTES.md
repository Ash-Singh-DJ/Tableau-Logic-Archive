# OA_Preliminary

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Product |
| Owner | Steve Bishop |
| Created | 2025-11-19 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/3632195 |
| Archived | 2026-11-11 |

## Summary

1 data source(s) in the workbook; 1 with an Athena component (1 embedded, 0 published).

## "DJM-OA" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / abc_matrix)
- **Used by worksheets:** OA Activities, Sheet 4, uu, visit
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> DJM-OA.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [DJM-OA.sql](DJM-OA.sql)
