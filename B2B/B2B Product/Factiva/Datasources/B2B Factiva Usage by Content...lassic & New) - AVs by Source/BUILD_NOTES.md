# B2B Factiva Usage by Content Source (Classic & New) - AVs by Source

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Product / Factiva / Datasources |
| Owner | Maria Peco |
| Created | 2025-08-28 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/95017206 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Join of 3 tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Structure:**

```
- LEFT JOIN on [Custom SQL Query].[plan_id] = [R&C Lookup].[ACCESS CODE]
  - LEFT JOIN on [Custom SQL Query].[Source_code] = [Src lookup].[SourceCode]
    - Athena Custom SQL "Custom SQL Query" -> Custom SQL Query.sql
    - Athena Custom SQL "Src lookup" -> Src lookup.sql
  - Google Drive Excel "R&C Lookup" table Sheet1$ (as "R&C Lookup")
```
- **Athena tables read:** `fact_external_db.omniture_event_fact`, `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `reference_external_db.pib_product_dimension`, `dimension_external_db.pib_territory_dimension`, `reference_external_db.country_reference`, `sandbox_mk.factiva_content_source_current`, `sandbox_mk.factiva_content_source_group_current`, `sandbox_mk.full_roo_table`
- **SQL files:** [Custom SQL Query.sql](Custom%20SQL%20Query.sql), [Src lookup.sql](Src%20lookup.sql)

## Connected workbooks

- [B2B Factiva Usage by Content Source (Classic & New)](../../../../B2B%20Sales/Product%20Usage/B2B%20Factiva%20Usage%20by%20Content%20Source%20%28Classic%20%26%20New%29) [B2B / B2B Sales / Product Usage]
