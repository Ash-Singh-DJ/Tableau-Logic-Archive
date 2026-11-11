# B2B Screening & Monitoring Customers Report

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Product / R&C / Datasources |
| Owner | Maria Peco |
| Created | 2025-07-24 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/154241766 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / abc_matrix)
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Custom SQL Query.sql
```
- **Athena tables read:** `google_sheets_db.rc_batch_screening_cdp_data_unpivot`
- **SQL files:** [Custom SQL Query.sql](Custom%20SQL%20Query.sql)

## Connected workbooks

- [B2B Screening & Monitoring Customer Report](../../B2B%20Screening%20%26%20Monitoring%20Customer%20Report) [B2B / B2B Product / R&C]
