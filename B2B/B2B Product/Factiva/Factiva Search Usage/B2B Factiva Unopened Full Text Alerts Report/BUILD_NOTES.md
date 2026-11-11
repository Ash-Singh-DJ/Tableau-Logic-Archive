# B2B Factiva Unopened Full Text Alerts Report

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Product / Factiva / Factiva Search Usage |
| Owner | Maria Peco |
| Created | 2025-07-28 |
| Last updated | 2025-09-12 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/3087307 |
| Archived | 2026-11-11 |

## Summary

1 data source(s) in the workbook; 1 with an Athena component (0 embedded, 1 published).

## "Full Txt" (published data source)

- **Published source:** "B2B Unopened Full Text Alerts Report - Data Source" in `B2B / B2B Product / Factiva / Datasources`, owner Maria Peco; [archived here](../../Datasources/B2B%20Unopened%20Full%20Text%20Alerts%20Report%20-%20Data%20Source). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Detail Report, Sheet 1, Sheet 1 (2), Sheet 2, Summary Numbers
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Full Txt.sql
```
- **Athena tables read:** `pib.email_open_rates`, `dimension_external_db.pib_alerts`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [Full Txt.sql](Full%20Txt.sql)
