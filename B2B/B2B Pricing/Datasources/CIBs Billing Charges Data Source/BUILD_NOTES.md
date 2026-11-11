# CIBs Billing Charges Data Source

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Pricing / Datasources |
| Owner | Thomas Russell |
| Created | 2025-09-18 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/147271971 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Relationship model: 3 logical tables -- Athena + Google Drive CSV
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / reference_external_db); Google Drive CSV
- **Structure:**

```
Logical table "Custom SQL Query"
  - Athena Custom SQL "Custom SQL Query" -> Custom SQL Query.sql
Logical table "currency-code-mapping.csv1"
  - Google Drive CSV "currency-code-mapping" table currency-code-mapping#csv (as "currency-code-mapping.csv1")
Logical table "fx_rates_current"
  - Athena table reference_external_db.fx_rates_current (as "fx_rates_current")
```

- **Relationships:**
  - "Custom SQL Query" ↔ "currency-code-mapping.csv1" on `[salesforce_local_currency] = [SFDC_code (currency-code-mapping.csv1)]`
  - "currency-code-mapping.csv1" ↔ "fx_rates_current" on `[currency_code (currency-code-mapping.csv1)] = [currency]`
- **Athena tables read:** `fact_external_db.tm1_fact`, `csuite_external_db.eloqua_cdo_current_risk_certification`, `dimension_external_db.pib_cibs_billing_charges_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_contract_dimension`, `dimension_external_db.pib_territory_dimension`, `dimension_external_db.pib_user_dimension`, `reference_external_db.fx_rates_current`
- **SQL files:** [Custom SQL Query.sql](Custom%20SQL%20Query.sql)

## Connected workbooks

_No connected workbooks found._
