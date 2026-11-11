# B2B User_Company-Level Metrics - Data Source

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Product / Factiva / Datasources |
| Owner | Maria Peco |
| Created | 2025-07-28 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/95899169 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Join of 2 tables
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / reference_external_db)
- **Structure:**

```
- LEFT JOIN on [User & Usage Information].[plan_id] = [pib_product_dimension].[access_code]
  - Athena Custom SQL "User & Usage Information" -> User & Usage Information.sql
  - Athena table reference_external_db.pib_product_dimension (as "pib_product_dimension")
```
- **Athena tables read:** `fact_external_db.omniture_event_fact`, `dimension_external_db.pib_alerts`, `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_territory_dimension`, `reference_external_db.country_reference`, `reference_external_db.pib_product_dimension`
- **SQL files:** [User & Usage Information.sql](User%20%26%20Usage%20Information.sql)

## Connected workbooks

- [B2B Factiva User_Company-Level Metrics Dashboard](../../B2B%20Factiva%20User_Company-Level%20Metrics%20Dashboard) [B2B / B2B Product / Factiva]
