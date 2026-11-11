# B2B Factiva Usage by Content Source and Account

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Product / Factiva / Factiva Usage by Source |
| Owner | Maria Peco |
| Created | 2025-07-29 |
| Last updated | 2025-09-02 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/3093316 |
| Archived | 2026-11-11 |

## Summary

2 data source(s) in the workbook; 2 with an Athena component (0 embedded, 2 published).

## "Translated Source" (published data source)

- **Published source:** "B2B Factiva Usage by Content Source and Account - Translated Source" in `B2B / B2B Product / Factiva / Datasources`, owner Maria Peco; [archived here](../../Datasources/B2B%20Factiva%20Usage%20by%20Content...d%20Account%20-%20Translated%20Source). The SQL below is copied from it.
- **Shape:** Join of 4 tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Used by worksheets:** Sheet 18
- **Structure:**

```
- LEFT JOIN on [Main Usage].[Source_code] = [Source lookup].[Source Code]
  - LEFT JOIN on [Main Usage].[pib_member_id] = [Cluster Groups].[eid]
    - LEFT JOIN on [Main Usage].[Source_code] = [Sources].[SourceCode]
      - Athena Custom SQL "Main Usage" -> Translated Source - Main Usage.sql
      - Athena Custom SQL "Sources" -> Translated Source - Sources.sql
    - Athena Custom SQL "Cluster Groups" -> Translated Source - Cluster Groups.sql
  - Google Drive Excel "Translated Sources" table Sheet1$ (as "Source lookup")
```
- **Athena tables read:** `fact_external_db.omniture_event_fact`, `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `reference_external_db.pib_product_dimension`, `dimension_external_db.pib_territory_dimension`, `reference_external_db.country_reference`, `sandbox_mk.factiva_content_source_current`, `sandbox_mk.factiva_content_source_group_current`, `sandbox_mk.full_roo_table`, `sandbox_mk.factiva_user_seg_12mo`
- **SQL files:** [Translated Source - Main Usage.sql](Translated%20Source%20-%20Main%20Usage.sql), [Translated Source - Sources.sql](Translated%20Source%20-%20Sources.sql), [Translated Source - Cluster Groups.sql](Translated%20Source%20-%20Cluster%20Groups.sql)

## "omnit_user_source_usage+ (dimension_external)" (published data source)

- **Published source:** "B2B  Factiva Usage by Content Source and Account - Data Source" in `B2B / B2B Product / Factiva / Datasources`, owner James Thomson; [archived here](../../Datasources/B2B%20Factiva%20Usage%20by%20Content...rce%20and%20Account%20-%20Data%20Source). The SQL below is copied from it.
- **Shape:** Join of 3 tables
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / sandbox_mk)
- **Used by worksheets:** Account Usage, BO - Billing Account IDs, BO - Company Names, BO - Sources, BO - User IDs, Content Usage by Language, DJ vs Non DJ, Last Updated, Pivot, Reset, Sheet 10, Sheet 16, Sheet 17, Sheet 9, Top 10 DJ Sources, Top 10 Source Countries, Top 10 Sources
- **Structure:**

```
- LEFT JOIN on [omnit_user_source_usage].[pib_member_id] = [User Seg].[eid]
  - INNER JOIN on [omnit_user_source_usage].[Source_code] = [SourceInfo].[SourceCode]
    - Athena Custom SQL "omnit_user_source_usage" -> omnit_user_source_usage+ (dimension_external) - omnit_user_source_usage.sql
    - Athena Custom SQL "SourceInfo" -> omnit_user_source_usage+ (dimension_external) - SourceInfo.sql
  - Athena Custom SQL "User Seg" -> omnit_user_source_usage+ (dimension_external) - User Seg.sql
```
- **Athena tables read:** `dimension_external_db.pib_membership_dimension`, `fact_external_db.omniture_event_fact`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `reference_external_db.pib_product_dimension`, `dimension_external_db.pib_territory_dimension`, `reference_external_db.country_reference`, `sandbox_mk.factiva_content_source_current`, `sandbox_mk.factiva_content_source_group_current`, `sandbox_mk.full_roo_table`, `sandbox_mk.factiva_user_seg_12mo`
- **SQL files:** [omnit_user_source_usage+ (dimension_external) - omnit_user_source_usage.sql](omnit_user_source_usage%2B%20%28dimension_external%29%20-%20omnit_user_source_usage.sql), [omnit_user_source_usage+ (dimension_external) - SourceInfo.sql](omnit_user_source_usage%2B%20%28dimension_external%29%20-%20SourceInfo.sql), [omnit_user_source_usage+ (dimension_external) - User Seg.sql](omnit_user_source_usage%2B%20%28dimension_external%29%20-%20User%20Seg.sql)
