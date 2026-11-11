# Proquest IP Report (Commerce Envelope Version)

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Content Licensing- PAL |
| Owner | James Thomson |
| Created | 2025-10-07 |
| Last updated | 2026-05-22 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/3435403 |
| Archived | 2026-11-11 |

## Summary

1 data source(s) in the workbook; 1 with an Athena component (0 embedded, 1 published).

## "CE IP Report" (published data source)

- **Published source:** "CE IP Report" in `B2B / B2B Content Licensing- PAL`, owner James Thomson; [archived here](../CE%20IP%20Report). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Sheet 1, Sheet 2 (2), Sheet 2 (3), Summary, Visit Alert Chart, Vist Alert
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> CE IP Report.sql
```
- **Athena tables read:** `publisher_reporting_db.commerce_envelope`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_territory_dimension`
- **SQL files:** [CE IP Report.sql](CE%20IP%20Report.sql)
