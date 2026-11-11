# Internal Users Search Adrian

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Product / Factiva / Factiva Search Usage |
| Owner | svc_dj tableaucdl_b2b |
| Created | 2026-04-29 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/4563203 |
| Archived | 2026-11-11 |

## Summary

1 data source(s) in the workbook; 1 with an Athena component (1 embedded, 0 published).

## "Internal Users Search Adrian" (embedded)

- **Shape:** Join of 3 tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Used by worksheets:** Sheet 1, Sheet 2, Sheet 3
- **Structure:**

```
- LEFT JOIN on lower([Custom SQL Query].[email]) = lower([HR data].[email_address])
  - LEFT JOIN on [Custom SQL Query].[department_code] = [Job Function].[Code]
    - Athena Custom SQL "Custom SQL Query" -> Internal Users Search Adrian - Custom SQL Query.sql
    - Google Drive Excel "(2)" table Sheet1$ (as "Job Function")
  - Athena Custom SQL "HR data" -> Internal Users Search Adrian - HR data.sql
```
- **Athena tables read:** `dimension_external_db.pib_membership_dimension`, `fact_external_db.omniture_event_fact`, `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `reference_external_db.country_reference`, `dimension_external_db.workday_employee_current`
- **SQL files:** [Internal Users Search Adrian - Custom SQL Query.sql](Internal%20Users%20Search%20Adrian%20-%20Custom%20SQL%20Query.sql), [Internal Users Search Adrian - HR data.sql](Internal%20Users%20Search%20Adrian%20-%20HR%20data.sql)
