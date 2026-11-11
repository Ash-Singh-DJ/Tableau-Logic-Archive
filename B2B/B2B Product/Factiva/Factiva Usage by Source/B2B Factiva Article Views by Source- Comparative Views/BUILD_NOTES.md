# B2B Factiva Article Views by Source: Comparative Views

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Product / Factiva / Factiva Usage by Source |
| Owner | James Thomson |
| Created | 2025-07-30 |
| Last updated | 2025-09-02 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/3100105 |
| Archived | 2026-11-11 |

## Summary

3 data source(s) in the workbook; 3 with an Athena component (0 embedded, 3 published).

## "Smart Summary backend" (published data source)

- **Published source:** "B2B Factiva Article Views by Source: Comparative Views - Smart Summary backend" in `B2B / B2B Product / Factiva / Datasources`, owner Maria Peco; [archived here](../../Datasources/B2B%20Factiva%20Article%20Views%20by...Views%20-%20Smart%20Summary%20backend). The SQL below is copied from it.
- **Shape:** Join of 2 tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Used by worksheets:** Sheet 10 (2), Smart Sum Pivot Table, Smart Sum Table
- **Structure:**

```
- LEFT JOIN on [Custom SQL Query].[sc3] = [Source lookup].[Source Code (sc)]
  - Athena Custom SQL "Custom SQL Query" -> Smart Summary backend.sql
  - Google Drive Excel "Data for Tableau Factiva Source Dashboard 2025-06-02" table 9453_20250602$ (as "Source lookup")
```
- **Athena tables read:** `sandbox_mk.factiva_content_source_current`, `sandbox_mk.factiva_content_source_group_current`, `sandbox_mk.full_roo_table`, `publisher_reporting_db.commerce_envelope`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `pib_event_data.pib_product_metrics`
- **SQL files:** [Smart Summary backend.sql](Smart%20Summary%20backend.sql)

## "NF AVs by Src code" (published data source)

- **Published source:** "B2B Factiva Article Views by Source: Comparative Views - AVs by Src code" in `B2B / B2B Product / Factiva / Datasources`, owner James Thomson; [archived here](../../Datasources/B2B%20Factiva%20Article%20Views%20by...ative%20Views%20-%20AVs%20by%20Src%20code). The SQL below is copied from it.
- **Shape:** Join of 3 tables
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** By IP, By RPCode, By Source, By Source (2), By Source (3), Sheet 1, Sheet 6
- **Structure:**

```
- LEFT JOIN on UPPER(Mid([Article Views].[ti_td_page_content_source_code],12,((FIND([Article Views].[ti_td_page_content_source_code],"]"))-13))) = [SRC lookup].[SourceCode]
  - LEFT JOIN on [Sem Search].[search_seq] = [Article Views].[search_sequence2]
    - Athena Custom SQL "Sem Search" -> NF AVs by Src code - Sem Search.sql
    - Athena Custom SQL "Article Views" -> NF AVs by Src code - Article Views.sql
  - Athena Custom SQL "SRC lookup" -> NF AVs by Src code - SRC lookup.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `sandbox_mk.factiva_content_source_current`, `sandbox_mk.factiva_content_source_group_current`, `sandbox_mk.full_roo_table`
- **SQL files:** [NF AVs by Src code - Sem Search.sql](NF%20AVs%20by%20Src%20code%20-%20Sem%20Search.sql), [NF AVs by Src code - Article Views.sql](NF%20AVs%20by%20Src%20code%20-%20Article%20Views.sql), [NF AVs by Src code - SRC lookup.sql](NF%20AVs%20by%20Src%20code%20-%20SRC%20lookup.sql)

## "CF vs NF" (published data source)

- **Published source:** "B2B Factiva Article Views by Source: Comparative Views - CF vs NF" in `B2B / B2B Product / Factiva / Datasources`, owner James Thomson; [archived here](../../Datasources/B2B%20Factiva%20Article%20Views%20by...Comparative%20Views%20-%20CF%20vs%20NF). The SQL below is copied from it.
- **Shape:** Join of 2 tables
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Sheet 9
- **Structure:**

```
- LEFT JOIN on if startswith([CFNF].[SourceCode], '{') then UPPER(Mid([CFNF].[SourceCode],12,((FIND([CFNF].[SourceCode],"]"))-13))) else [CFNF].[SourceCode] end = [Source Lookup].[SourceCode]
  - Athena Custom SQL "CFNF" -> CF vs NF - CFNF.sql
  - Athena Custom SQL "Source Lookup" -> CF vs NF - Source Lookup.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `sandbox_mk.factiva_content_source_current`, `sandbox_mk.factiva_content_source_group_current`, `sandbox_mk.full_roo_table`
- **SQL files:** [CF vs NF - CFNF.sql](CF%20vs%20NF%20-%20CFNF.sql), [CF vs NF - Source Lookup.sql](CF%20vs%20NF%20-%20Source%20Lookup.sql)
