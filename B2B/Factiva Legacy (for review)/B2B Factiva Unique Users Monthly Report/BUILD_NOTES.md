# B2B Factiva Unique Users Monthly Report

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / Factiva Legacy (for review) |
| Owner | Maria Peco |
| Created | 2025-07-01 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/2954779 |
| Archived | 2026-11-11 |

## Summary

5 data source(s) in the workbook; 5 with an Athena component (5 embedded, 0 published).

## "Unique Users" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Factiva Unique Users, Sheet 3
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Unique Users.sql
```
- **Athena tables read:** `fact_external_db.omniture_event_fact`, `dimension_external_db.pib_membership_dimension`, `pib_event_data.pib_product_metrics`
- **SQL files:** [Unique Users.sql](Unique%20Users.sql)

## "Weekly MCT" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** WAU, WAU Chart
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Weekly MCT.sql
```
- **Athena tables read:** `reference_external_db.date_dimension`, `fact_external_db.omniture_event_fact`
- **SQL files:** [Weekly MCT.sql](Weekly%20MCT.sql)

## "MCT UVs" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** MCT Users
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> MCT UVs.sql
```
- **Athena tables read:** `fact_external_db.omniture_event_fact`
- **SQL files:** [MCT UVs.sql](MCT%20UVs.sql)

## "MCT Daily" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** DAU, DAU chart
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> MCT Daily.sql
```
- **Athena tables read:** `reference_external_db.date_dimension`, `fact_external_db.omniture_event_fact`
- **SQL files:** [MCT Daily.sql](MCT%20Daily.sql)

## "Question re mobile" (embedded)

- **Shape:** Join of 2 tables
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Sheet 4, Sheet 5
- **Structure:**

```
- LEFT JOIN on [Custom SQL Query].[post_evar3] = [onboarding].[user_info_user_ref]
  - Athena Custom SQL "Custom SQL Query" -> Question re mobile - Custom SQL Query.sql
  - Athena Custom SQL "onboarding" -> Question re mobile - onboarding.sql
```
- **Athena tables read:** `fact_external_db.omniture_event_fact`, `dimension_external_db.pib_membership_dimension`, `reference_external_db.pib_product_dimension`, `pib_event_data.pib_product_metrics`
- **SQL files:** [Question re mobile - Custom SQL Query.sql](Question%20re%20mobile%20-%20Custom%20SQL%20Query.sql), [Question re mobile - onboarding.sql](Question%20re%20mobile%20-%20onboarding.sql)
