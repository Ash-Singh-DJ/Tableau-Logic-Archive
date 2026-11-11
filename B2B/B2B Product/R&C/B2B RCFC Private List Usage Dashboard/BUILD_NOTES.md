# B2B RCFC Private List Usage Dashboard

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Product / R&C |
| Owner | Maria Peco |
| Created | 2025-07-29 |
| Last updated | 2025-08-21 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/3093268 |
| Archived | 2026-11-11 |

## Summary

1 data source(s) in the workbook; 1 with an Athena component (0 embedded, 1 published).

## "custom sql query (fact_external)" (published data source)

- **Published source:** "B2B RCFC Private List Usage" in `B2B / B2B Product / R&C / Datasources`, owner Maria Peco; [archived here](../Datasources/B2B%20RCFC%20Private%20List%20Usage). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / reference_external_db)
- **Used by worksheets:** BA Pie, BA Pie( %), Billing Account, Billing Account (month), En/Disable (trend), Enable/Disable (month), Enable/disable BA, Last Updated, Monthly Usage, Monthly Usage (%), RCFC Private List Metrics wks, Trend of Create, Trend of Delete, Trend of Edit, Trend of Toggle, Trend of disable, Trend of enable, en/disable (%), en/disable (pie), summary_line
- **Structure:**

```
- Athena Custom SQL "User & Usage Information" -> custom sql query (fact_external).sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [custom sql query (fact_external).sql](custom%20sql%20query%20%28fact_external%29.sql)
