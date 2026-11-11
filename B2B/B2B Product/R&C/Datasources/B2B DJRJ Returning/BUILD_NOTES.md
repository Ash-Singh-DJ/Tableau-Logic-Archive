# B2B DJRJ Returning

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Product / R&C / Datasources |
| Owner | Maria Peco |
| Created | 2025-08-28 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/98649933 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Join of 2 tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / abc_matrix); Google Drive Excel
- **Structure:**

```
- LEFT JOIN on [Custom SQL Query].[user_id] = [Account_Info].[User Id]
  - Athena Custom SQL "Custom SQL Query" -> Custom SQL Query.sql
  - Google Drive Excel "DJRJ Trials" table Sheet1$ (as "Account_Info")
```
- **Athena tables read:** `fact_external_db.omniture_event_fact_hourly`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_corporate_dimension`, `dimension_external_db.pib_territory_dimension`, `dimension_external_db.pib_user_dimension`
- **SQL files:** [Custom SQL Query.sql](Custom%20SQL%20Query.sql)

## Connected workbooks

_No connected workbooks found._
