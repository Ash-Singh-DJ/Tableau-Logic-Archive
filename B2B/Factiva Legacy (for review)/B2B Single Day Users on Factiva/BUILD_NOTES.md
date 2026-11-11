# B2B Single Day Users on Factiva

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / Factiva Legacy (for review) |
| Owner | Maria Peco |
| Created | 2025-07-28 |
| Last updated | 2025-09-12 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/3086991 |
| Archived | 2026-11-11 |

## Summary

3 data source(s) in the workbook; 3 with an Athena component (0 embedded, 3 published).

## "Last Page" (published data source)

- **Published source:** "B2B Single Day Users on Factiva - Last Page" in `B2B / B2B Product / Factiva / Datasources`, owner Maria Peco; [archived here](../../B2B%20Product/Factiva/Datasources/B2B%20Single%20Day%20Users%20on%20Factiva%20-%20Last%20Page). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Sheet 11, Sheet 8
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Last Page.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`
- **SQL files:** [Last Page.sql](Last%20Page.sql)

## "Last Page 2" (published data source)

- **Published source:** "B2B Single Day Users on Factiva - Last Page 2" in `B2B / B2B Product / Factiva / Datasources`, owner Maria Peco; [archived here](../../B2B%20Product/Factiva/Datasources/B2B%20Single%20Day%20Users%20on%20Factiva%20-%20Last%20Page%202). The SQL below is copied from it.
- **Shape:** Join of 3 tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Used by worksheets:** Last Page, Last Page %, Sheet 10, Sheet 12 (2)
- **Structure:**

```
- LEFT JOIN on [Custom SQL Query].[department_code] = [Job Function].[Code]
  - LEFT JOIN on [Custom SQL Query].[pib_member_id] = [Cluster Group].[eid]
    - Athena Custom SQL "Custom SQL Query" -> Last Page 2 - Custom SQL Query.sql
    - Athena Custom SQL "Cluster Group" -> Last Page 2 - Cluster Group.sql
  - Google Drive Excel "Job Function" table Sheet1$ (as "Job Function")
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `fact_external_db.omniture_event_fact`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `sandbox_mk.factiva_user_seg_12mo`
- **SQL files:** [Last Page 2 - Custom SQL Query.sql](Last%20Page%202%20-%20Custom%20SQL%20Query.sql), [Last Page 2 - Cluster Group.sql](Last%20Page%202%20-%20Cluster%20Group.sql)

## "Draft3" (published data source)

- **Published source:** "B2B Single Day Users on Factiva - Data Source" in `B2B / B2B Product / Factiva / Datasources`, owner Maria Peco; [archived here](../../B2B%20Product/Factiva/Datasources/B2B%20Single%20Day%20Users%20on%20Factiva%20-%20Data%20Source). The SQL below is copied from it.
- **Shape:** Join of 4 tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Used by worksheets:** Piv, Sheet 5, Sheet 5 (2), Sheet 6, Sheet 7, Sheet 9
- **Structure:**

```
- LEFT JOIN on [Main query].[pib_member_id] = [Cluster].[eid]
  - LEFT JOIN on [Main query].[department_code] = [Job Function].[Code]
    - LEFT JOIN on [Main query].[company_industry] = [Industry Mapping].[SFDC Industry]
      - Athena Custom SQL "Main query" -> Draft3 - Main query.sql
      - Google Drive Excel "Industry Mapping" table Sheet1$ (as "Industry Mapping")
    - Google Drive Excel "Job Function" table Sheet1$ (as "Job Function")
  - Athena Custom SQL "Cluster" -> Draft3 - Cluster.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `fact_external_db.omniture_event_fact`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `reference_external_db.country_reference`, `sandbox_mk.factiva_user_seg_12mo`
- **SQL files:** [Draft3 - Main query.sql](Draft3%20-%20Main%20query.sql), [Draft3 - Cluster.sql](Draft3%20-%20Cluster.sql)
