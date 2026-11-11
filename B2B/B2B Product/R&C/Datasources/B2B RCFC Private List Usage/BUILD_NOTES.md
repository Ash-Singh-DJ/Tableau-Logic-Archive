# B2B RCFC Private List Usage

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Product / R&C / Datasources |
| Owner | Maria Peco |
| Created | 2025-07-29 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/101776453 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / reference_external_db)
- **Structure:**

```
- Athena Custom SQL "User & Usage Information" -> User & Usage Information.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [User & Usage Information.sql](User%20%26%20Usage%20Information.sql)

## Connected workbooks

- [B2B RCFC Private List Usage Dashboard](../../B2B%20RCFC%20Private%20List%20Usage%20Dashboard) [B2B / B2B Product / R&C]
