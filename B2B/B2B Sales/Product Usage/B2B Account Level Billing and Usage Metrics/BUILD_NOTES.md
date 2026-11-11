# B2B Account Level Billing and Usage Metrics

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Sales / Product Usage |
| Owner | James Thomson |
| Created | 2025-11-12 |
| Last updated | 2026-07-07 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/3597616 |
| Archived | 2026-11-11 |

## Summary

1 data source(s) in the workbook; 1 with an Athena component (0 embedded, 1 published).

## "User Level data by Account" (published data source)

- **Published source:** "User Level data by Account" in `B2B / B2B Sales / Data Sources`, owner James Thomson; [archived here](../../Data%20Sources/User%20Level%20data%20by%20Account). The SQL below is copied from it.
- **Shape:** Relationship model: 6 logical tables (with joins inside) -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Used by worksheets:** Sheet 1, Sheet 2, Sheet 3, Sheet 4
- **Structure:**

```
Logical table "Downloads"
  - Athena Custom SQL "Custom SQL Query1" -> User Level data by Account - Custom SQL Query1.sql
Logical table "Alerts Sharing"
  - Athena Custom SQL "Custom SQL Query3" -> User Level data by Account - Custom SQL Query3.sql
Logical table "Number of Seats"
  - Athena Custom SQL "Custom SQL Query5" -> User Level data by Account - Custom SQL Query5.sql
Logical table "Password sharing"
  - Athena Custom SQL "Custom SQL Query2" -> User Level data by Account - Custom SQL Query2.sql
Logical table "Main data"
  - LEFT JOIN on [Custom SQL Query].[plan_id] = [Codes].[Code]
    - Athena Custom SQL "Custom SQL Query" -> User Level data by Account - Custom SQL Query.sql
    - Google Drive Excel "RCFC codes" table Codes$ (as "Codes")
Logical table "Contract data"
  - Athena Custom SQL "Custom SQL Query4" -> User Level data by Account - Custom SQL Query4.sql
```

- **Relationships:**
  - "Main data" ↔ "Downloads" on `[year_month] = [year_month (Custom SQL Query1)] AND [billing_account_id] = [billing_account_id (Custom SQL Query1)]`
  - "Main data" ↔ "Alerts Sharing" on `[billing_account_id] = [account_id]`
  - "Main data" ↔ "Number of Seats" on `[billing_account_id] = [billing_account_number (Custom SQL Query5)]`
  - "Main data" ↔ "Password sharing" on `[billing_account_id] = [billing_account_id (Custom SQL Query2)]`
  - "Main data" ↔ "Contract data" on `[billing_account_id] = [billing_account_number]`
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_alerts`, `dimension_external_db.pib_territory_dimension`, `finance_external_db.cibs_products_rules`, `finance_external_db.tm1_cibs_gltransrel`, `finance_external_db.cibs_products`, `fact_external_db.omniture_event_fact`, `reference_external_db.country_reference`, `dimension_external_db.pib_user_dimension`, `reference_external_db.pib_product_master`, `dimension_external_db.pib_contract_dimension`, `fact_external_db.tm1_fact`, `reference_external_db.date_dimension`
- **SQL files:** [User Level data by Account - Custom SQL Query1.sql](User%20Level%20data%20by%20Account%20-%20Custom%20SQL%20Query1.sql), [User Level data by Account - Custom SQL Query3.sql](User%20Level%20data%20by%20Account%20-%20Custom%20SQL%20Query3.sql), [User Level data by Account - Custom SQL Query5.sql](User%20Level%20data%20by%20Account%20-%20Custom%20SQL%20Query5.sql), [User Level data by Account - Custom SQL Query2.sql](User%20Level%20data%20by%20Account%20-%20Custom%20SQL%20Query2.sql), [User Level data by Account - Custom SQL Query.sql](User%20Level%20data%20by%20Account%20-%20Custom%20SQL%20Query.sql), [User Level data by Account - Custom SQL Query4.sql](User%20Level%20data%20by%20Account%20-%20Custom%20SQL%20Query4.sql)
