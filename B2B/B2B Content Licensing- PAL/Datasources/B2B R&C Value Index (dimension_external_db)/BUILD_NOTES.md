# B2B R&C Value Index (dimension_external_db)

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Content Licensing- PAL / Datasources |
| Owner | Steve Bishop |
| Created | 2025-07-29 |
| Last updated | 2025-07-30 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/90108697 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Structure:**

```
- Athena Custom SQL "R&C Value Index" -> R&C Value Index.sql
```
- **Athena tables read:** `sandbox_mk.rnc_value_index`, `sandbox_mk.factiva_content_source_current`
- **SQL files:** [R&C Value Index.sql](R%26C%20Value%20Index.sql)

## Connected workbooks

- [B2B R&C Value Index Dashboard 08172022](../../B2B%20R%26C%20Value%20Index%20Dashboard%2008172022) [B2B / B2B Content Licensing- PAL]
