# B2B Registered Users Athena

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Sales / Sales Leadership & Operations / Datasources |
| Owner | James Thomson |
| Created | 2025-07-28 |
| Last updated | 2026-05-05 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/90015231 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Structure:**

```
- Athena Custom SQL "custom_sql_query" -> custom_sql_query.sql
```
- **Athena tables read:** `dimension_external_db.pib_membership_dimension`, `reference_external_db.pib_product_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [custom_sql_query.sql](custom_sql_query.sql)

## Connected workbooks

_No connected workbooks found._
