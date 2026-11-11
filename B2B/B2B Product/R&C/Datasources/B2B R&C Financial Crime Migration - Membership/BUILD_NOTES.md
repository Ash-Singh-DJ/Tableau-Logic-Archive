# B2B R&C Financial Crime Migration - Membership

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Product / R&C / Datasources |
| Owner | Maria Peco |
| Created | 2025-08-27 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/94784562 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Join of 4 tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Structure:**

```
- LEFT JOIN on [Custom SQL Query].[rcfc_access_code2] = [New Code1].[New_Code]
  - LEFT JOIN on [Custom SQL Query].[billing_account_id] = [Cohort].[Billing_ID]
    - LEFT JOIN on [Custom SQL Query].[rcfc_access_code] = [New Code].[New_Code]
      - Athena Custom SQL "Custom SQL Query" -> Custom SQL Query.sql
      - Google Drive Excel "RCFC_Code for Migration.xlsx" table New Code$ (as "New Code")
    - Google Drive Excel "RCFC_Code for Migration.xlsx" table Cohort$ (as "Cohort")
  - Google Drive Excel "RCFC_Code for Migration.xlsx" table New Code$ (as "New Code1")
```
- **Athena tables read:** `dimension_external_db.pib_membership_history`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_user_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_territory_dimension`
- **SQL files:** [Custom SQL Query.sql](Custom%20SQL%20Query.sql)

## Connected workbooks

- [B2B R&C Financial Crime Migration Dashboard](../../B2B%20R%26C%20Financial%20Crime%20Migration%20Dashboard) [B2B / B2B Product / R&C]
