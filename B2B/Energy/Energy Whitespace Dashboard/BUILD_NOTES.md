# Energy Whitespace Dashboard

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / Energy |
| Owner | Aishwarya Singh |
| Created | 2025-06-26 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/2935021 |
| Archived | 2026-11-11 |

## Summary

1 data source(s) in the workbook; 1 with an Athena component (1 embedded, 0 published).

## "Main CustomSQL Stack" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dnb_firmographic_db)
- **Used by worksheets:** page_industry_pie, page_median_spend, page_product_spenders_count, page_spenders_count, page_suggested_comps_count, sheet_acct_pivot, sheet_industry_product
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Main CustomSQL Stack.sql
```
- **Athena tables read:** `dnb_firmographic_db.company_information_current`, `sandbox_hvc.opis_sales_hierarchy`, `dimension_external_db.pib_product_services_dimension`, `sandbox_spb.cmm_prod_override`, `sandbox_spb.opis_prod_override`, `sandbox_spb.cma_prod_override`, `sandbox_spb.opis_revenue`, `sandbox_hvc.firmographic_summary`, `sandbox_hvc.fy24_profiler_data_snapshot`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_territory_dimension`, `dimension_external_db.pib_user_dimension`
- **SQL files:** [Main CustomSQL Stack.sql](Main%20CustomSQL%20Stack.sql)
