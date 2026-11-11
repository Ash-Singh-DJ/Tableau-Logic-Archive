# B2B Factiva User Maturity Dashboard - Users

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Product / Factiva / Datasources |
| Owner | Maria Peco |
| Created | 2025-07-28 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/89899893 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Join of 2 tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Structure:**

```
- LEFT JOIN on [Custom SQL Query].[department_code] = [Sheet1].[Code]
  - Athena Custom SQL "Custom SQL Query" -> Custom SQL Query.sql
  - Google Drive Excel "Job Function" table Sheet1$ (as "Sheet1")
```
- **Athena tables read:** `dimension_external_db.pib_membership_dimension`, `fact_external_db.omniture_event_fact`, `pib_event_data.pib_product_metrics`, `google_sheets_db.saml_master_list_b2b_current`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [Custom SQL Query.sql](Custom%20SQL%20Query.sql)

## Connected workbooks

- [B2B Factiva User Maturity Dashboard](../../../../Factiva%20Legacy%20%28for%20review%29/B2B%20Factiva%20User%20Maturity%20Dashboard) [B2B / Factiva Legacy (for review)]
