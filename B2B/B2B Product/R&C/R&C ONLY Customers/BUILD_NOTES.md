# R&C ONLY Customers

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Product / R&C |
| Owner | Shirley Chu |
| Created | 2026-02-03 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/3951488 |
| Archived | 2026-11-11 |

## Summary

1 data source(s) in the workbook; 1 with an Athena component (1 embedded, 0 published).

## "DJM" (embedded)

- **Shape:** Join of 2 tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / abc_matrix); Google Drive Excel
- **Used by worksheets:** Detail, uu
- **Structure:**

```
- LEFT JOIN on [Custom SQL Query].[plan_id] = [Risk & Compliance].[ACCESS CODE]
  - Athena Custom SQL "Custom SQL Query" -> DJM.sql
  - Google Drive Excel "RCFC_Code_KW Edit" table Risk & Compliance$ (as "Risk & Compliance")
```
- **Athena tables read:** `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `reference_external_db.pib_product_dimension`, `pib_event_data.pib_product_metrics`, `fact_external_db.omniture_event_fact`
- **SQL files:** [DJM.sql](DJM.sql)
