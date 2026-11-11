# B2B DAU_WAU_MAU

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Sales / Sales Leadership & Operations / Datasources |
| Owner | James Thomson |
| Created | 2025-07-28 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/111977152 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Join of 3 tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Structure:**

```
- LEFT JOIN on [Custom SQL Query].[year_month_day] = [FYQ Lookup].[Day]
  - LEFT JOIN on [Custom SQL Query].[department_code] = [Job Function].[Code]
    - Athena Custom SQL "Custom SQL Query" -> Custom SQL Query.sql
    - Google Drive Excel "Job Function2" table Sheet1$ (as "Job Function")
  - Google Drive Excel "FYQ lookup" table Sheet1$ (as "FYQ Lookup")
```
- **Athena tables read:** `reference_external_db.date_dimension`, `dimension_external_db.pib_membership_dimension`, `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `fact_external_db.omniture_event_fact`, `google_sheets_db.rcfc_access_code`, `fact_external_db.omniture_event_fact_hourly`, `subscription_external_db.identity_lookup`, `pib_event_data.pib_platform_trace`
- **SQL files:** [Custom SQL Query.sql](Custom%20SQL%20Query.sql)

## Connected workbooks

- [B2B User Engagement - Weekly and Daily to Monthly Active User Ratios](../../../../B2B%20Product/B2B%20User%20Engagement%20-%20Weekly...to%20Monthly%20Active%20User%20Ratios) [B2B / B2B Product]
