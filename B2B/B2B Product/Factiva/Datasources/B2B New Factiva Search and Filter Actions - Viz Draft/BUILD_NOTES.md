# B2B New Factiva Search and Filter Actions - Viz Draft

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Product / Factiva / Datasources |
| Owner | James Thomson |
| Created | 2025-07-30 |
| Last updated | 2026-07-29 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/168742628 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Custom SQL Query.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [Custom SQL Query.sql](Custom%20SQL%20Query.sql)

## Connected workbooks

- [B2B New Factiva Search and Filter Actions](../../Factiva%20Search%20Usage/B2B%20New%20Factiva%20Search%20and%20Filter%20Actions) [B2B / B2B Product / Factiva / Factiva Search Usage]
