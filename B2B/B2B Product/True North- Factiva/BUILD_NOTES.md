# True North: Factiva

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Product |
| Owner | svc_dj tableaucdl_b2b |
| Created | 2026-03-19 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/4260945 |
| Archived | 2026-11-11 |

## Summary

5 data source(s) in the workbook; 4 with an Athena component (4 embedded, 0 published).
Other data sources: "True North Fact NPS" (Google Drive Excel).

## "Consolidated article usage" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Consolidated, Consolidated (2), Consolidated (3), Sheet 25, Sheet 26
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Consolidated article usage.sql
```
- **Athena tables read:** `reference_external_db.date_dimension`, `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `pib_event_data.gen_ai_article_usage`, `pib_event_data.user_key_billing_account_mappings`, `publisher_reporting_db.commerce_envelope`, `fact_external_db.omniture_event_fact`, `pib.email_open_rates`, `dimension_external_db.pib_alerts`, `dimension_external_db.pib_territory_dimension`, `dimension_external_db.pib_user_dimension`, `pib_event_data.pib_platform_trace`
- **SQL files:** [Consolidated article usage.sql](Consolidated%20article%20usage.sql)

## "PlatPref3" (embedded)

- **Shape:** Join of 2 tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Used by worksheets:** Pref1, Pref1 (2)
- **Structure:**

```
- LEFT JOIN on [Custom SQL Query].[department_code] = [Job Function].[Code]
  - Athena Custom SQL "Custom SQL Query" -> PlatPref3.sql
  - Google Drive Excel "Job Function" table Sheet1$ (as "Job Function")
```
- **Athena tables read:** `reference_external_db.date_dimension`, `dimension_external_db.pib_membership_dimension`, `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [PlatPref3.sql](PlatPref3.sql)

## "DAU WAU Trend" (embedded)

- **Shape:** Join of 3 tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Used by worksheets:** AVG MAU, DAU / MAU, Sheet 14, Sheet 14 (2), Sheet 20, Sheet 21, Sheet 22, WAU / DAU JF, WAU / MAU, WAU / MAU JF
- **Structure:**

```
- LEFT JOIN on [Custom SQL Query].[department_code] = [Job Function].[Code]
  - LEFT JOIN on [Custom SQL Query].[year_month_day] = [FYQ Lookup].[Day]
    - Athena Custom SQL "Custom SQL Query" -> DAU WAU Trend.sql
    - Google Drive Excel "FYQ lookup" table Sheet1$ (as "FYQ Lookup")
  - Google Drive Excel "Job Function" table Sheet1$ (as "Job Function")
```
- **Athena tables read:** `reference_external_db.date_dimension`, `dimension_external_db.pib_membership_dimension`, `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [DAU WAU Trend.sql](DAU%20WAU%20Trend.sql)

## "Job Function Pie" (embedded)

- **Shape:** Join of 2 tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Used by worksheets:** JF Pct Trend, JF Pie, JF Trend, JF1
- **Structure:**

```
- LEFT JOIN on [Custom SQL Query].[department_code] = [Job Function].[Code]
  - Athena Custom SQL "Custom SQL Query" -> Job Function Pie.sql
  - Google Drive Excel "Job Function" table Sheet1$ (as "Job Function")
```
- **Athena tables read:** `reference_external_db.date_dimension`, `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`
- **SQL files:** [Job Function Pie.sql](Job%20Function%20Pie.sql)
