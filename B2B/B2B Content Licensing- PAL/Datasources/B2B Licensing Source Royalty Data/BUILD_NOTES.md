# B2B Licensing Source Royalty Data

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Content Licensing- PAL / Datasources |
| Owner | Maria Peco |
| Created | 2025-07-28 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/124729965 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Structure:**

```
- Athena Custom SQL "Source Royalty Data" -> Source Royalty Data.sql
```
- **Athena tables read:** `dimension_external_db.royalty_monthly_management_report`
- **SQL files:** [Source Royalty Data.sql](Source%20Royalty%20Data.sql)

## Connected workbooks

- B2B Licensing Dashboard [B2B / B2B Content Licensing- PAL]
