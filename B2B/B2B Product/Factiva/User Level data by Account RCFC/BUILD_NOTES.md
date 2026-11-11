# User Level data by Account RCFC

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Product / Factiva |
| Owner | James Thomson |
| Created | 2025-12-18 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/117533858 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Relationship model: 5 logical tables (with joins inside) -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Structure:**

```
Logical table "Number of Seats"
  - Athena Custom SQL "Custom SQL Query5" -> Custom SQL Query5.sql
Logical table "Password sharing"
  - Athena Custom SQL "Custom SQL Query2" -> Custom SQL Query2.sql
Logical table "Main data"
  - LEFT JOIN on [Custom SQL Query].[plan_id] = [Codes].[Code]
    - Athena Custom SQL "Custom SQL Query" -> Custom SQL Query.sql
    - Google Drive Excel "RCFC codes" table Codes$ (as "Codes")
Logical table "Contract data"
  - Athena Custom SQL "Custom SQL Query4" -> Custom SQL Query4.sql
Logical table "UBO"
  - Athena Custom SQL "Custom SQL Query1" -> Custom SQL Query1.sql
```

- **Relationships:**
  - "Main data" ↔ "Number of Seats" on `[billing_account_id] = [billing_account_number (Custom SQL Query5)]`
  - "Main data" ↔ "Password sharing" on `[billing_account_id] = [billing_account_id (Custom SQL Query2)]`
  - "Main data" ↔ "Contract data" on `[billing_account_id] = [billing_account_number]`
  - "Main data" ↔ "UBO" on `[billing_account_id] = [cibs_billing_account_id]`
- **Athena tables read:** `finance_external_db.cibs_products_rules`, `finance_external_db.tm1_cibs_gltransrel`, `finance_external_db.cibs_products`, `fact_external_db.omniture_event_fact`, `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `reference_external_db.pib_product_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_user_dimension`, `dimension_external_db.pib_territory_dimension`, `dimension_external_db.pib_contract_dimension`, `fact_external_db.tm1_fact`, `reference_external_db.date_dimension`, `dimension_external_db.pib_cibs_billing_charges_dimension`, `google_sheets_db.ubo_usage_monthly_unpivot`
- **SQL files:** [Custom SQL Query5.sql](Custom%20SQL%20Query5.sql), [Custom SQL Query2.sql](Custom%20SQL%20Query2.sql), [Custom SQL Query.sql](Custom%20SQL%20Query.sql), [Custom SQL Query4.sql](Custom%20SQL%20Query4.sql), [Custom SQL Query1.sql](Custom%20SQL%20Query1.sql)

## Connected workbooks

- [B2B Account Level Billing and Usage Metrics: RCFC](../../../B2B%20Sales/Product%20Usage/B2B%20Account%20Level%20Billing%20and%20Usage%20Metrics-%20RCFC) [B2B / B2B Sales / Product Usage]
- B2B Account Level Billing and Usage Metrics [B2B / B2B Testing]
