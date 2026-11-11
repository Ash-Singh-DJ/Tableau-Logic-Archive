# B2B Factiva Gen AI Article Usage - Data Source

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Product / Factiva / Datasources |
| Owner | James Thomson |
| Created | 2025-09-10 |
| Last updated | 2026-05-05 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/97502884 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Join of 2 tables
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / pib_event_data)
- **Structure:**

```
- LEFT JOIN on [gen_ai_article_usa].[user_key] = [Comp lookup].[user_key]
  - Athena table pib_event_data.gen_ai_article_usage (as "gen_ai_article_usa")
  - Athena Custom SQL "Comp lookup" -> Comp lookup.sql
```
- **Athena tables read:** `pib_event_data.gen_ai_article_usage`, `pib_event_data.user_key_billing_account_mappings`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [Comp lookup.sql](Comp%20lookup.sql)

## Connected workbooks

_No connected workbooks found._
