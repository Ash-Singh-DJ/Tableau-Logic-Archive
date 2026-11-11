# B2B R&C API - Customer Lifetime Value

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Product / R&C / Datasources |
| Owner | Ashish Kumar |
| Created | 2026-03-24 |
| Last updated | 2026-05-05 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/139011786 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Custom SQL Query.sql
```
- **Athena tables read:** `dimension_external_db.pib_cibs_billing_charges_dimension`, `dimension_external_db.pib_billing_account_dimension`, `fact_external_db.tm1_fact`
- **SQL files:** [Custom SQL Query.sql](Custom%20SQL%20Query.sql)

## Connected workbooks

_No connected workbooks found._
