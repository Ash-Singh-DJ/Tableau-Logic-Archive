# B2B Single Day Users on Factiva - Last Page 2

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Product / Factiva / Datasources |
| Owner | Maria Peco |
| Created | 2025-07-28 |
| Last updated | 2026-05-05 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/101118970 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Join of 3 tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Structure:**

```
- LEFT JOIN on [Custom SQL Query].[department_code] = [Job Function].[Code]
  - LEFT JOIN on [Custom SQL Query].[pib_member_id] = [Cluster Group].[eid]
    - Athena Custom SQL "Custom SQL Query" -> Custom SQL Query.sql
    - Athena Custom SQL "Cluster Group" -> Cluster Group.sql
  - Google Drive Excel "Job Function" table Sheet1$ (as "Job Function")
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `fact_external_db.omniture_event_fact`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `sandbox_mk.factiva_user_seg_12mo`
- **SQL files:** [Custom SQL Query.sql](Custom%20SQL%20Query.sql), [Cluster Group.sql](Cluster%20Group.sql)

## Connected workbooks

- [Single Day Users](../../Single%20Day%20Users) [B2B / B2B Product / Factiva]
- [B2B Single Day Users on Factiva](../../../../Factiva%20Legacy%20%28for%20review%29/B2B%20Single%20Day%20Users%20on%20Factiva) [B2B / Factiva Legacy (for review)]
