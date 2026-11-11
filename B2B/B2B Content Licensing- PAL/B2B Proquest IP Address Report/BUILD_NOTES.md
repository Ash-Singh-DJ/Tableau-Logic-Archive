# B2B Proquest IP Address Report

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Content Licensing- PAL |
| Owner | James Thomson |
| Created | 2025-08-11 |
| Last updated | 2026-02-11 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/3161804 |
| Archived | 2026-11-11 |

## Summary

1 data source(s) in the workbook; 1 with an Athena component (0 embedded, 1 published).

## "Proquest" (published data source)

- **Published source:** "B2B Proquest IP Address - Datasource" in `B2B / B2B Product / Newswires / Datasources`, owner James Thomson; [archived here](../../B2B%20Product/Newswires/Datasources/B2B%20Proquest%20IP%20Address%20-%20Datasource). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** MTD Alert, MTD chart, Report by Account, Report by Account (2), Report by User ID, Sheet 2, Sheet 5, Sheet 5 (2), Sheet 5 (3), Sheet 8, chartt
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Proquest.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_territory_dimension`
- **SQL files:** [Proquest.sql](Proquest.sql)
