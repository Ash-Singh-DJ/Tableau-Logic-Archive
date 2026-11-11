# B2B Factiva User_Company-Level Metrics Dashboard

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Product / Factiva |
| Owner | Ashish Kumar |
| Created | 2025-07-28 |
| Last updated | 2025-09-02 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/3088300 |
| Archived | 2026-11-11 |

## Summary

1 data source(s) in the workbook; 1 with an Athena component (0 embedded, 1 published).

## "custom sql query (fact_external)" (published data source)

- **Published source:** "B2B User_Company-Level Metrics - Data Source" in `B2B / B2B Product / Factiva / Datasources`, owner Maria Peco; [archived here](../Datasources/B2B%20User_Company-Level%20Metrics%20-%20Data%20Source). The SQL below is copied from it.
- **Shape:** Join of 2 tables
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / reference_external_db)
- **Used by worksheets:** Articles Sent via AlertsTrend Chart, Email Alerts Sent Trend Chart, Full text Articles Sent via AlertsTrend Chart, Last Updated, PIB Company-Level Data Dashboard, PIB User-Level Data Dashboard, Sheet 3, Sheet 8
- **Structure:**

```
- LEFT JOIN on [User & Usage Information].[plan_id] = [pib_product_dimension].[access_code]
  - Athena Custom SQL "User & Usage Information" -> custom sql query (fact_external).sql
  - Athena table reference_external_db.pib_product_dimension (as "pib_product_dimension")
```
- **Athena tables read:** `fact_external_db.omniture_event_fact`, `dimension_external_db.pib_alerts`, `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_territory_dimension`, `reference_external_db.country_reference`, `reference_external_db.pib_product_dimension`
- **SQL files:** [custom sql query (fact_external).sql](custom%20sql%20query%20%28fact_external%29.sql)
