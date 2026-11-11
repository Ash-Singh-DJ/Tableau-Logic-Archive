# B2B R&C Financial Crime Migration Dashboard

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Product / R&C |
| Owner | Maria Peco |
| Created | 2025-05-27 |
| Last updated | 2025-08-27 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/2797779 |
| Archived | 2026-11-11 |

## Summary

1 data source(s) in the workbook; 1 with an Athena component (0 embedded, 1 published).

## "R&C Financial Crime Migration - Membership" (published data source)

- **Published source:** "B2B R&C Financial Crime Migration - Membership" in `B2B / B2B Product / R&C / Datasources`, owner Maria Peco; [archived here](../Datasources/B2B%20R%26C%20Financial%20Crime%20Migration%20-%20Membership). The SQL below is copied from it.
- **Shape:** Join of 4 tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Used by worksheets:** cht_BA_Sum(AME), cht_BA_Sum(APC), cht_BA_Sum(All), cht_BA_Sum(EMA), cht_Neutral_Sum(AME), cht_Neutral_Sum(APC), cht_Neutral_Sum(All), cht_Neutral_Sum(EMA), wks_BA by Q, wks_BA_Sum(AME), wks_BA_Sum(APC), wks_BA_Sum(All), wks_BA_Sum(EMA), wks_Neutral_Sum(AME), wks_Neutral_Sum(APC), wks_Neutral_Sum(All), wks_Neutral_Sum(EMA), wks_Renew, wks_Renew (BA), wks_billing accounts, wks_membership, wks_user by Q
- **Structure:**

```
- LEFT JOIN on [Custom SQL Query].[rcfc_access_code2] = [New Code1].[New_Code]
  - LEFT JOIN on [Custom SQL Query].[billing_account_id] = [Cohort].[Billing_ID]
    - LEFT JOIN on [Custom SQL Query].[rcfc_access_code] = [New Code].[New_Code]
      - Athena Custom SQL "Custom SQL Query" -> R&C Financial Crime Migration - Membership.sql
      - Google Drive Excel "RCFC_Code for Migration.xlsx" table New Code$ (as "New Code")
    - Google Drive Excel "RCFC_Code for Migration.xlsx" table Cohort$ (as "Cohort")
  - Google Drive Excel "RCFC_Code for Migration.xlsx" table New Code$ (as "New Code1")
```
- **Athena tables read:** `dimension_external_db.pib_membership_history`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_user_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_territory_dimension`
- **SQL files:** [R&C Financial Crime Migration - Membership.sql](R%26C%20Financial%20Crime%20Migration%20-%20Membership.sql)
