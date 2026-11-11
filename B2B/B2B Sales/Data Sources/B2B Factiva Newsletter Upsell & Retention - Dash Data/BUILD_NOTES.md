# B2B Factiva Newsletter Upsell & Retention -  Dash Data

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Sales / Data Sources |
| Owner | Maria Peco |
| Created | 2025-08-11 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/94372087 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Structure:**

```
- Athena Custom SQL "Newsletter Retention Data" -> Newsletter Retention Data.sql
```
- **Athena tables read:** `fact_external_db.omniture_event_fact`, `dimension_external_db.pib_membership_dimension`, `reference_external_db.date_dimension`, `fact_external_db.pib_membership_fact`, `dimension_external_db.pib_billing_account_dimension`, `fact_external_db.pib_account_hierarchy_fact`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_territory_dimension`, `dimension_external_db.pib_user_dimension`
- **SQL files:** [Newsletter Retention Data.sql](Newsletter%20Retention%20Data.sql)

## Connected workbooks

- [ B2B Factiva Newsletter Upsell & Retention Dashboard](../../../Factiva%20Legacy%20%28for%20review%29/B2B%20Factiva%20Newsletter%20Upsell%20%26%20Retention%20Dashboard) [B2B / Factiva Legacy (for review)]
