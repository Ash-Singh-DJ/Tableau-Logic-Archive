# B2B Company-level Usage between Classic and New Factiva

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / Factiva Legacy (for review) |
| Owner | Maria Peco |
| Created | 2025-07-28 |
| Last updated | 2025-09-12 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/3086949 |
| Archived | 2026-11-11 |

## Summary

2 data source(s) in the workbook; 2 with an Athena component (0 embedded, 2 published).

## "Usage" (published data source)

- **Published source:** "B2B Company-level Usage between Classic and New Factiva - Usage" in `B2B / B2B Product / Factiva / Datasources`, owner James Thomson; [archived here](../../B2B%20Product/Factiva/Datasources/B2B%20Company-level%20Usage%20betw...assic%20and%20New%20Factiva%20-%20Usage). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / abc_matrix)
- **Used by worksheets:** Usage
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Usage.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `fact_external_db.omniture_event_fact`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_territory_dimension`, `dimension_external_db.pib_user_dimension`
- **SQL files:** [Usage.sql](Usage.sql)

## "B2B Company-level Usage Preference" (published data source)

- **Published source:** "B2B Company-level Usage between Classic and New Factiva - Usage Preference" in `B2B / B2B Product / Factiva / Datasources`, owner James Thomson; [archived here](../../B2B%20Product/Factiva/Datasources/B2B%20Company-level%20Usage%20betw...ew%20Factiva%20-%20Usage%20Preference). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / abc_matrix)
- **Used by worksheets:** Preference wb
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> B2B Company-level Usage Preference.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_territory_dimension`, `dimension_external_db.pib_user_dimension`
- **SQL files:** [B2B Company-level Usage Preference.sql](B2B%20Company-level%20Usage%20Preference.sql)
