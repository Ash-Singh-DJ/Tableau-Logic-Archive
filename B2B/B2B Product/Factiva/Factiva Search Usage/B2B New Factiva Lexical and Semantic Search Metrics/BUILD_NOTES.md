# B2B New Factiva Lexical and Semantic Search Metrics

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Product / Factiva / Factiva Search Usage |
| Owner | James Thomson |
| Created | 2025-06-09 |
| Last updated | 2025-11-12 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/2855415 |
| Archived | 2026-11-11 |

## Summary

4 data source(s) in the workbook; 4 with an Athena component (0 embedded, 4 published).

## "Search Sequence II" (published data source)

- **Published source:** "Search Sequence II" in `B2B / B2B Product / Factiva / Factiva Search Usage`, owner James Thomson; [archived here](../Search%20Sequence%20II). The SQL below is copied from it.
- **Shape:** Relationship model: 2 logical tables (with joins inside)
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** By User, Comparison 1, Comparison 2, Con Articles per search, Daily Search Count %, Daily Search Count % (3), Distribution, Dwell Time by Position, Dwell Time by Position (2), Glossary, MMR, MMR (2), MMR table, MMR table (2), MRR@20 Daily Trend, Rank Distribution, Rank Distribution (2), Rank@20 Daily Trend, Search Conversion Daily Trend, Search Count, Search Count %, Search Count % (2), Search Count % (3), Search Count Exits, Search Count Exits %, Sem Search Count %, Sheet 1, Sheet 10, Sheet 12, Sheet 17, Sheet 18, Sheet 2, Sheet 3, Sheet 35, Sheet 36, Sheet 4, Sheet 5, Sheet 50, Sheet 50 (3), Sheet 51, Sheet 56, Sheet 57, Sheet 57 (2), Sheet 59, Sheet 6, Sheet 60, Sheet 61, Sheet 62, Sheet 63, Sheet 7, Sheet 8, Sheet 9, sum table
- **Structure:**

```
Logical table "Custom SQL Query"
  - LEFT JOIN on [Custom SQL Query].[EID] = [Usage].[EID]
    - Athena Custom SQL "Custom SQL Query" -> Search Sequence II - Custom SQL Query.sql
    - Athena Custom SQL "Usage" -> Search Sequence II - Usage.sql
Logical table "Lang config"
  - Athena Custom SQL "Custom SQL Query1" -> Search Sequence II - Custom SQL Query1.sql
```

- **Relationships:**
  - "Custom SQL Query" ↔ "Lang config" on `[EID] = [user_info_user_ref]`
- **Athena tables read:** `reference_external_db.date_dimension`, `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [Search Sequence II - Custom SQL Query.sql](Search%20Sequence%20II%20-%20Custom%20SQL%20Query.sql), [Search Sequence II - Usage.sql](Search%20Sequence%20II%20-%20Usage.sql), [Search Sequence II - Custom SQL Query1.sql](Search%20Sequence%20II%20-%20Custom%20SQL%20Query1.sql)

## "Single Search CF" (published data source)

- **Published source:** "Single Search CF" in `B2B / B2B Product / Factiva / Factiva Search Usage`, owner James Thomson; [archived here](../Single%20Search%20CF). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Sheet 34
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Single Search CF.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`
- **SQL files:** [Single Search CF.sql](Single%20Search%20CF.sql)

## "Single Search Abandoned Users" (published data source)

- **Published source:** "Single Search Abandoned Users" in `B2B / B2B Product / Factiva / Factiva Search Usage`, owner James Thomson; [archived here](../Single%20Search%20Abandoned%20Users). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Search Abandon, Sheet 31, Sheet 32 (2), sem search
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Single Search Abandoned Users.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`
- **SQL files:** [Single Search Abandoned Users.sql](Single%20Search%20Abandoned%20Users.sql)

## "Semantic Search vol2" (published data source)

- **Published source:** "Semantic Search vol2" in `B2B / B2B Product / Factiva / Factiva Search Usage`, owner James Thomson; [archived here](../Semantic%20Search%20vol2). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** By Search Type Pie, By Search Type table, By Search Type table (2), Lex override %, Lex override % (2), actions disable AIsearch, lexical and sem override
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Semantic Search vol2.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [Semantic Search vol2.sql](Semantic%20Search%20vol2.sql)
