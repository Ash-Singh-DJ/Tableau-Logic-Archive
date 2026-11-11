# B2B Factiva Emails: Deliveries and Opens - Aggregate

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Product / Factiva / Datasources |
| Owner | Maria Peco |
| Created | 2025-09-10 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/154245410 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Join of 2 tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Structure:**

```
- LEFT JOIN on [Custom SQL Query].[department_code] = [Job Function Lookup].[Code]
  - Athena Custom SQL "Custom SQL Query" -> Custom SQL Query.sql
  - Google Drive Excel "Job Function2" table Sheet1$ (as "Job Function Lookup")
```
- **Athena tables read:** `dimension_external_db.pib_membership_dimension`, `pib.email_open_rates`, `dimension_external_db.pib_alerts`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_territory_dimension`, `dimension_external_db.pib_user_dimension`, `reference_external_db.country_reference`
- **SQL files:** [Custom SQL Query.sql](Custom%20SQL%20Query.sql)

## Connected workbooks

- [B2B Factiva Emails: Deliveries and Opens](../../B2B%20Factiva%20Emails-%20Deliveries%20and%20Opens) [B2B / B2B Product / Factiva]
- Email Deliveries Test  [B2B / B2B Testing]
- NL Test [B2B / B2B Testing]
