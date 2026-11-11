# B2B Factiva Gen AI Article Usage

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Product / Factiva |
| Owner | svc_dj tableaucdl_b2b |
| Created | 2025-09-10 |
| Last updated | 2026-10-21 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/3300299 |
| Archived | 2026-11-11 |

## Summary

7 data source(s) in the workbook; 5 with an Athena component (0 embedded, 5 published).
Other data sources: "GenAI Retrieval SNOWFLAKE" (published); "(CIBS) GenAI Article Usage" (published).

## "genai test" (published data source)

- **Published source:** "genai test" in `B2B / B2B Product / Data sources`, owner James Thomson; [archived here](../../Data%20sources/genai%20test). The SQL below is copied from it.
- **Shape:** Relationship model: 2 logical tables -- Athena + Snowflake
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Snowflake
- **Used by worksheets:** Total Articles Reported and Consumed
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

## "genairetrieve" (published data source)

- **Published source:** "genairetrieve" in `B2B / B2B Product / Factiva`, owner James Thomson; [archived here](../genairetrieve). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** _none (data source is unused in this workbook)_
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> genairetrieve.sql
```
- **Athena tables read:** `pib_event_data.pib_platform_trace`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [genairetrieve.sql](genairetrieve.sql)

## "Split by Source" (published data source)

- **Published source:** "Split by Source" in `B2B / B2B Product / Factiva`, owner James Thomson; [archived here](../Split%20by%20Source). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Split by Source
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Split by Source.sql
```
- **Athena tables read:** `pib_event_data.user_key_billing_account_mappings`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `pib_event_data.gen_ai_article_usage`, `sandbox_mk.source_db_clean`
- **SQL files:** [Split by Source.sql](Split%20by%20Source.sql)

## "Src Breakdown" (published data source)

- **Published source:** "Src Breakdown" in `B2B / B2B Product / Factiva`, owner James Thomson; [archived here](../Src%20Breakdown). The SQL below is copied from it.
- **Shape:** Join of 2 tables
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / sandbox_mk)
- **Used by worksheets:** Sheet 26
- **Structure:**

```
- LEFT JOIN on [Custom SQL Query].[source_code] = [source_db_clean].[sourcecode]
  - Athena Custom SQL "Custom SQL Query" -> Src Breakdown.sql
  - Athena table sandbox_mk.source_db_clean (as "source_db_clean")
```
- **Athena tables read:** `pib_event_data.pib_platform_trace`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `sandbox_mk.source_db_clean`
- **SQL files:** [Src Breakdown.sql](Src%20Breakdown.sql)

## "gen_ai_article_usage" (published data source)

- **Published source:** "gen_ai_article_usage" in `B2B / B2B Product / Factiva`, owner James Thomson; [archived here](../gen_ai_article_usage). The SQL below is copied from it.
- **Shape:** Join of 2 tables
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / pib_event_data)
- **Used by worksheets:** Article Views, Article Views MoM, Avg Work IDs per User, Avg Work IDs per use (2), Sheet 1, Sheet 1 (2), Top Companies, Unique Users, Unique Users MoM, Unique Work IDs, Work IDs MoM
- **Structure:**

```
- LEFT JOIN on [gen_ai_article_usa].[user_key] = [Comp lookup].[user_key]
  - Athena table pib_event_data.gen_ai_article_usage (as "gen_ai_article_usa")
  - Athena Custom SQL "Comp lookup" -> gen_ai_article_usage.sql
```
- **Athena tables read:** `pib_event_data.gen_ai_article_usage`, `pib_event_data.user_key_billing_account_mappings`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [gen_ai_article_usage.sql](gen_ai_article_usage.sql)
