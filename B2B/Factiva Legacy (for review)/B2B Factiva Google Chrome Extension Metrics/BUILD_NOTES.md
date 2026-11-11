# B2B Factiva Google Chrome Extension Metrics

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / Factiva Legacy (for review) |
| Owner | Maria Peco |
| Created | 2025-07-28 |
| Last updated | 2025-09-12 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/3087067 |
| Archived | 2026-11-11 |

## Summary

2 data source(s) in the workbook; 1 with an Athena component (0 embedded, 1 published).
Other data sources: "Chrome downloads" (published).

## "Chrome Ext" (published data source)

- **Published source:** "B2B Google Chrome Extension Metrics - Chrome Ext" in `B2B / B2B Product / Factiva / Datasources`, owner Maria Peco; [archived here](../../B2B%20Product/Factiva/Datasources/B2B%20Google%20Chrome%20Extension%20Metrics%20-%20Chrome%20Ext). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Sheet 1, Sheet 2, Sheet 3, Sheet 3 (2), Sheet 8, User Level
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Chrome Ext.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [Chrome Ext.sql](Chrome%20Ext.sql)
