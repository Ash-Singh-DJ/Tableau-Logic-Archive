# B2B Factiva  Monetary Value Relative to Usage

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Product / Factiva |
| Owner | James Thomson |
| Created | 2025-06-11 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/2866377 |
| Archived | 2026-11-11 |

## Summary

1 data source(s) in the workbook; 1 with an Athena component (1 embedded, 0 published).

## "Page split" (embedded)

- **Shape:** Relationship model: 2 logical tables (with joins inside) -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Used by worksheets:** Sheet 1, Sheet 1 (2), Sheet 3, Sheet 7, Top users, Top users (2), user report
- **Structure:**

```
Logical table "Sheet1"
  - Google Drive Excel "Revenue March 2024" table Sheet1$ (as "Sheet1")
Logical table "Custom SQL Query"
  - LEFT JOIN on [Page Views].[plan_id] = [RCFC Lookup].[Code]
    - LEFT JOIN on [Page Views].[department_code] = [Job Function].[Code]
      - Athena Custom SQL "Page Views" -> Page split.sql
      - Google Drive Excel "Job Function" table Sheet1$ (as "Job Function")
    - Google Drive Excel "RCFC codes" table Sheet1$ (as "RCFC Lookup")
```

- **Relationships:**
  - "Custom SQL Query" ↔ "Sheet1" on `[company_sfdc_id] = [Company_sfdc_id]`
- **Athena tables read:** `fact_external_db.omniture_event_fact`, `pib_event_data.pib_product_metrics`, `fact_external_db.pib_membership_fact`, `reference_external_db.pib_product_master`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_contract_dimension`, `fact_external_db.pib_account_hierarchy_fact`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_territory_dimension`, `sandbox_mk.geo_region_rollup`, `reference_external_db.pib_product_dimension`
- **SQL files:** [Page split.sql](Page%20split.sql)
