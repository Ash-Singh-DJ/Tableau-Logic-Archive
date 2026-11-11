# B2B Screening & Monitoring Customer Report

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Product / R&C |
| Owner | Maria Peco |
| Created | 2025-07-24 |
| Last updated | 2025-08-21 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/3073025 |
| Archived | 2026-11-11 |

## Summary

2 data source(s) in the workbook; 2 with an Athena component (0 embedded, 2 published).

## "Batch_Screening" (published data source)

- **Published source:** "B2B Screening & Monitoring Customers Report" in `B2B / B2B Product / R&C / Datasources`, owner Maria Peco; [archived here](../Datasources/B2B%20Screening%20%26%20Monitoring%20Customers%20Report). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / abc_matrix)
- **Used by worksheets:** Combine
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Batch_Screening.sql
```
- **Athena tables read:** `google_sheets_db.rc_batch_screening_cdp_data_unpivot`
- **SQL files:** [Batch_Screening.sql](Batch_Screening.sql)

## "RC Revenue" (published data source)

- **Published source:** "B2B Screening & Monitoring RC Revenue" in `B2B / B2B Product / R&C / Datasources`, owner Maria Peco; [archived here](../Datasources/B2B%20Screening%20%26%20Monitoring%20RC%20Revenue). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / abc_matrix)
- **Used by worksheets:** Combine
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> RC Revenue.sql
```
- **Athena tables read:** `reference_external_db.pib_account_mapping`, `fact_external_db.tm1_fact`, `reference_external_db.pib_product_master`, `reference_external_db.date_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_contract_dimension`, `fact_external_db.pib_account_hierarchy_fact`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_corporate_dimension`, `dimension_external_db.pib_product_service_attributes`, `sandbox_mk.geo_region_rollup`
- **SQL files:** [RC Revenue.sql](RC%20Revenue.sql)
