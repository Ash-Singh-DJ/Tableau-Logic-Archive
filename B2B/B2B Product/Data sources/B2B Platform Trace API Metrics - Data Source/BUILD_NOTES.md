# B2B Platform Trace API Metrics - Data Source

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Product / Data sources |
| Owner | Thomas Russell |
| Created | 2025-08-26 |
| Last updated | 2026-07-29 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/123476377 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Relationship model: 3 logical tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Structure:**

```
Logical table "URN Mapping for Tableau"
  - Google Drive Excel "Platform  Trace - resourceurn mapping table" table URN Mapping for Tableau$ (as "URN Mapping for Tableau")
Logical table "Account Info"
  - Athena Custom SQL "Custom SQL Query1" -> Custom SQL Query1.sql
Logical table "PTM Data"
  - Athena Custom SQL "Custom SQL Query" -> Custom SQL Query.sql
```

- **Relationships:**
  - "PTM Data" ↔ "URN Mapping for Tableau" on `[transaction_resource_urn] = [data_transaction_resourceurn]`
  - "PTM Data" ↔ "Account Info" on `[client_account_id] = [cibs_billing_account_id]`
- **Athena tables read:** `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_territory_dimension`, `sandbox_mk.geo_region_rollup`, `dimension_external_db.pib_user_dimension`, `pib_event_data.pib_platform_trace`, `reference_external_db.date_dimension`, `pib_event_data.pib_platform_trace_private_user`, `dimension_external_db.pib_membership_dimension`
- **SQL files:** [Custom SQL Query1.sql](Custom%20SQL%20Query1.sql), [Custom SQL Query.sql](Custom%20SQL%20Query.sql)

## Connected workbooks

_No connected workbooks found._
