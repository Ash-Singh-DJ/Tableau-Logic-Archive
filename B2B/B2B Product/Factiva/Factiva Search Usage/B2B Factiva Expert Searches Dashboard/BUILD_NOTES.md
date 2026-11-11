# B2B Factiva Expert Searches Dashboard

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Product / Factiva / Factiva Search Usage |
| Owner | Maria Peco |
| Created | 2025-07-14 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/3014899 |
| Archived | 2026-11-11 |

## Summary

1 data source(s) in the workbook; 1 with an Athena component (1 embedded, 0 published).

## "FES" (embedded)

- **Shape:** Join of 2 tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Used by worksheets:** Sheet 1, Sheet 2, Sheet 3, Sheet 4, Sheet 5, Sheet 6, Sheet 7
- **Structure:**

```
- LEFT JOIN on [Custom SQL Query].[search_code] = [Searches_as of Jan 2026].[Search Code]
  - Athena Custom SQL "Custom SQL Query" -> FES.sql
  - Google Drive Excel "FES Mapping" table Searches_as of Jan 2026$ (as "Searches_as of Jan 2026")
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `fact_external_db.pib_membership_fact`, `reference_external_db.pib_product_master`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_contract_dimension`, `fact_external_db.pib_account_hierarchy_fact`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_territory_dimension`, `sandbox_mk.geo_region_rollup`
- **SQL files:** [FES.sql](FES.sql)
