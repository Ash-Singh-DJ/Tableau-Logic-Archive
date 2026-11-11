# B2B Screening & Monitoring RC Revenue

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Product / R&C / Datasources |
| Owner | Maria Peco |
| Created | 2025-07-24 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/124041248 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / abc_matrix)
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Custom SQL Query.sql
```
- **Athena tables read:** `reference_external_db.pib_account_mapping`, `fact_external_db.tm1_fact`, `reference_external_db.pib_product_master`, `reference_external_db.date_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_contract_dimension`, `fact_external_db.pib_account_hierarchy_fact`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_corporate_dimension`, `dimension_external_db.pib_product_service_attributes`, `sandbox_mk.geo_region_rollup`
- **SQL files:** [Custom SQL Query.sql](Custom%20SQL%20Query.sql)

## Connected workbooks

- [B2B Screening & Monitoring Customer Report](../../B2B%20Screening%20%26%20Monitoring%20Customer%20Report) [B2B / B2B Product / R&C]
