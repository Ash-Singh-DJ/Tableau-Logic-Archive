# B2B AI_Gen AI Case

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Pricing / ARCHIVE |
| Owner | Maria Peco |
| Created | 2025-08-28 |
| Last updated | 2026-07-28 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/3235320 |
| Archived | 2026-11-11 |

## Summary

1 data source(s) in the workbook; 1 with an Athena component (0 embedded, 1 published).

## "Commercial Policy Cases" (published data source)

- **Published source:** "Commercial Policy Cases" in `B2B / B2B Pricing / Datasources`, owner Maria Peco; [archived here](../../Datasources/Commercial%20Policy%20Cases). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Gen AI Cases
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Commercial Policy Cases.sql
```
- **Athena tables read:** `dimension_external_db.pib_customer_service_case_dimension`, `dimension_external_db.pib_opportunity_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_user_dimension`, `dimension_external_db.pib_product_services_dimension`, `fact_external_db.pib_account_hierarchy_fact`, `dimension_external_db.pib_company_dimension`, `reference_external_db.date_dimension`
- **SQL files:** [Commercial Policy Cases.sql](Commercial%20Policy%20Cases.sql)
