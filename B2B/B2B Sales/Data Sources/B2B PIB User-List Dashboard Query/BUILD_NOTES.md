# B2B PIB User-List Dashboard Query

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Sales / Data Sources |
| Owner | Maria Peco |
| Created | 2025-10-27 |
| Last updated | 2026-04-07 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/106787290 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Join of 4 tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / reference_external_db); Google Drive Excel
- **Structure:**

```
- LEFT JOIN on [User & Usage Information].[country_code] = [Country_Region_Table].[EDW_code]
  - LEFT JOIN on [User & Usage Information].[plan_id] = [pib_product_dimens].[access_code]
    - LEFT JOIN on [User & Usage Information].[billing_account_id] = [Billing Acct Information].[cibs_billing_account_id]
      - Athena Custom SQL "User & Usage Information" -> User & Usage Information.sql
      - Athena Custom SQL "Billing Acct Information" -> Billing Acct Information.sql
    - Athena table reference_external_db.pib_product_dimension (as "pib_product_dimens")
  - Google Drive Excel "Country_Region_Table" table Country_Region_Table$ (as "Country_Region_Table")
```
- **Athena tables read:** `fact_external_db.omniture_event_fact`, `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `subscription_external_db.identity_lookup`, `dimension_external_db.pib_billing_account_dimension`, `fact_external_db.pib_account_hierarchy_fact`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_corporate_dimension`, `dimension_external_db.pib_territory_dimension`, `dimension_external_db.pib_user_dimension`, `reference_external_db.pib_product_dimension`
- **SQL files:** [User & Usage Information.sql](User%20%26%20Usage%20Information.sql), [Billing Acct Information.sql](Billing%20Acct%20Information.sql)

## Connected workbooks

_No connected workbooks found._
