# B2B New Factiva Off Platform Users

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / Factiva Legacy (for review) |
| Owner | Maria Peco |
| Created | 2025-07-29 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/3093400 |
| Archived | 2026-11-11 |

## Summary

1 data source(s) in the workbook; 1 with an Athena component (1 embedded, 0 published).

## "Off Platform Digest users" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Details, Sheet 1, Sheet 1 (2), Sheet 1 (3), Sheet 1 (5), Sheet 1 (6), Sheet 4
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Off Platform Digest users.sql
```
- **Athena tables read:** `fact_external_db.omniture_event_fact`, `pib_event_data.pib_product_metrics`, `pib.email_open_rates`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [Off Platform Digest users.sql](Off%20Platform%20Digest%20users.sql)
