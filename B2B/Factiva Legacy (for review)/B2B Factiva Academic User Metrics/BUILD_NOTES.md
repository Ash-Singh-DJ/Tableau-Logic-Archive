# B2B Factiva Academic User Metrics

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / Factiva Legacy (for review) |
| Owner | Maria Peco |
| Created | 2025-07-28 |
| Last updated | 2025-09-12 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/3087138 |
| Archived | 2026-11-11 |

## Summary

1 data source(s) in the workbook; 1 with an Athena component (0 embedded, 1 published).

## "Academics" (published data source)

- **Published source:** "B2B Factiva Academic User Metrics - Data Source" in `B2B / B2B Product / Factiva / Datasources`, owner James Thomson; [archived here](../../B2B%20Product/Factiva/Datasources/B2B%20Factiva%20Academic%20User%20Metrics%20-%20Data%20Source). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Avg Monthly Users, Daily Active Users, Link, Max date, Monthly Active MTD, Monthly Active Users, Monthly Active YoY, Monthly Active YoY uvs, Monthly Newly Active Users, PM MTD, PY MTD, Quarterly Active Users, Table, Users Chart, Yearly Active Users
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Academics.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [Academics.sql](Academics.sql)
