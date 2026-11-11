# B2B Licensing ip_contacts_data_current (sandbox_mk)

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Content Licensing- PAL / Datasources |
| Owner | Maria Peco |
| Created | 2025-07-28 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/108311816 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Standalone table
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / sandbox_mk)
- **Structure:**

```
- Athena table sandbox_mk.ip_contacts_data_current (as "ip_contacts_data_c")
```
- **Athena tables read:** `sandbox_mk.ip_contacts_data_current`
- **SQL files:** _none -- Athena is read as plain table(s), no Custom SQL_

## Connected workbooks

_No connected workbooks found._
