# Factiva Weekly retention.

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Product / Factiva |
| Owner | James Thomson |
| Created | 2026-02-12 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/129430264 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Join of 2 tables
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / reference_external_db)
- **Structure:**

```
- LEFT JOIN on [Custom SQL Query].[plan_id] = [pib_product_dimens].[access_code]
  - Athena Custom SQL "Custom SQL Query" -> Custom SQL Query.sql
  - Athena table reference_external_db.pib_product_dimension (as "pib_product_dimens")
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_corporate_dimension`, `dimension_external_db.pib_territory_dimension`, `dimension_external_db.pib_user_dimension`, `reference_external_db.pib_product_dimension`
- **SQL files:** [Custom SQL Query.sql](Custom%20SQL%20Query.sql)

## Connected workbooks

- [B2B True North Metrics](../../B2B%20True%20North%20Metrics) [B2B / B2B Product]
