# B2B Factiva Value Index Cost Prediction

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Content Licensing- PAL / Datasources |
| Owner | Porfirio Hernandez |
| Created | 2025-07-29 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/90104649 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Join of 7 tables -- Athena + Text/CSV file
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / sandbox_mk); Text/CSV file
- **Structure:**

```
- LEFT JOIN on [Custom SQL Query].[source_code] = [vi_data_all_cols.csv].[Source Code] AND [Custom SQL Query].[period] = [vi_data_all_cols.csv].[Period]
  - LEFT JOIN on [Custom SQL Query].[period] = [vi_usage_data.csv].[period] AND [Custom SQL Query].[source_code] = [vi_usage_data.csv].[source_code]
    - LEFT JOIN on [Custom SQL Query].[source_code] = [sv_prestige_active].[source_code]
      - LEFT JOIN on [Custom SQL Query].[source_code] = [sv_exclusives_active].[source_code]
        - LEFT JOIN on [source_db_clean].[sourcecode] = [source_roo_custom].[sourcecode]
          - LEFT JOIN on [Custom SQL Query].[source_code] = [source_db_clean].[sourcecode]
            - Athena Custom SQL "Custom SQL Query" -> Custom SQL Query.sql
            - Athena table sandbox_mk.source_db_clean (as "source_db_clean")
          - Athena Custom SQL "source_roo_custom" -> source_roo_custom.sql
        - Athena Custom SQL "sv_exclusives_active" -> sv_exclusives_active.sql
      - Athena Custom SQL "sv_prestige_active" -> sv_prestige_active.sql
    - Text/CSV file "vi_usage_data" table vi_usage_data#csv (as "vi_usage_data.csv")
  - Text/CSV file "vi_data_all_cols" table vi_data_all_cols#csv (as "vi_data_all_cols.csv")
```
- **Athena tables read:** `dimension_external_db.royalty_monthly_guaranteed_minimum_report`, `dimension_external_db.royalty_monthly_management_report`, `sandbox_mk.factiva_content_value_index_ui`, `sandbox_mk.source_db_clean`, `sandbox_mk.source_group`, `sandbox_mk.source_roo`, `sandbox_mk.sv_exclusives`, `dimension_external_db.cdb_source_docs_current`, `sandbox_mk.sv_prestige`
- **SQL files:** [Custom SQL Query.sql](Custom%20SQL%20Query.sql), [source_roo_custom.sql](source_roo_custom.sql), [sv_exclusives_active.sql](sv_exclusives_active.sql), [sv_prestige_active.sql](sv_prestige_active.sql)

## Connected workbooks

_No connected workbooks found._
