# B2B Factiva Usage by Content Source (Classic & New)

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Sales / Product Usage |
| Owner | Maria Peco |
| Created | 2025-08-28 |
| Last updated | 2025-09-17 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/3235810 |
| Archived | 2026-11-11 |

## Summary

1 data source(s) in the workbook; 1 with an Athena component (0 embedded, 1 published).

## "AVs by Source" (published data source)

- **Published source:** "B2B Factiva Usage by Content Source (Classic & New) - AVs by Source" in `B2B / B2B Product / Factiva / Datasources`, owner Maria Peco; [archived here](../../../B2B%20Product/Factiva/Datasources/B2B%20Factiva%20Usage%20by%20Content...lassic%20%26%20New%29%20-%20AVs%20by%20Source). The SQL below is copied from it.
- **Shape:** Join of 3 tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Used by worksheets:** Sheet 1, Sheet 2, Sheet 3
- **Structure:**

```
- LEFT JOIN on [Custom SQL Query].[plan_id] = [R&C Lookup].[ACCESS CODE]
  - LEFT JOIN on [Custom SQL Query].[Source_code] = [Src lookup].[SourceCode]
    - Athena Custom SQL "Custom SQL Query" -> AVs by Source - Custom SQL Query.sql
    - Athena Custom SQL "Src lookup" -> AVs by Source - Src lookup.sql
  - Google Drive Excel "R&C Lookup" table Sheet1$ (as "R&C Lookup")
```
- **Athena tables read:** `fact_external_db.omniture_event_fact`, `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `reference_external_db.pib_product_dimension`, `dimension_external_db.pib_territory_dimension`, `reference_external_db.country_reference`, `sandbox_mk.factiva_content_source_current`, `sandbox_mk.factiva_content_source_group_current`, `sandbox_mk.full_roo_table`
- **SQL files:** [AVs by Source - Custom SQL Query.sql](AVs%20by%20Source%20-%20Custom%20SQL%20Query.sql), [AVs by Source - Src lookup.sql](AVs%20by%20Source%20-%20Src%20lookup.sql)
