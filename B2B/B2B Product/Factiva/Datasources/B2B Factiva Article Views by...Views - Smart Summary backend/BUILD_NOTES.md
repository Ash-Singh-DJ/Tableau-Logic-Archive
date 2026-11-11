# B2B Factiva Article Views by Source: Comparative Views - Smart Summary backend

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Product / Factiva / Datasources |
| Owner | Maria Peco |
| Created | 2025-07-30 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/126130789 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Join of 2 tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Structure:**

```
- LEFT JOIN on [Custom SQL Query].[sc3] = [Source lookup].[Source Code (sc)]
  - Athena Custom SQL "Custom SQL Query" -> Custom SQL Query.sql
  - Google Drive Excel "Data for Tableau Factiva Source Dashboard 2025-06-02" table 9453_20250602$ (as "Source lookup")
```
- **Athena tables read:** `sandbox_mk.factiva_content_source_current`, `sandbox_mk.factiva_content_source_group_current`, `sandbox_mk.full_roo_table`, `publisher_reporting_db.commerce_envelope`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `pib_event_data.pib_product_metrics`
- **SQL files:** [Custom SQL Query.sql](Custom%20SQL%20Query.sql)

## Connected workbooks

- [B2B Factiva Article Views by Source: Comparative Views](../../Factiva%20Usage%20by%20Source/B2B%20Factiva%20Article%20Views%20by%20Source-%20Comparative%20Views) [B2B / B2B Product / Factiva / Factiva Usage by Source]
