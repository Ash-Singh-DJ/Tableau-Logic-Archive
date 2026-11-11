# B2B Factiva Usage by Content Source and Account - Translated Source

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Product / Factiva / Datasources |
| Owner | Maria Peco |
| Created | 2025-07-29 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/90042605 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Join of 4 tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Structure:**

```
- LEFT JOIN on [Main Usage].[Source_code] = [Source lookup].[Source Code]
  - LEFT JOIN on [Main Usage].[pib_member_id] = [Cluster Groups].[eid]
    - LEFT JOIN on [Main Usage].[Source_code] = [Sources].[SourceCode]
      - Athena Custom SQL "Main Usage" -> Main Usage.sql
      - Athena Custom SQL "Sources" -> Sources.sql
    - Athena Custom SQL "Cluster Groups" -> Cluster Groups.sql
  - Google Drive Excel "Translated Sources" table Sheet1$ (as "Source lookup")
```
- **Athena tables read:** `fact_external_db.omniture_event_fact`, `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `reference_external_db.pib_product_dimension`, `dimension_external_db.pib_territory_dimension`, `reference_external_db.country_reference`, `sandbox_mk.factiva_content_source_current`, `sandbox_mk.factiva_content_source_group_current`, `sandbox_mk.full_roo_table`, `sandbox_mk.factiva_user_seg_12mo`
- **SQL files:** [Main Usage.sql](Main%20Usage.sql), [Sources.sql](Sources.sql), [Cluster Groups.sql](Cluster%20Groups.sql)

## Connected workbooks

- [B2B Factiva Usage by Content Source and Account](../../Factiva%20Usage%20by%20Source/B2B%20Factiva%20Usage%20by%20Content%20Source%20and%20Account) [B2B / B2B Product / Factiva / Factiva Usage by Source]
- 9THE070400 source breakdown [B2B / B2B Testing]
