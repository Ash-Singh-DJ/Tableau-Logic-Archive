# B2B Cancels & Downsells Dashboard

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Sales / Sales Leadership & Operations |
| Owner | Steve Bishop |
| Created | 2025-10-07 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/3436796 |
| Archived | 2026-11-11 |

## Summary

2 data source(s) in the workbook; 1 with an Athena component (1 embedded, 0 published).
Other data sources: "Sheet1 (Navigation File)" (Extract (.hyper)).

## "custom sql query+ (Multiple Connections)" (embedded)

- **Shape:** Join of 3 tables -- Athena + Excel file + Text/CSV file
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Excel file; Text/CSV file
- **Used by worksheets:** Average Loss Opp Age, Average Opportunity Loss Size, Average Product-Service Loss Size, Average Size of Lost Revenue Opportunities by Cycle Length, Deal Size Distributions (Closed Won Date), Deal Size Distributions (Open Date), Fiscal Date Check (Close), Fiscal Date Check (Open), MultiChart View (Won Opps/Sales $), Net Product-Service Loss Size, Opportunity Counts, Opportunity Table, Pivot Table View (Opened Opps & Sales $), Pivot Table View (Won Opps & Sales $), Pivot Table View (Won Sales $ Only), Pivot Table View (percentages), Product Service Counts, Product-Service Table, Proportion of Lost Revenue Opps & Sales $ Lost by Cycle Length, Save Rates & Trends Breakdown, Sheet 25, Total Loss Sizes (Opportunities), WinRate
- **Structure:**

```
- LEFT JOIN on [Custom SQL Query].[company_industry] = [Industry Rollup Table (no gov&other) js v2.csv].[SFDC Industry]
  - LEFT JOIN on [Custom SQL Query].[territory_name] = [Geo Region Mapping FY21].[Sales Territory]
    - Athena Custom SQL "Custom SQL Query" -> custom sql query+ (Multiple Connections).sql
    - Excel file "Geo Region rollup Table FY21" table Sheet1$ (as "Geo Region Mapping FY21")
  - Text/CSV file "Industry Rollup Table" table Industry Rollup Table (no gov&other)  js v2#csv (as "Industry Rollup Table (no gov&other)  js v2.csv")
```
- **Athena tables read:** `fact_external_db.pib_account_hierarchy_fact`, `dimension_external_db.pib_opportunity_dimension_history`, `dimension_external_db.pib_opportunity_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_corporate_dimension`, `dimension_external_db.pib_product_services_dimension`, `dimension_external_db.pib_campaign_dimension`, `dimension_external_db.pib_campaign_influence`, `dimension_external_db.pib_user_dimension`, `dimension_external_db.pib_territory_dimension`, `reference_external_db.fx_rates_current`, `reference_external_db.pib_product_dimension`, `dimension_external_db.pib_product_service_attributes`, `reference_external_db.date_dimension`
- **SQL files:** [custom sql query+ (Multiple Connections).sql](custom%20sql%20query%2B%20%28Multiple%20Connections%29.sql)
