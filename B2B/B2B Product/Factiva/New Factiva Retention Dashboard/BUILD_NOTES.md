# New Factiva Retention Dashboard

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Product / Factiva |
| Owner | James Thomson |
| Created | 2026-01-07 |
| Last updated | 2026-01-07 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/3812580 |
| Archived | 2026-11-11 |

## Summary

1 data source(s) in the workbook; 1 with an Athena component (0 embedded, 1 published).

## "Factiva Weekly retention" (published data source)

- **Published source:** "Factiva Weekly retention" in `B2B / B2B Testing`, owner James Thomson; not archived separately: it sits outside the archive scope (B2B Testing). The SQL below is copied from it.
- **Shape:** Join of 4 tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / reference_external_db); Google Drive Excel
- **Used by worksheets:** Sheet 1, Sheet 5, Weekly Retention rate %, Weekly retention numbers, Weekly retention numbers (2)
- **Structure:**

```
- LEFT JOIN on [Custom SQL Query].[plan_id] = [Codes].[Code]
  - LEFT JOIN on [Custom SQL Query].[plan_id] = [pib_product_dimens].[access_code]
    - LEFT JOIN on [Custom SQL Query].[company_industry] = [Industry Mapping].[SFDC Industry]
      - Athena Custom SQL "Custom SQL Query" -> Factiva Weekly retention.sql
      - Google Drive Excel "Industry Mapping" table Sheet1$ (as "Industry Mapping")
    - Athena table reference_external_db.pib_product_dimension (as "pib_product_dimens")
  - Google Drive Excel "RCFC codes" table Codes$ (as "Codes")
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_corporate_dimension`, `dimension_external_db.pib_territory_dimension`, `dimension_external_db.pib_user_dimension`, `reference_external_db.pib_product_dimension`
- **SQL files:** [Factiva Weekly retention.sql](Factiva%20Weekly%20retention.sql)
