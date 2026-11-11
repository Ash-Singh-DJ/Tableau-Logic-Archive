# B2B  Factiva Compliance Model Dashboard

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Product / Factiva / Factiva 1P & User Segmentation |
| Owner | Steve Bishop |
| Created | 2025-07-28 |
| Last updated | 2025-09-02 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/3089305 |
| Archived | 2026-11-11 |

## Summary

1 data source(s) in the workbook; 1 with an Athena component (0 embedded, 1 published).

## "Custom SQL Query+ (dimension_external_db)" (published data source)

- **Published source:** "B2B Factiva Compliance Model Dashboard - Data Source" in `B2B / B2B Product / Factiva / Datasources`, owner Maria Peco; [archived here](../../Datasources/B2B%20Factiva%20Compliance%20Model%20Dashboard%20-%20Data%20Source). The SQL below is copied from it.
- **Shape:** Join of 2 tables
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Company Breakdown, Company List, User List
- **Structure:**

```
- LEFT JOIN on [Company Data].[company_sfdc_id] = [User + Model Data].[company_sfdc_id]
  - Athena Custom SQL "Company Data" -> Custom SQL Query+ (dimension_external_db) - Company Data.sql
  - Athena Custom SQL "User + Model Data" -> Custom SQL Query+ (dimension_external_db) - User + Model Data.sql
```
- **Athena tables read:** `fact_external_db.tm1_fact`, `reference_external_db.pib_product_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_corporate_dimension`, `dimension_external_db.pib_territory_dimension`, `dimension_external_db.pib_user_dimension`, `dimension_external_db.pib_membership_dimension`, `sandbox_mk.compliance_model_results`
- **SQL files:** [Custom SQL Query+ (dimension_external_db) - Company Data.sql](Custom%20SQL%20Query%2B%20%28dimension_external_db%29%20-%20Company%20Data.sql), [Custom SQL Query+ (dimension_external_db) - User + Model Data.sql](Custom%20SQL%20Query%2B%20%28dimension_external_db%29%20-%20User%20%2B%20Model%20Data.sql)
