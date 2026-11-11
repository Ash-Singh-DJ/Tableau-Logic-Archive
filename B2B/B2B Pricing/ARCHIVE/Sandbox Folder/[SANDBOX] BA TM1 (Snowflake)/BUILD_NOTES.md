# [SANDBOX] BA TM1 (Snowflake)

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Pricing / ARCHIVE / Sandbox Folder |
| Owner | Jonas Coelho |
| Created | 2026-06-23 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/4959883 |
| Archived | 2026-11-11 |

## Summary

1 data source(s) in the workbook; 1 with an Athena component (1 embedded, 0 published).

## "Historical Pricing TM1" (embedded)

- **Shape:** Join of 2 tables -- Google Drive Excel + Snowflake
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Google Drive Excel; Snowflake
- **Used by worksheets:** TM1 Explorer
- **Structure:**

```
- LEFT JOIN on lower([B2B_BILLING_ACCOUNT_TM1].[bill_acct_country]) = lower([Emerging Market Countries].[Country])
  - Snowflake table SANDBOX.B2B.B2B_BILLING_ACCOUNT_TM1 (as "B2B_BILLING_ACCOUNT_TM1")
  - Google Drive Excel "(2)" table Sheet1$ (as "Emerging Market Countries")
```
- **SQL files:** _none -- Athena is read as plain table(s), no Custom SQL_
