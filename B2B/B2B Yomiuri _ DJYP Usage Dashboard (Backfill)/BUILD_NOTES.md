# B2B Yomiuri _ DJYP Usage Dashboard (Backfill)

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B |
| Owner | svc_dj tableaucdl_b2b |
| Created | 2026-07-06 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/5042289 |
| Archived | 2026-11-11 |

## Summary

2 data source(s) in the workbook; 1 with an Athena component (1 embedded, 0 published).
Other data sources: "B2B DJYP - Returning Users | Project : Datasources" (published).

## "DJY - Test" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / abc_matrix)
- **Used by worksheets:** 1.AV Sum, 1.Activity (Pie%), 1.Activity (Pie), 1.Daily AV (chart), 1.Daily HL, 1.Daily PR, 1.Daily PV (chart), 1.Daily SV, 1.Daily Visit (chart), 1.Daily users (chart), 1.HL Sum, 1.PR Sum, 1.PV Sum, 1.SV Sum, 1.User Sum, 1.Visit Sum, 1.timestamp, 2. Daily Activity (BA), 2.User Details, 3.Device (OS Type), 3.Device users (#), 3.Device users (%), 3.Device users (chart), 5.Visit Hourly, 5.Visit Hourly (Chart), 5.Visit Hourly (device chart), 5.Visit Hourly (device), 6.Visit Weekly, 6.Visit Weekly (Chart), 6.Visit Weekly (device chart), 6.Visit Weekly (device), Daily Activity, Daily users (OS version), Daily users (browser), Headlines , Headlines News
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> DJY - Test.sql
```
- **Athena tables read:** `fact_external_db.omniture_event_fact_hourly`, `subscription_external_db.identity_lookup`, `dimension_external_db.pib_membership_dimension`, `pib_event_data.pib_platform_trace`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [DJY - Test.sql](DJY%20-%20Test.sql)
