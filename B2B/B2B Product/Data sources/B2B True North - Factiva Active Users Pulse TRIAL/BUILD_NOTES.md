# B2B True North - Factiva Active Users Pulse TRIAL

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Product / Data sources |
| Owner | Maria Peco |
| Created | 2025-08-20 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/108737297 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Relationship model: 3 logical tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Structure:**

```
Logical table "Codes"
  - Google Drive Excel "RCFC codes" table Codes$ (as "Codes")
Logical table "Industry Lookup"
  - Google Drive Excel "Industry Mapping" table Sheet1$ (as "Sheet1")
Logical table "Custom SQL Query"
  - Athena Custom SQL "Custom SQL Query" -> Custom SQL Query.sql
```

- **Relationships:**
  - "Custom SQL Query" ↔ "Codes" on `[plan_id] = [Code]`
  - "Custom SQL Query" ↔ "Industry Lookup" on `[company_industry] = [SFDC Industry]`
- **Athena tables read:** `reference_external_db.date_dimension`, `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `reference_external_db.pib_product_dimension`, `fact_external_db.omniture_event_fact`
- **SQL files:** [Custom SQL Query.sql](Custom%20SQL%20Query.sql)

## Connected workbooks

_No connected workbooks found._
