# B2B Pendo Factiva Smart Search Engagement Metrics

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / Factiva Legacy (for review) |
| Owner | Maria Peco |
| Created | 2025-07-28 |
| Last updated | 2025-09-12 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/3087216 |
| Archived | 2026-11-11 |

## Summary

1 data source(s) in the workbook; 1 with an Athena component (0 embedded, 1 published).

## "Usage from Pendo Prompt Dec" (published data source)

- **Published source:** "B2B Usage from Pendo Prompt Dec" in `B2B / B2B Product / Factiva / Datasources`, owner Maria Peco; [archived here](../../B2B%20Product/Factiva/Datasources/B2B%20Usage%20from%20Pendo%20Prompt%20Dec). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Sheet 1, Sheet 2, Sheet 3, Sheet 3 (2), Sheet 3 (3)
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Usage from Pendo Prompt Dec.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [Usage from Pendo Prompt Dec.sql](Usage%20from%20Pendo%20Prompt%20Dec.sql)
