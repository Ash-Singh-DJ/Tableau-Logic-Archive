# B2B Licensing Source Level Data

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Content Licensing- PAL / Datasources |
| Owner | Porfirio Hernandez |
| Created | 2025-07-29 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/138123613 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Structure:**

```
- Athena Custom SQL "Source Level Data" -> Source Level Data.sql
```
- **Athena tables read:** `fact_external_db.omniture_event_fact`, `dimension_external_db.pib_membership_dimension`, `reference_external_db.pib_product_dimension`, `pib_event_data.pib_product_metrics`, `dimension_external_db.cdb_source_docs_current`, `dimension_external_db.cdb_group_docs_current`, `dimension_external_db.cdb_region_type_code`, `dimension_external_db.royalty_monthly_management_report`, `sandbox_mk.factiva_content_value_index_ui`, `dimension_external_db.content_volumes`, `dimension_external_db.ip_rights_data_current`, `sandbox_mk.sources_used_for_rnc_all_time`, `sandbox_mk.rnc_value_index`
- **SQL files:** [Source Level Data.sql](Source%20Level%20Data.sql)

## Connected workbooks

- B2B Licensing Dashboard [B2B / B2B Content Licensing- PAL]
