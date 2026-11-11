# B2B R&C Value Index Dashboard 08172022

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Content Licensing- PAL |
| Owner | Steve Bishop |
| Created | 2025-07-27 |
| Last updated | 2025-08-21 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/3083911 |
| Archived | 2026-11-11 |

## Summary

2 data source(s) in the workbook; 1 with an Athena component (0 embedded, 1 published).
Other data sources: "Strategic Value Table (R&C Value Index Countries and Industries)" (published).

## "R&C Value Index (dimension_external_db)" (published data source)

- **Published source:** "B2B R&C Value Index (dimension_external_db)" in `B2B / B2B Content Licensing- PAL / Datasources`, owner Steve Bishop; [archived here](../Datasources/B2B%20R%26C%20Value%20Index%20%28dimension_external_db%29). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Raw Data Sheet, Value Distribution - Source Counts, Value List
- **Structure:**

```
- Athena Custom SQL "R&C Value Index" -> R&C Value Index (dimension_external_db).sql
```
- **Athena tables read:** `sandbox_mk.rnc_value_index`, `sandbox_mk.factiva_content_source_current`
- **SQL files:** [R&C Value Index (dimension_external_db).sql](R%26C%20Value%20Index%20%28dimension_external_db%29.sql)
