# B2B Account Level Billing and Usage Metrics: RCFC

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Sales / Product Usage |
| Owner | James Thomson |
| Created | 2025-12-19 |
| Last updated | 2025-12-19 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/3753652 |
| Archived | 2026-11-11 |

## Summary

1 data source(s) in the workbook; 1 with an Athena component (0 embedded, 1 published).

## "User Level data by Account RCFC" (published data source)

- **Published source:** "User Level data by Account RCFC" in `B2B / B2B Product / Factiva`, owner James Thomson; [archived here](../../../B2B%20Product/Factiva/User%20Level%20data%20by%20Account%20RCFC). The SQL below is copied from it.
- **Shape:** Relationship model: 5 logical tables (with joins inside) -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Used by worksheets:** Sheet 1, Sheet 2, Sheet 3, Sheet 4
- **Structure:**

```
Logical table "Number of Seats"
  - Athena Custom SQL "Custom SQL Query5" -> User Level data by Account RCFC - Custom SQL Query5.sql
Logical table "Password sharing"
  - Athena Custom SQL "Custom SQL Query2" -> User Level data by Account RCFC - Custom SQL Query2.sql
Logical table "Main data"
  - LEFT JOIN on [Custom SQL Query].[plan_id] = [Codes].[Code]
    - Athena Custom SQL "Custom SQL Query" -> User Level data by Account RCFC - Custom SQL Query.sql
    - Google Drive Excel "RCFC codes" table Codes$ (as "Codes")
Logical table "Contract data"
  - Athena Custom SQL "Custom SQL Query4" -> User Level data by Account RCFC - Custom SQL Query4.sql
Logical table "UBO"
  - Athena Custom SQL "Custom SQL Query1" -> User Level data by Account RCFC - Custom SQL Query1.sql
```

- **Relationships:**
  - "Main data" ↔ "Number of Seats" on `[billing_account_id] = [billing_account_number (Custom SQL Query5)]`
  - "Main data" ↔ "Password sharing" on `[billing_account_id] = [billing_account_id (Custom SQL Query2)]`
  - "Main data" ↔ "Contract data" on `[billing_account_id] = [billing_account_number]`
  - "Main data" ↔ "UBO" on `[billing_account_id] = [cibs_billing_account_id]`
- **Athena tables read:** `finance_external_db.cibs_products_rules`, `finance_external_db.tm1_cibs_gltransrel`, `finance_external_db.cibs_products`, `fact_external_db.omniture_event_fact`, `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `reference_external_db.pib_product_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_user_dimension`, `dimension_external_db.pib_territory_dimension`, `dimension_external_db.pib_contract_dimension`, `fact_external_db.tm1_fact`, `reference_external_db.date_dimension`, `dimension_external_db.pib_cibs_billing_charges_dimension`, `google_sheets_db.ubo_usage_monthly_unpivot`
- **SQL files:** [User Level data by Account RCFC - Custom SQL Query5.sql](User%20Level%20data%20by%20Account%20RCFC%20-%20Custom%20SQL%20Query5.sql), [User Level data by Account RCFC - Custom SQL Query2.sql](User%20Level%20data%20by%20Account%20RCFC%20-%20Custom%20SQL%20Query2.sql), [User Level data by Account RCFC - Custom SQL Query.sql](User%20Level%20data%20by%20Account%20RCFC%20-%20Custom%20SQL%20Query.sql), [User Level data by Account RCFC - Custom SQL Query4.sql](User%20Level%20data%20by%20Account%20RCFC%20-%20Custom%20SQL%20Query4.sql), [User Level data by Account RCFC - Custom SQL Query1.sql](User%20Level%20data%20by%20Account%20RCFC%20-%20Custom%20SQL%20Query1.sql)
