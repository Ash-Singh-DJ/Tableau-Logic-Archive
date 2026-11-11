# B2B First time Login users

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Sales / Sales Leadership & Operations / Datasources |
| Owner | James Thomson |
| Created | 2025-07-28 |
| Last updated | 2026-05-05 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/90015222 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Structure:**

```
- Athena Custom SQL "First Time Login" -> First Time Login.sql
```
- **Athena tables read:** `google_sheets_db.saml_master_list_b2b_current`, `fact_external_db.omniture_event_fact`, `dimension_external_db.pib_membership_dimension`
- **SQL files:** [First Time Login.sql](First%20Time%20Login.sql)

## Connected workbooks

_No connected workbooks found._
