# Membership Table Lookup

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Product / Factiva |
| Owner | James Thomson |
| Created | 2025-09-26 |
| Last updated | 2025-12-23 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/3390714 |
| Archived | 2026-11-11 |

## Summary

1 data source(s) in the workbook; 1 with an Athena component (0 embedded, 1 published).

## "Custom SQL Query (dimension_external_db)" (published data source)

- **Published source:** "Custom SQL Query (dimension_external_db)" in `B2B / B2B Testing`, owner James Thomson; not archived separately: it sits outside the archive scope (B2B Testing). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** PiB Member ID, Sheet 1, billing
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Custom SQL Query (dimension_external_db).sql
```
- **Athena tables read:** `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [Custom SQL Query (dimension_external_db).sql](Custom%20SQL%20Query%20%28dimension_external_db%29.sql)
