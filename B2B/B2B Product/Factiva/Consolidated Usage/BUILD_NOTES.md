# Consolidated Usage

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Product / Factiva |
| Owner | James Thomson |
| Created | 2025-12-08 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/3709610 |
| Archived | 2026-11-11 |

## Summary

1 data source(s) in the workbook; 1 with an Athena component (1 embedded, 0 published).

## "Consolidated usage" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Downloads, Downloads (2), Sheet 1, Sheet 1 (2), Sheet 2
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Consolidated usage.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `pib_event_data.gen_ai_article_usage`, `publisher_reporting_db.commerce_envelope`, `pib.email_open_rates`, `dimension_external_db.pib_alerts`, `dimension_external_db.pib_territory_dimension`, `dimension_external_db.pib_user_dimension`, `pib_event_data.pib_platform_trace`
- **SQL files:** [Consolidated usage.sql](Consolidated%20usage.sql)
