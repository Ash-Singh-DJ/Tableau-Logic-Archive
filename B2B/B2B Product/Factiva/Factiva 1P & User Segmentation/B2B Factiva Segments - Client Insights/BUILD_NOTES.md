# B2B Factiva Segments - Client Insights

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Product / Factiva / Factiva 1P & User Segmentation |
| Owner | Porfirio Hernandez |
| Created | 2025-05-23 |
| Last updated | 2025-09-02 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/2786456 |
| Archived | 2026-11-11 |

## Summary

2 data source(s) in the workbook; 2 with an Athena component (0 embedded, 2 published).

## "Factiva User Seg Micro 6mo" (published data source)

- **Published source:** "B2B Factiva Segments Client Insights - User Seg Micro 6mo" in `B2B / B2B Product / Factiva / Datasources`, owner Maria Peco; [archived here](../../Datasources/B2B%20Factiva%20Segments%20Client%20Insights%20-%20User%20Seg%20Micro%206mo). The SQL below is copied from it.
- **Shape:** Join of 2 tables
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / zoolander_db)
- **Used by worksheets:** Avg Click Activity Distribution, Count Internal Accounts, Micro Model Users List, Micro Users List Selected Info, Usage Time Window, micro 1P Data along rows
- **Structure:**

```
- INNER JOIN on [Custom SQL Query].[territory_name] = [geo_region_mapping].[territory_name]
  - Athena Custom SQL "Custom SQL Query" -> Factiva User Seg Micro 6mo - Custom SQL Query.sql
  - Athena Custom SQL "geo_region_mapping" -> Factiva User Seg Micro 6mo - geo_region_mapping.sql
```
- **Athena tables read:** `dimension_external_db.dnb_contact_and_location`, `zoolander_db.factiva_micro_user_seg_6mo`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_territory_dimension`
- **SQL files:** [Factiva User Seg Micro 6mo - Custom SQL Query.sql](Factiva%20User%20Seg%20Micro%206mo%20-%20Custom%20SQL%20Query.sql), [Factiva User Seg Micro 6mo - geo_region_mapping.sql](Factiva%20User%20Seg%20Micro%206mo%20-%20geo_region_mapping.sql)

## "Segments All Dates" (published data source)

- **Published source:** "B2B Factiva Segments Client Insights - All Dates" in `B2B / B2B Product / Factiva / Datasources`, owner Maria Peco; [archived here](../../Datasources/B2B%20Factiva%20Segments%20Client%20Insights%20-%20All%20Dates). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / zoolander_db)
- **Used by worksheets:** micro model cluster migration
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Segments All Dates.sql
```
- **Athena tables read:** `zoolander_db.factiva_micro_user_seg_6mo`
- **SQL files:** [Segments All Dates.sql](Segments%20All%20Dates.sql)
