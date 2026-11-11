# DJ B2B Xsell Dashboard (Deprecated)

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Sales / Cross-sell & Upsell |
| Owner | Aishwarya Singh |
| Created | 2025-09-08 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/3289242 |
| Archived | 2026-11-11 |

## Summary

4 data source(s) in the workbook; 2 with an Athena component (2 embedded, 0 published).
Other data sources: "New Products" (Google Drive Excel); "Cross-Sell Feedback Form" (Google Drive Excel).

## "Main CustomSQL Stack" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dnb_firmographic_db)
- **Used by worksheets:** page_industry_pie, page_median_spend, page_product_spenders_count, page_spenders_count, page_suggested_comps_count, sheet_acct_pivot, sheet_industry_product, sheet_suggestions
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Main CustomSQL Stack.sql
```
- **Athena tables read:** `dnb_firmographic_db.company_information_current`, `sandbox_mk.b2b_revenue`, `sandbox_hvc.firmographic_summary`, `sandbox_mk.temp_table`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_territory_dimension`, `dimension_external_db.pib_user_dimension`, `sandbox_hvc.ftva_prod_override`, `sandbox_hvc.nwrs_prod_override`, `sandbox_hvc.rnc_prod_override`, `sandbox_hvc.fy24_profiler_data_snapshot`
- **SQL files:** [Main CustomSQL Stack.sql](Main%20CustomSQL%20Stack.sql)

## "Raw Xsell Suggestions" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / sandbox_hvc)
- **Used by worksheets:** sheet_suggestions
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Raw Xsell Suggestions.sql
```
- **Athena tables read:** `sandbox_mk.temp_table`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_territory_dimension`, `dimension_external_db.pib_user_dimension`, `sandbox_hvc.firmographic_summary`
- **SQL files:** [Raw Xsell Suggestions.sql](Raw%20Xsell%20Suggestions.sql)
