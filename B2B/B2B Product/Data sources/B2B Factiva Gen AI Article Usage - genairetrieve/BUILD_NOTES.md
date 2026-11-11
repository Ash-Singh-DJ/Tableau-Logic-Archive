# B2B Factiva Gen AI Article Usage - genairetrieve

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Product / Data sources |
| Owner | James Thomson |
| Created | 2025-09-10 |
| Last updated | 2026-04-18 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/97502844 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Custom SQL Query.sql
```
- **Athena tables read:** `pib_event_data.pib_platform_trace`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [Custom SQL Query.sql](Custom%20SQL%20Query.sql)

## Connected workbooks

_No connected workbooks found._
