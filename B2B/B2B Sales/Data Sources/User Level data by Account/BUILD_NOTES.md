# User Level data by Account

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Sales / Data Sources |
| Owner | James Thomson |
| Created | 2025-11-12 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/179845560 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Relationship model: 6 logical tables (with joins inside) -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Structure:**

```
Logical table "Downloads"
  - Athena Custom SQL "Custom SQL Query1" -> Custom SQL Query1.sql
Logical table "Alerts Sharing"
  - Athena Custom SQL "Custom SQL Query3" -> Custom SQL Query3.sql
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
```

- **Relationships:**
  - "Main data" ↔ "Downloads" on `[year_month] = [year_month (Custom SQL Query1)] AND [billing_account_id] = [billing_account_id (Custom SQL Query1)]`
  - "Main data" ↔ "Alerts Sharing" on `[billing_account_id] = [account_id]`
  - "Main data" ↔ "Number of Seats" on `[billing_account_id] = [billing_account_number (Custom SQL Query5)]`
  - "Main data" ↔ "Password sharing" on `[billing_account_id] = [billing_account_id (Custom SQL Query2)]`
  - "Main data" ↔ "Contract data" on `[billing_account_id] = [billing_account_number]`
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_alerts`, `dimension_external_db.pib_territory_dimension`, `finance_external_db.cibs_products_rules`, `finance_external_db.tm1_cibs_gltransrel`, `finance_external_db.cibs_products`, `fact_external_db.omniture_event_fact`, `reference_external_db.country_reference`, `dimension_external_db.pib_user_dimension`, `reference_external_db.pib_product_master`, `dimension_external_db.pib_contract_dimension`, `fact_external_db.tm1_fact`, `reference_external_db.date_dimension`
- **SQL files:** [Custom SQL Query1.sql](Custom%20SQL%20Query1.sql), [Custom SQL Query3.sql](Custom%20SQL%20Query3.sql), [Custom SQL Query5.sql](Custom%20SQL%20Query5.sql), [Custom SQL Query2.sql](Custom%20SQL%20Query2.sql), [Custom SQL Query.sql](Custom%20SQL%20Query.sql), [Custom SQL Query4.sql](Custom%20SQL%20Query4.sql)

## Connected workbooks

- [B2B Account Level Billing and Usage Metrics](../../Product%20Usage/B2B%20Account%20Level%20Billing%20and%20Usage%20Metrics) [B2B / B2B Sales / Product Usage]
