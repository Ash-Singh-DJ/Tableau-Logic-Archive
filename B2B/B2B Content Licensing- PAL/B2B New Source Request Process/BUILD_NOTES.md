# B2B New Source Request Process

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Content Licensing- PAL |
| Owner | Maria Peco |
| Created | 2025-07-07 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/2984451 |
| Archived | 2026-11-11 |

## Summary

1 data source(s) in the workbook; 1 with an Athena component (1 embedded, 0 published).

## "Source request dash test" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** By Revenue, Industry, Map, Requests by Status, Sheet 10, Sheet 11, Table, Table2, Time Series, Top Countries, Total Requests
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Source request dash test.sql
```
- **Athena tables read:** `fact_external_db.tm1_fact`, `reference_external_db.pib_account_mapping`, `reference_external_db.pib_product_master`, `reference_external_db.date_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_contract_dimension`, `fact_external_db.pib_account_hierarchy_fact`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_corporate_dimension`, `dimension_external_db.pib_customer_service_case_dimension`, `dimension_external_db.pib_membership_dimension`
- **SQL files:** [Source request dash test.sql](Source%20request%20dash%20test.sql)
