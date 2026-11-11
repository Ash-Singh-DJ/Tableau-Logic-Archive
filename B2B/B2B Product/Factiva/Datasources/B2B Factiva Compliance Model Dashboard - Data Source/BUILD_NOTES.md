# B2B Factiva Compliance Model Dashboard - Data Source

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Product / Factiva / Datasources |
| Owner | Maria Peco |
| Created | 2025-07-28 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/94374699 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Join of 2 tables
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Structure:**

```
- LEFT JOIN on [Company Data].[company_sfdc_id] = [User + Model Data].[company_sfdc_id]
  - Athena Custom SQL "Company Data" -> Company Data.sql
  - Athena Custom SQL "User + Model Data" -> User + Model Data.sql
```
- **Athena tables read:** `fact_external_db.tm1_fact`, `reference_external_db.pib_product_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_corporate_dimension`, `dimension_external_db.pib_territory_dimension`, `dimension_external_db.pib_user_dimension`, `dimension_external_db.pib_membership_dimension`, `sandbox_mk.compliance_model_results`
- **SQL files:** [Company Data.sql](Company%20Data.sql), [User + Model Data.sql](User%20%2B%20Model%20Data.sql)

## Connected workbooks

- [B2B  Factiva Compliance Model Dashboard](../../Factiva%201P%20%26%20User%20Segmentation/B2B%20Factiva%20Compliance%20Model%20Dashboard) [B2B / B2B Product / Factiva / Factiva 1P & User Segmentation]
