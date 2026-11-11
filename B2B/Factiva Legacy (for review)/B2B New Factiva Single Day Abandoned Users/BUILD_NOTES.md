# B2B New Factiva Single Day Abandoned Users

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / Factiva Legacy (for review) |
| Owner | Maria Peco |
| Created | 2025-07-28 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/3087043 |
| Archived | 2026-11-11 |

## Summary

1 data source(s) in the workbook; 1 with an Athena component (1 embedded, 0 published).

## "KPI MW" (embedded)

- **Shape:** Join of 2 tables
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Sheet 1, Sheet 2, Sheet 3, Sheet 3 (2), Sheet 5
- **Structure:**

```
- LEFT JOIN on LEFT(STR(DATE(DATEADD('month',1,DATE([Custom SQL Query].[onbo_year_month]+'-01' )))),7) = [OnboPlusOne].[year_month] AND [Custom SQL Query].[pib_member_id] = [OnboPlusOne].[pib_member_id]
  - Athena Custom SQL "Custom SQL Query" -> KPI MW - Custom SQL Query.sql
  - Athena Custom SQL "OnboPlusOne" -> KPI MW - OnboPlusOne.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [KPI MW - Custom SQL Query.sql](KPI%20MW%20-%20Custom%20SQL%20Query.sql), [KPI MW - OnboPlusOne.sql](KPI%20MW%20-%20OnboPlusOne.sql)
