# B2B Factiva Digest Sign-Up Rate Comparison

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / Factiva Legacy (for review) |
| Owner | Maria Peco |
| Created | 2025-07-28 |
| Last updated | 2025-09-12 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/3087195 |
| Archived | 2026-11-11 |

## Summary

1 data source(s) in the workbook; 1 with an Athena component (0 embedded, 1 published).

## "Digest Sign up rates" (published data source)

- **Published source:** "B2B Factiva Digest Sign-Up Rate Comparison - Sign up rates" in `B2B / B2B Product / Factiva / Datasources`, owner Maria Peco; [archived here](../../B2B%20Product/Factiva/Datasources/B2B%20Factiva%20Digest%20Sign-Up%20Rate%20Comparison%20-%20Sign%20up%20rates). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Data 1, Data 2, Total 1, Total 2
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Digest Sign up rates.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `reference_external_db.date_dimension`
- **SQL files:** [Digest Sign up rates.sql](Digest%20Sign%20up%20rates.sql)
