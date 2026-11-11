# Factiva UI monthly

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Product / Factiva |
| Owner | James Thomson |
| Created | 2026-03-26 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/4307569 |
| Archived | 2026-11-11 |

## Summary

4 data source(s) in the workbook; 4 with an Athena component (2 embedded, 2 published).

## "Reg users" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Factiva Registered Users
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Reg users.sql
```
- **Athena tables read:** `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `reference_external_db.pib_product_dimension`
- **SQL files:** [Reg users.sql](Reg%20users.sql)

## "genairetrieve" (published data source)

- **Published source:** "genairetrieve" in `B2B / B2B Product / Factiva`, owner James Thomson; [archived here](../genairetrieve). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** GenAI Retrieval Usage
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> genairetrieve.sql
```
- **Athena tables read:** `pib_event_data.pib_platform_trace`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [genairetrieve.sql](genairetrieve.sql)

## "gen_ai_article_usage" (published data source)

- **Published source:** "gen_ai_article_usage" in `B2B / B2B Product / Factiva`, owner James Thomson; [archived here](../gen_ai_article_usage). The SQL below is copied from it.
- **Shape:** Join of 2 tables
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / pib_event_data)
- **Used by worksheets:** GenAI Article Feed Usage
- **Structure:**

```
- LEFT JOIN on [gen_ai_article_usa].[user_key] = [Comp lookup].[user_key]
  - Athena table pib_event_data.gen_ai_article_usage (as "gen_ai_article_usa")
  - Athena Custom SQL "Comp lookup" -> gen_ai_article_usage.sql
```
- **Athena tables read:** `pib_event_data.gen_ai_article_usage`, `pib_event_data.user_key_billing_account_mappings`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [gen_ai_article_usage.sql](gen_ai_article_usage.sql)

## "Factiva UI monthly" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** UI Article Downloads, UI Article Views, UI Unique Users, UI Visits
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Factiva UI monthly.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `reference_external_db.pib_product_dimension`
- **SQL files:** [Factiva UI monthly.sql](Factiva%20UI%20monthly.sql)
