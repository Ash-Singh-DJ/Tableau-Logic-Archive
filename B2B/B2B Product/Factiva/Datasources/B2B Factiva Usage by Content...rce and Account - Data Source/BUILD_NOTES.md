# B2B  Factiva Usage by Content Source and Account - Data Source

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Product / Factiva / Datasources |
| Owner | James Thomson |
| Created | 2025-07-29 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/181113026 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Join of 3 tables
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / sandbox_mk)
- **Structure:**

```
- LEFT JOIN on [omnit_user_source_usage].[pib_member_id] = [User Seg].[eid]
  - INNER JOIN on [omnit_user_source_usage].[Source_code] = [SourceInfo].[SourceCode]
    - Athena Custom SQL "omnit_user_source_usage" -> omnit_user_source_usage.sql
    - Athena Custom SQL "SourceInfo" -> SourceInfo.sql
  - Athena Custom SQL "User Seg" -> User Seg.sql
```
- **Athena tables read:** `dimension_external_db.pib_membership_dimension`, `fact_external_db.omniture_event_fact`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `reference_external_db.pib_product_dimension`, `dimension_external_db.pib_territory_dimension`, `reference_external_db.country_reference`, `sandbox_mk.factiva_content_source_current`, `sandbox_mk.factiva_content_source_group_current`, `sandbox_mk.full_roo_table`, `sandbox_mk.factiva_user_seg_12mo`
- **SQL files:** [omnit_user_source_usage.sql](omnit_user_source_usage.sql), [SourceInfo.sql](SourceInfo.sql), [User Seg.sql](User%20Seg.sql)

## Connected workbooks

- [B2B Factiva Usage by Content Source and Account](../../Factiva%20Usage%20by%20Source/B2B%20Factiva%20Usage%20by%20Content%20Source%20and%20Account) [B2B / B2B Product / Factiva / Factiva Usage by Source]
- 9THE070400 source breakdown [B2B / B2B Testing]
