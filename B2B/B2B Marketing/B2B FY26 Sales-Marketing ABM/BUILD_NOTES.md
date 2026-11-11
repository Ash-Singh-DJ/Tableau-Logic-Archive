# B2B FY26 Sales-Marketing ABM

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Marketing |
| Owner | Maria Peco |
| Created | 2025-12-03 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/3687609 |
| Archived | 2026-11-11 |

## Summary

1 data source(s) in the workbook; 1 with an Athena component (1 embedded, 0 published).

## "Custom SQL Query (sandbox_pecom)" (embedded)

- **Shape:** Relationship model: 4 logical tables
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / sandbox_pecom)
- **Used by worksheets:** Companies with event, Companies with sales, Company_drill_down, Count MKT, Count Sales, Cumulative Companies Sales, Cumulative Companies Touched, Event Drilldown, Glossary, MoM Open Opp Table ytd, MoM Open Opp chart ytd, Opportunities_overview Closed FY, Revenue_marketing, Revenue_non_touched, Revenue_overview, Sheet 19, YoY Open Opp Table, account_list_new, marketing_drilldown, marketing_lift_opps, number_companies, opportunities_drill, product_pivot
- **Structure:**

```
Logical table "date_dimension"
  - Athena Custom SQL "Custom SQL Query2" -> Custom SQL Query (sandbox_pecom) - Custom SQL Query2.sql
Logical table "product_mapping"
  - Athena Custom SQL "Custom SQL Query" -> Custom SQL Query (sandbox_pecom) - Custom SQL Query.sql
Logical table "marketing_data"
  - Athena table sandbox_pecom.marketing_data_abm (as "marketing_data_abm")
Logical table "sales_deliverable"
  - Athena table sandbox_pecom.abm_fy26_sales (as "abm_fy26_sales")
```

- **Relationships:**
  - "sales_deliverable" ↔ "date_dimension" on `[opp_created_date] = [full_date]`
  - "sales_deliverable" ↔ "product_mapping" on `[product] = [product_name]`
  - "sales_deliverable" ↔ "marketing_data" on `[company_sfdc_id] = [company_sfdc_id (marketing_data_abm)]`
- **Athena tables read:** `reference_external_db.date_dimension`, `sandbox_hvc.prod_master`, `sandbox_pecom.marketing_data_abm`, `sandbox_pecom.abm_fy26_sales`
- **SQL files:** [Custom SQL Query (sandbox_pecom) - Custom SQL Query2.sql](Custom%20SQL%20Query%20%28sandbox_pecom%29%20-%20Custom%20SQL%20Query2.sql), [Custom SQL Query (sandbox_pecom) - Custom SQL Query.sql](Custom%20SQL%20Query%20%28sandbox_pecom%29%20-%20Custom%20SQL%20Query.sql)
