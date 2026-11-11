# B2B R&C Upsell Opportunity - R&C ASAM Data

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Sales / Data Sources |
| Owner | Thomas Russell |
| Created | 2025-08-22 |
| Last updated | 2026-08-02 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/108174169 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Custom SQL Query.sql
```
- **Athena tables read:** `dimension_external_db.asam_usage_stats`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_corporate_dimension`, `dimension_external_db.pib_territory_dimension`, `dimension_external_db.pib_user_dimension`, `dimension_external_db.pib_cibs_billing_charges_dimension`
- **SQL files:** [Custom SQL Query.sql](Custom%20SQL%20Query.sql)

## Connected workbooks

- B2B R&C Upsell Opportunity Dashboard [B2B / B2B Sales / Cross-sell & Upsell]
