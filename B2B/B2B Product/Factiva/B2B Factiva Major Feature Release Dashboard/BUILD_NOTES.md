# B2B Factiva Major Feature Release Dashboard

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Product / Factiva |
| Owner | James Thomson |
| Created | 2025-07-29 |
| Last updated | 2026-07-03 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/3093351 |
| Archived | 2026-11-11 |

## Summary

2 data source(s) in the workbook; 2 with an Athena component (0 embedded, 2 published).

## "New Features" (published data source)

- **Published source:** "B2B Factiva Major Feature Release - New Features" in `B2B / B2B Product / Factiva / Datasources`, owner James Thomson; [archived here](../Datasources/B2B%20Factiva%20Major%20Feature%20Release%20-%20New%20Features). The SQL below is copied from it.
- **Shape:** Join of 3 tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Used by worksheets:** Met text, Met text user, Sheet 1, Sheet 10, Sheet 2, Sheet 4, Sheet 7, Sheet 8, Sheet 9
- **Structure:**

```
- LEFT JOIN on [Usage].[department_code] = [Job Function].[Code]
  - LEFT JOIN on [Usage].[EID] = [Cluster Name].[eid]
    - Athena Custom SQL "Usage" -> New Features - Usage.sql
    - Athena Custom SQL "Cluster Name" -> New Features - Cluster Name.sql
  - Google Drive Excel "Job Function2" table Sheet1$ (as "Job Function")
```
- **Athena tables read:** `dimension_external_db.pib_membership_dimension`, `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `sandbox_mk.factiva_user_seg_12mo`
- **SQL files:** [New Features - Usage.sql](New%20Features%20-%20Usage.sql), [New Features - Cluster Name.sql](New%20Features%20-%20Cluster%20Name.sql)

## "Front page" (published data source)

- **Published source:** "B2B Factiva Major Feature Release -  Front page" in `B2B / B2B Product / Factiva / Datasources`, owner James Thomson; [archived here](../Datasources/B2B%20Factiva%20Major%20Feature%20Release%20-%20Front%20page). The SQL below is copied from it.
- **Shape:** Relationship model: 2 logical tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Used by worksheets:** Sheet 11, Sheet 3
- **Structure:**

```
Logical table "Release Dates"
  - Google Drive Excel "Release Dates" table Sheet1$ (as "Sheet1")
Logical table "Custom SQL Query"
  - Athena Custom SQL "Custom SQL Query" -> Front page.sql
```

- **Relationships:**
  - "Custom SQL Query" ↔ "Release Dates" on `[Code] = [code]`
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`
- **SQL files:** [Front page.sql](Front%20page.sql)
