# B2B DJ Search Dashboard - NF Search Metrics 2025

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Product / Data sources |
| Owner | James Thomson |
| Created | 2025-09-15 |
| Last updated | 2026-01-19 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/121523326 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Join of 3 tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Structure:**

```
- LEFT JOIN on [Custom SQL Query].[company_industry] = [Industry Lookup].[SFDC Industry]
  - LEFT JOIN on [Custom SQL Query].[department_code] = [Job Function].[Code]
    - Athena Custom SQL "Custom SQL Query" -> Custom SQL Query.sql
    - Google Drive Excel "Job Function2" table Sheet1$ (as "Job Function")
  - Google Drive Excel "Industry Mapping 3" table Sheet1$ (as "Industry Lookup")
```
- **Athena tables read:** `dimension_external_db.pib_membership_dimension`, `reference_external_db.date_dimension`, `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [Custom SQL Query.sql](Custom%20SQL%20Query.sql)

## Connected workbooks

- [Entity Link Usage](../../Entity%20Link%20Usage) [B2B / B2B Product]
