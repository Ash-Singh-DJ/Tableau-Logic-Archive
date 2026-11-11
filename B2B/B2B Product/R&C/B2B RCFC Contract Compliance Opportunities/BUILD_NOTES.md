# B2B RCFC Contract Compliance Opportunities

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Product / R&C |
| Owner | Thomas Russell |
| Created | 2025-09-10 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/3299313 |
| Archived | 2026-11-11 |

## Summary

1 data source(s) in the workbook; 1 with an Athena component (1 embedded, 0 published).

## "campaign_opps_influence (sandbox_russellt)" (embedded)

- **Shape:** Standalone table
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / sandbox_russellt)
- **Used by worksheets:** Annual Revenue, Last Refreshed, Opp Type Groups, Opportunity Summary, Report, Revenue by Type
- **Structure:**

```
- Athena table sandbox_russellt.campaign_opps_influence (as "campaign_opps_infl")
```
- **Athena tables read:** `sandbox_russellt.campaign_opps_influence`
- **SQL files:** _none -- Athena is read as plain table(s), no Custom SQL_
