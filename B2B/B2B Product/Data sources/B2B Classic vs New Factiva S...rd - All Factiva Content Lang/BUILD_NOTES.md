# B2B Classic vs New Factiva Search Dashboard - All Factiva Content Lang

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Product / Data sources |
| Owner | Maria Peco |
| Created | 2025-11-06 |
| Last updated | 2026-01-07 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/108746610 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Relationship model: 3 logical tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Structure:**

```
Logical table "Lang"
  - Google Drive Excel "ISO Codes2" table Sheet1$ (as "Sheet1")
Logical table "Revenue"
  - Google Drive Excel "Revenue Lang" table Sheet 1$ (as "Sheet 1")
Logical table "Custom SQL Query"
  - Athena Custom SQL "Custom SQL Query" -> Custom SQL Query.sql
```

- **Relationships:**
  - "Custom SQL Query" ↔ "Lang" on `[lang] = [code]`
  - "Custom SQL Query" ↔ "Revenue" on `[company_sfdc_id] = [company sfdc id]`
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [Custom SQL Query.sql](Custom%20SQL%20Query.sql)

## Connected workbooks

_No connected workbooks found._
