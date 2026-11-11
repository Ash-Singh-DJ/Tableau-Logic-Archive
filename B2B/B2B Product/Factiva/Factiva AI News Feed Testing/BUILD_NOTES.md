# Factiva AI News Feed Testing

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Product / Factiva |
| Owner | James Thomson |
| Created | 2026-07-01 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/5012210 |
| Archived | 2026-11-11 |

## Summary

1 data source(s) in the workbook; 1 with an Athena component (1 embedded, 0 published).

## "genai test" (embedded)

- **Shape:** Relationship model: 2 logical tables -- Athena + Snowflake
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Snowflake
- **Used by worksheets:** Sheet 1
- **Structure:**

```
Logical table "Custom SQL Query"
  - Snowflake Custom SQL "Custom SQL Query"
Logical table "Reported Usage"
  - Athena Custom SQL "Custom SQL Query1" -> genai test.sql
```

- **Relationships:**
  - "Custom SQL Query" ↔ "Reported Usage" on `[ACCOUNT_NUMBER] = [billing_account_id]`
- **Athena tables read:** `pib_event_data.gen_ai_article_usage`, `pib_event_data.user_key_billing_account_mappings`
- **Non-Athena Custom SQL (not archived):** "Custom SQL Query" (Snowflake)
- **SQL files:** [genai test.sql](genai%20test.sql)
