# Commercial Policy Cases

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Pricing / Datasources |
| Owner | Maria Peco |
| Created | 2025-09-09 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/154048120 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Custom SQL Query.sql
```
- **Athena tables read:** `dimension_external_db.pib_customer_service_case_dimension`, `dimension_external_db.pib_opportunity_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_user_dimension`, `dimension_external_db.pib_product_services_dimension`, `fact_external_db.pib_account_hierarchy_fact`, `dimension_external_db.pib_company_dimension`, `reference_external_db.date_dimension`
- **SQL files:** [Custom SQL Query.sql](Custom%20SQL%20Query.sql)

## Connected workbooks

- Commercial Policy Cases [B2B / B2B Pricing]
- [B2B AI_Gen AI Case](../../ARCHIVE/B2B%20AI_Gen%20AI%20Case) [B2B / B2B Pricing / ARCHIVE]
