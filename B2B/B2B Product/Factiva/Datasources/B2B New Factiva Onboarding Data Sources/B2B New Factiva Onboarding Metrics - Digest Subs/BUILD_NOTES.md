# B2B New Factiva Onboarding Metrics - Digest Subs

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Product / Factiva / Datasources / B2B New Factiva Onboarding Data Sources |
| Owner | Maria Peco |
| Created | 2025-08-26 |
| Last updated | 2026-05-05 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/100670772 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Custom SQL Query.sql
```
- **Athena tables read:** `reference_external_db.date_dimension`, `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_membership_dimension`
- **SQL files:** [Custom SQL Query.sql](Custom%20SQL%20Query.sql)

## Connected workbooks

- [B2B New Factiva Onboarding Metrics](../../../../../Factiva%20Legacy%20%28for%20review%29/B2B%20New%20Factiva%20Onboarding%20Metrics) [B2B / Factiva Legacy (for review)]
