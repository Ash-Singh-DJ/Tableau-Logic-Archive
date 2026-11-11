# B2B Consumer Usage Dashboard

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Sales / Product Usage |
| Owner | Steve Bishop |
| Created | 2025-05-19 |
| Last updated | 2026-02-24 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/2770717 |
| Archived | 2026-11-11 |

## Summary

1 data source(s) in the workbook; 1 with an Athena component (0 embedded, 1 published).

## "Custom SQL Query (dimension_external_db)" (published data source)

- **Published source:** "B2B Consumer Usage Dashboard - Data Source" in `B2B / B2B Sales / Data Sources`, owner James Thomson; [archived here](../../Data%20Sources/B2B%20Consumer%20Usage%20Dashboard%20-%20Data%20Source). The SQL below is copied from it.
- **Shape:** Join of 3 tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Used by worksheets:** Pivot Table, Sheet 2
- **Structure:**

```
- LEFT JOIN on [Custom SQL Query].[company_industry] = [Industry Rollup Table (no gov&o1].[SFDC Industry]
  - LEFT JOIN on [Custom SQL Query].[territory_name] = [Geo Region Rollup].[Sales Territory]
    - Athena Custom SQL "Custom SQL Query" -> Custom SQL Query (dimension_external_db).sql
    - Google Drive Excel "Geo Region rollup Table FY21" table Sheet1$ (as "Geo Region Rollup")
  - Google Drive Excel "Industry Rollup Table (no gov&other)  js v2" table Industry Rollup Table (no gov&o$ (as "Industry Rollup Table (no gov&o1")
```
- **Athena tables read:** `fact_external_db.omniture_event_fact`, `reference_external_db.date_dimension`, `dimension_external_db.pib_membership_dimension`, `subscription_external_db.identity_lookup`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_user_dimension`, `dimension_external_db.pib_territory_dimension`, `reference_external_db.country_reference`
- **SQL files:** [Custom SQL Query (dimension_external_db).sql](Custom%20SQL%20Query%20%28dimension_external_db%29.sql)
