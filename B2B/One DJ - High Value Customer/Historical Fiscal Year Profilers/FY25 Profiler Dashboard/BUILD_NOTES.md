# FY25 Profiler Dashboard

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / One DJ - High Value Customer / Historical Fiscal Year Profilers |
| Owner | Aishwarya Singh |
| Created | 2025-09-23 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/3374476 |
| Archived | 2026-11-11 |

## Summary

4 data source(s) in the workbook; 3 with an Athena component (3 embedded, 0 published).
Other data sources: "Profiler Dashboard Glossary" (Google Drive Excel).

## "Terr Map" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / sandbox_mk)
- **Used by worksheets:** page_hvcs_total, sheet_brand_pivot, sheet_hvcs
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Terr Map.sql
```
- **Athena tables read:** `dnb_firmographic_db.company_information_current`, `dnb_firmographic_db.corporate_linkage_current`, `google_sheets_db.dnb_hvcs_global_ultimate_override`, `sandbox_hvc.duns_profiler_tranche13`
- **SQL files:** [Terr Map.sql](Terr%20Map.sql)

## "Date Display" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** page_last_updated
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Date Display.sql
```
- **Athena tables read:** `sandbox_hvc.date_alignment`, `sandbox_hvc.date_alignment_desync`
- **SQL files:** [Date Display.sql](Date%20Display.sql)

## "Custom SQL Query (dimension_external_db)" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** page_company_name, page_company_staticinfo, page_global_ult_main_acct_owners, page_global_ult_name, page_hvcs_total, page_summary_guc_count_industry, page_summary_pie, page_summary_pie_topn, page_topn_clients, page_topn_guc_count_industry, page_topn_rev_display, page_total_rev_display, sheet_acct_owner_level, sheet_brand_pivot, sheet_company_level, sheet_global_ult_level, sheet_hierarchy_level, sheet_hvcs
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Custom SQL Query (dimension_external_db).sql
```
- **Athena tables read:** `dnb_firmographic_db.company_information_current`, `dnb_firmographic_db.corporate_linkage_current`, `dnb_firmographic_db.contact_and_location_current`, `dnb_firmographic_db.industry_and_activity_current`, `reference_external_db.industry_codes_sic`, `reference_external_db.industry_codes_naics`, `google_sheets_db.dnb_hvcs_global_ultimate_override`, `sandbox_hvc.high_value_clients`, `sandbox_hvc.duns_profiler_tranche13`, `sandbox_hvc.industry_sectors`, `sandbox_hvc.holding_companies`, `sandbox_mk.opps_b2b`, `sandbox_mk.opps_cma`, `sandbox_mk.opps_adv`, `sandbox_hvc.opp_prod_mapping`
- **SQL files:** [Custom SQL Query (dimension_external_db).sql](Custom%20SQL%20Query%20%28dimension_external_db%29.sql)
