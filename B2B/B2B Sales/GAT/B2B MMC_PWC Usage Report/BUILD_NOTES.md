# B2B MMC_PWC Usage Report

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Sales / GAT |
| Owner | Maria Peco |
| Created | 2025-09-08 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/3286614 |
| Archived | 2026-11-11 |

## Summary

1 data source(s) in the workbook; 1 with an Athena component (1 embedded, 0 published).

## "Active_Users_MMC" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Consumer_User, Overall_User (chart), PIB_User
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Active_Users_MMC.sql
```
- **Athena tables read:** `fact_external_db.omniture_event_fact`, `pib_event_data.pib_product_metrics`, `reference_external_db.date_dimension`, `dimension_external_db.pib_membership_dimension`, `subscription_external_db.identity_lookup`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_user_dimension`, `dimension_external_db.pib_territory_dimension`, `reference_external_db.country_reference`
- **SQL files:** [Active_Users_MMC.sql](Active_Users_MMC.sql)
