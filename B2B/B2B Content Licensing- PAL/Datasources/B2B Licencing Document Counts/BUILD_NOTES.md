# B2B Licencing Document Counts

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Content Licensing- PAL / Datasources |
| Owner | Ashish Kumar |
| Created | 2025-07-28 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/138094640 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / sandbox_mk)
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Custom SQL Query.sql
```
- **Athena tables read:** `dimension_external_db.cdb_source_docs_current`, `dimension_external_db.ip_rights_data_current`, `dimension_external_db.content_volumes`
- **SQL files:** [Custom SQL Query.sql](Custom%20SQL%20Query.sql)

## Connected workbooks

- B2B Licensing Dashboard [B2B / B2B Content Licensing- PAL]
