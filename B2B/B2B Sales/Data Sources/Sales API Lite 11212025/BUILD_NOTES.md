# Sales API Lite 11212025

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Sales / Data Sources |
| Owner | Steve Bishop |
| Created | 2025-11-21 |
| Last updated | 2026-04-07 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/112074013 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Relationship model: 2 logical tables
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Structure:**

```
Logical table "API Usage by Account"
  - Athena Custom SQL "Custom SQL Query" -> Custom SQL Query.sql
Logical table "TM1"
  - Athena Custom SQL "TM1 Data" -> TM1 Data.sql
```

- **Relationships:**
  - "API Usage by Account" ↔ "TM1" on `[company_sfdc_id] = [company_sfdc_id (TM1 Data)]`
- **Athena tables read:** `pib_event_data.pib_platform_trace`, `pib_event_data.pib_platform_trace_private_user`, `pib_event_data.pib_legacy_api`, `google_sheets_db.rc_legacy_api_usage_unpivot`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_territory_dimension`, `dimension_external_db.pib_user_dimension`, `sandbox_mk.geo_region_rollup`, `dimension_external_db.pib_membership_dimension`, `reference_external_db.country_reference`, `fact_external_db.tm1_fact`, `reference_external_db.pib_account_mapping`, `reference_external_db.pib_product_master`, `reference_external_db.date_dimension`
- **SQL files:** [Custom SQL Query.sql](Custom%20SQL%20Query.sql), [TM1 Data.sql](TM1%20Data.sql)

## Connected workbooks

_No connected workbooks found._
