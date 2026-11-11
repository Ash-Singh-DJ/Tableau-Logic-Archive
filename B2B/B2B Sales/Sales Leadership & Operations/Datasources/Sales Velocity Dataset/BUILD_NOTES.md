# Sales Velocity Dataset

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Sales / Sales Leadership & Operations / Datasources |
| Owner | Maria Peco |
| Created | 2025-08-28 |
| Last updated | 2026-04-07 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/95014491 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Join of 5 tables -- Athena + Google Drive Excel + Text/CSV file
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel; Text/CSV file
- **Structure:**

```
- LEFT JOIN on [Sales Analytics Dataset].[product_service] = [SFDC to Custom Groups].[Product/Service]
  - LEFT JOIN on [Industry Rollup Table (no gov&other) js v2.csv].[SFDC Industry] = [Grouped Industry Table].[SFDC Industry]
    - LEFT JOIN on [Sales Analytics Dataset].[territory_name] = [Geo Region rollup Table FY21].[Sales Territory]
      - LEFT JOIN on [Sales Analytics Dataset].[company_industry] = [Industry Rollup Table (no gov&other) js v2.csv].[SFDC Industry]
        - Athena Custom SQL "Sales Analytics Dataset" -> Sales Analytics Dataset.sql
        - Text/CSV file "Industry Rollup Table" table Industry Rollup Table (no gov&other)  js v2#csv (as "Industry Rollup Table (no gov&other)  js v2.csv")
      - Google Drive Excel "Geo Region rollup Table FY21" table Sheet1$ (as "Geo Region rollup Table FY21")
    - Google Drive Excel "Industry Mapping" table Sheet1$ (as "Grouped Industry Table")
  - Google Drive Excel "(2)" table SFDC to Custom Groups$ (as "SFDC to Custom Groups")
```
- **Athena tables read:** `fact_external_db.pib_account_hierarchy_fact`, `dimension_external_db.pib_opportunity_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_corporate_dimension`, `dimension_external_db.pib_campaign_influence`, `dimension_external_db.pib_campaign_dimension`, `dimension_external_db.pib_product_services_dimension`, `dimension_external_db.pib_user_dimension`, `dimension_external_db.pib_territory_dimension`, `reference_external_db.fx_rates_current`, `reference_external_db.pib_product_dimension`, `dimension_external_db.pib_product_service_attributes`, `dimension_external_db.pib_contact_dimension`, `reference_external_db.date_dimension`, `dimension_external_db.pib_leads_dimension`, `dimension_external_db.pib_leads_dimension_history`
- **SQL files:** [Sales Analytics Dataset.sql](Sales%20Analytics%20Dataset.sql)

## Connected workbooks

_No connected workbooks found._
