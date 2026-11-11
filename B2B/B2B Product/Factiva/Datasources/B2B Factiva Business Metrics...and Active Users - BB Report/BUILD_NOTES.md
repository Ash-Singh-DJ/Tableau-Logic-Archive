# B2B Factiva Business Metrics: Registered and Active Users - BB Report

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Product / Factiva / Datasources |
| Owner | James Thomson |
| Created | 2025-09-14 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/150431294 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Relationship model: 2 logical tables (with joins inside) -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Structure:**

```
Logical table "Sheet1"
  - Google Drive Excel "Industry Mapping" table Sheet1$ (as "INDUSTRY MAPPING")
Logical table "Custom SQL Query"
  - LEFT JOIN on [Active Days].[billing_account_id] = [Reg in month].[billing_account_id] AND STR([Active Days].[year_month_day]) = [Reg in month].[year_month]
    - Athena Custom SQL "Active Days" -> Active Days.sql
    - Athena Custom SQL "Reg in month" -> Reg in month.sql
```

- **Relationships:**
  - "Custom SQL Query" ↔ "Sheet1" on `UPPER([company_industry]) = [SFDC Industry]`
- **Athena tables read:** `google_sheets_db.saml_master_list_b2b_current`, `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `fact_external_db.omniture_event_fact`
- **SQL files:** [Active Days.sql](Active%20Days.sql), [Reg in month.sql](Reg%20in%20month.sql)

## Connected workbooks

- [B2B Factiva Business Metrics: Registered and Active Users](../../B2B%20Factiva%20Business%20Metrics-%20Registered%20and%20Active%20Users) [B2B / B2B Product / Factiva]
