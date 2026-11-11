# B2B Deutsche Bank - User_Level

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Sales / GAT / Datasources |
| Owner | Shirley Chu |
| Created | 2025-09-29 |
| Last updated | 2026-09-05 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/101199297 |
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
- **Athena tables read:** `fact_external_db.omniture_event_fact`, `dimension_external_db.pib_alerts`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_territory_dimension`, `reference_external_db.country_reference`, `reference_external_db.pib_product_dimension`
- **SQL files:** [User & Usage Information.sql](User%20%26%20Usage%20Information.sql)

## Connected workbooks

_No connected workbooks found._
