# B2B Classic Factiva Usage Dashboard - Usage Athena

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Product / Factiva / Datasources |
| Owner | James Thomson |
| Created | 2025-09-14 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/98304944 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Join of 3 tables -- Athena + BigQuery
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); BigQuery
- **Structure:**

```
- LEFT JOIN on [usage_main].[pib_member_id] = [Cluster data].[eid]
  - INNER JOIN on [usage_main].[year_cal_week] = [fiscal_week lookup].[cal_week]
    - Athena Custom SQL "usage_main" -> usage_main.sql
    - Athena Custom SQL "fiscal_week lookup" -> fiscal_week lookup.sql
  - BigQuery Custom SQL "Cluster data"
```
- **Athena tables read:** `fact_external_db.omniture_event_fact`, `pib_event_data.pib_product_metrics`, `reference_external_db.pib_product_master`, `google_sheets_db.saml_master_list_b2b_current`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_territory_dimension`, `reference_external_db.country_reference`, `reference_external_db.date_dimension`
- **Non-Athena Custom SQL (not archived):** "Cluster data" (BigQuery)
- **SQL files:** [usage_main.sql](usage_main.sql), [fiscal_week lookup.sql](fiscal_week%20lookup.sql)

## Connected workbooks

- [B2B Classic Factiva Usage Dashboard](../../B2B%20Classic%20Factiva%20Usage%20Dashboard) [B2B / B2B Product / Factiva]
