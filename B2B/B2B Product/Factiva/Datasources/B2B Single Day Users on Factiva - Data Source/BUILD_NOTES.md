# B2B Single Day Users on Factiva - Data Source

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Product / Factiva / Datasources |
| Owner | Maria Peco |
| Created | 2025-07-28 |
| Last updated | 2026-06-08 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/103988591 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Join of 4 tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Structure:**

```
- LEFT JOIN on [Main query].[pib_member_id] = [Cluster].[eid]
  - LEFT JOIN on [Main query].[department_code] = [Job Function].[Code]
    - LEFT JOIN on [Main query].[company_industry] = [Industry Mapping].[SFDC Industry]
      - Athena Custom SQL "Main query" -> Main query.sql
      - Google Drive Excel "Industry Mapping" table Sheet1$ (as "Industry Mapping")
    - Google Drive Excel "Job Function" table Sheet1$ (as "Job Function")
  - Athena Custom SQL "Cluster" -> Cluster.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `fact_external_db.omniture_event_fact`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `reference_external_db.country_reference`, `sandbox_mk.factiva_user_seg_12mo`
- **SQL files:** [Main query.sql](Main%20query.sql), [Cluster.sql](Cluster.sql)

## Connected workbooks

- [Single Day Users](../../Single%20Day%20Users) [B2B / B2B Product / Factiva]
- [B2B Single Day Users on Factiva](../../../../Factiva%20Legacy%20%28for%20review%29/B2B%20Single%20Day%20Users%20on%20Factiva) [B2B / Factiva Legacy (for review)]
