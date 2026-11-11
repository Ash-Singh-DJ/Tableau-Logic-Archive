# genai test

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Product / Data sources |
| Owner | James Thomson |
| Created | 2026-07-14 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/165429199 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Relationship model: 2 logical tables -- Athena + Snowflake
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Snowflake
- **Structure:**

```
Logical table "Custom SQL Query"
  - Snowflake Custom SQL "Custom SQL Query"
Logical table "Reported Usage"
  - Athena Custom SQL "Custom SQL Query1" -> Custom SQL Query1.sql
```

- **Relationships:**
  - "Custom SQL Query" ↔ "Reported Usage" on `[ACCOUNT_NUMBER] = [billing_account_id]`
- **Athena tables read:** `pib_event_data.gen_ai_article_usage`, `pib_event_data.user_key_billing_account_mappings`
- **Non-Athena Custom SQL (not archived):** "Custom SQL Query" (Snowflake)
- **SQL files:** [Custom SQL Query1.sql](Custom%20SQL%20Query1.sql)

## Connected workbooks

- [B2B Factiva Gen AI Article Usage](../../Factiva/B2B%20Factiva%20Gen%20AI%20Article%20Usage) [B2B / B2B Product / Factiva]
