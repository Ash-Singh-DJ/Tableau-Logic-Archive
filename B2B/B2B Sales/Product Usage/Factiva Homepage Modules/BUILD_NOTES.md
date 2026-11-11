# Factiva Homepage Modules

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Sales / Product Usage |
| Owner | James Thomson |
| Created | 2025-10-15 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/3469710 |
| Archived | 2026-11-11 |

## Summary

2 data source(s) in the workbook; 2 with an Athena component (2 embedded, 0 published).

## "Homepage Modules" (embedded)

- **Shape:** Join of 3 tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Used by worksheets:** DAUs, DAUss, MAUs, Pivot Table, Top Users1, WAUs, WAUss
- **Structure:**

```
- LEFT JOIN on [Custom SQL Query].[company_industry] = [Industry].[SFDC Industry]
  - LEFT JOIN on [Custom SQL Query].[department_code] = [Job Function].[Code]
    - Athena Custom SQL "Custom SQL Query" -> Homepage Modules.sql
    - Google Drive Excel "Job Function" table Sheet1$ (as "Job Function")
  - Google Drive Excel "Industry Mapping" table Sheet1$ (as "Industry")
```
- **Athena tables read:** `reference_external_db.date_dimension`, `dimension_external_db.pib_membership_dimension`, `fact_external_db.omniture_event_fact`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [Homepage Modules.sql](Homepage%20Modules.sql)

## "Admin" (embedded)

- **Shape:** Join of 3 tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Used by worksheets:** Admin PVs, Admin Users
- **Structure:**

```
- LEFT JOIN on [Custom SQL Query].[company_industry] = [Idustry lookup].[SFDC Industry]
  - LEFT JOIN on [Custom SQL Query].[department_code] = [JOb Function].[Code]
    - Athena Custom SQL "Custom SQL Query" -> Admin.sql
    - Google Drive Excel "Job Function" table Sheet1$ (as "JOb Function")
  - Google Drive Excel "Industry Mapping" table Sheet1$ (as "Idustry lookup")
```
- **Athena tables read:** `reference_external_db.date_dimension`, `dimension_external_db.pib_membership_dimension`, `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [Admin.sql](Admin.sql)
