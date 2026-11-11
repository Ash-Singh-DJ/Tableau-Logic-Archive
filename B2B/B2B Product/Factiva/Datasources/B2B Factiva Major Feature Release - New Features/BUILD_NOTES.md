# B2B Factiva Major Feature Release - New Features

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Product / Factiva / Datasources |
| Owner | James Thomson |
| Created | 2025-07-29 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/164654089 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Join of 3 tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Structure:**

```
- LEFT JOIN on [Usage].[department_code] = [Job Function].[Code]
  - LEFT JOIN on [Usage].[EID] = [Cluster Name].[eid]
    - Athena Custom SQL "Usage" -> Usage.sql
    - Athena Custom SQL "Cluster Name" -> Cluster Name.sql
  - Google Drive Excel "Job Function2" table Sheet1$ (as "Job Function")
```
- **Athena tables read:** `dimension_external_db.pib_membership_dimension`, `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `sandbox_mk.factiva_user_seg_12mo`
- **SQL files:** [Usage.sql](Usage.sql), [Cluster Name.sql](Cluster%20Name.sql)

## Connected workbooks

- [B2B Factiva Major Feature Release Dashboard](../../B2B%20Factiva%20Major%20Feature%20Release%20Dashboard) [B2B / B2B Product / Factiva]
