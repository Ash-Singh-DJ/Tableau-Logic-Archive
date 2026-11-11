# B2B Deutsche Bank - CF Top Sources

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Sales / GAT / Datasources |
| Owner | Shirley Chu |
| Created | 2025-09-29 |
| Last updated | 2026-09-05 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/101199378 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Join of 2 tables
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / sandbox_mk)
- **Structure:**

```
- INNER JOIN on [omnit_user_source_usage].[Source_code] = [SourceInfo].[SourceCode]
  - Athena Custom SQL "omnit_user_source_usage" -> omnit_user_source_usage.sql
  - Athena Custom SQL "SourceInfo" -> SourceInfo.sql
```
- **Athena tables read:** `fact_external_db.omniture_event_fact`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `reference_external_db.pib_product_dimension`, `dimension_external_db.pib_territory_dimension`, `reference_external_db.country_reference`, `sandbox_mk.factiva_content_source_current`, `sandbox_mk.factiva_content_source_group_current`, `sandbox_mk.full_roo_table`
- **SQL files:** [omnit_user_source_usage.sql](omnit_user_source_usage.sql), [SourceInfo.sql](SourceInfo.sql)

## Connected workbooks

_No connected workbooks found._
