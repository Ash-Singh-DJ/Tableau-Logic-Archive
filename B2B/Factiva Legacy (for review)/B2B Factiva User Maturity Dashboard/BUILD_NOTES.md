# B2B Factiva User Maturity Dashboard

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / Factiva Legacy (for review) |
| Owner | Maria Peco |
| Created | 2025-07-28 |
| Last updated | 2025-09-12 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/3087090 |
| Archived | 2026-11-11 |

## Summary

1 data source(s) in the workbook; 1 with an Athena component (0 embedded, 1 published).

## "Maturity Factiva Users" (published data source)

- **Published source:** "B2B Factiva User Maturity Dashboard - Users" in `B2B / B2B Product / Factiva / Datasources`, owner Maria Peco; [archived here](../../B2B%20Product/Factiva/Datasources/B2B%20Factiva%20User%20Maturity%20Dashboard%20-%20Users). The SQL below is copied from it.
- **Shape:** Join of 2 tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Used by worksheets:** Chart %, Chart Num, Chart Num2, Maturity %, Numbers, Numbers (2), Numbers Reg, Sheet 1, Sheet 10, Sheet 2, Sheet 9, User Maturity Chart, User Maturity Chart (2)
- **Structure:**

```
- LEFT JOIN on [Custom SQL Query].[department_code] = [Sheet1].[Code]
  - Athena Custom SQL "Custom SQL Query" -> Maturity Factiva Users.sql
  - Google Drive Excel "Job Function" table Sheet1$ (as "Sheet1")
```
- **Athena tables read:** `dimension_external_db.pib_membership_dimension`, `fact_external_db.omniture_event_fact`, `pib_event_data.pib_product_metrics`, `google_sheets_db.saml_master_list_b2b_current`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [Maturity Factiva Users.sql](Maturity%20Factiva%20Users.sql)
