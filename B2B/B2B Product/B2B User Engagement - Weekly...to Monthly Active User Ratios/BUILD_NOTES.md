# B2B User Engagement - Weekly and Daily to Monthly Active User Ratios

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Product |
| Owner | James Thomson |
| Created | 2025-07-28 |
| Last updated | 2026-05-06 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/3087097 |
| Archived | 2026-11-11 |

## Summary

1 data source(s) in the workbook; 1 with an Athena component (0 embedded, 1 published).

## "DAU_WAU_MAU" (published data source)

- **Published source:** "B2B DAU_WAU_MAU" in `B2B / B2B Sales / Sales Leadership & Operations / Datasources`, owner James Thomson; [archived here](../../B2B%20Sales/Sales%20Leadership%20%26%20Operations/Datasources/B2B%20DAU_WAU_MAU). The SQL below is copied from it.
- **Shape:** Join of 3 tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Used by worksheets:** Classic, DAU MAU Chart, DJYP, New, Newsplus, RCFC, Risk Journal, Sheet 11, Sheet 2, Sheet 3, Sheet 4, Sheet 5, Sheet 6, WAU MAU Chart
- **Structure:**

```
- LEFT JOIN on [Custom SQL Query].[year_month_day] = [FYQ Lookup].[Day]
  - LEFT JOIN on [Custom SQL Query].[department_code] = [Job Function].[Code]
    - Athena Custom SQL "Custom SQL Query" -> DAU_WAU_MAU.sql
    - Google Drive Excel "Job Function2" table Sheet1$ (as "Job Function")
  - Google Drive Excel "FYQ lookup" table Sheet1$ (as "FYQ Lookup")
```
- **Athena tables read:** `reference_external_db.date_dimension`, `dimension_external_db.pib_membership_dimension`, `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `fact_external_db.omniture_event_fact`, `google_sheets_db.rcfc_access_code`, `fact_external_db.omniture_event_fact_hourly`, `subscription_external_db.identity_lookup`, `pib_event_data.pib_platform_trace`
- **SQL files:** [DAU_WAU_MAU.sql](DAU_WAU_MAU.sql)
