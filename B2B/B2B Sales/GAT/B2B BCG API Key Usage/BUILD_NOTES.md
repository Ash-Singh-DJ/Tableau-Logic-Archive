# B2B BCG API Key Usage

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Sales / GAT |
| Owner | svc_dj tableaucdl_b2b |
| Created | 2026-09-22 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/5551251 |
| Archived | 2026-11-11 |

## Summary

1 data source(s) in the workbook; 1 with an Athena component (1 embedded, 0 published).

## "API Usage" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** API Usage by User ID, Transaction Trend by API
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> API Usage.sql
```
- **Athena tables read:** `pib_event_data.pib_platform_trace`, `pib_event_data.pib_platform_trace_private_user`, `pib_event_data.pib_legacy_api`, `google_sheets_db.rc_legacy_api_usage_unpivot`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_territory_dimension`, `dimension_external_db.pib_user_dimension`, `sandbox_mk.geo_region_rollup`, `dimension_external_db.pib_membership_dimension`, `reference_external_db.country_reference`
- **SQL files:** [API Usage.sql](API%20Usage.sql)
