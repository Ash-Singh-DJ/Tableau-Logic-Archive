# B2B Yomiuri User List

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Product / Newswires / DJ Yomiuri |
| Owner | Shirley Chu |
| Created | 2026-04-22 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/4511517 |
| Archived | 2026-11-11 |

## Summary

1 data source(s) in the workbook; 1 with an Athena component (1 embedded, 0 published).

## "DJY - Test" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / abc_matrix)
- **Used by worksheets:** User List
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> DJY - Test.sql
```
- **Athena tables read:** `fact_external_db.omniture_event_fact_hourly`, `subscription_external_db.identity_lookup`, `dimension_external_db.pib_membership_dimension`, `pib_event_data.pib_platform_trace`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [DJY - Test.sql](DJY%20-%20Test.sql)
