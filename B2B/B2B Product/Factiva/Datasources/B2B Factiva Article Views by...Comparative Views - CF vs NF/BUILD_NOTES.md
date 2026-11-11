# B2B Factiva Article Views by Source: Comparative Views - CF vs NF

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Product / Factiva / Datasources |
| Owner | James Thomson |
| Created | 2025-07-30 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/90190229 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Join of 2 tables
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Structure:**

```
- LEFT JOIN on if startswith([CFNF].[SourceCode], '{') then UPPER(Mid([CFNF].[SourceCode],12,((FIND([CFNF].[SourceCode],"]"))-13))) else [CFNF].[SourceCode] end = [Source Lookup].[SourceCode]
  - Athena Custom SQL "CFNF" -> CFNF.sql
  - Athena Custom SQL "Source Lookup" -> Source Lookup.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `sandbox_mk.factiva_content_source_current`, `sandbox_mk.factiva_content_source_group_current`, `sandbox_mk.full_roo_table`
- **SQL files:** [CFNF.sql](CFNF.sql), [Source Lookup.sql](Source%20Lookup.sql)

## Connected workbooks

- [B2B Factiva Article Views by Source: Comparative Views](../../Factiva%20Usage%20by%20Source/B2B%20Factiva%20Article%20Views%20by%20Source-%20Comparative%20Views) [B2B / B2B Product / Factiva / Factiva Usage by Source]
