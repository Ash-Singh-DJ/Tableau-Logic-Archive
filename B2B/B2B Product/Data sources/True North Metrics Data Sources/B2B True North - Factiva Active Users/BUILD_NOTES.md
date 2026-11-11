# B2B True North - Factiva Active Users

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Product / Data sources / True North Metrics Data Sources |
| Owner | James Thomson |
| Created | 2025-09-16 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/141473165 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Join of 2 tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Structure:**

```
- LEFT JOIN on [Custom SQL Query].[year_month_day] = STR([Sheet1].[Date])
  - Athena Custom SQL "Custom SQL Query" -> Custom SQL Query.sql
  - Google Drive Excel "Day lookup" table Sheet1$ (as "Sheet1")
```
- **Athena tables read:** `reference_external_db.date_dimension`, `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `fact_external_db.omniture_event_fact`
- **SQL files:** [Custom SQL Query.sql](Custom%20SQL%20Query.sql)

## Connected workbooks

- [B2B True North Metrics](../../../B2B%20True%20North%20Metrics) [B2B / B2B Product]
