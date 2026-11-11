# B2B Forecast Datasource

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Sales / Sales Leadership & Operations / Datasources |
| Owner | Maria Peco |
| Created | 2025-09-29 |
| Last updated | 2026-04-07 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/101125312 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Join of 5 tables -- Athena + Google Drive Excel + Excel file
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Excel file; Google Drive Excel
- **Structure:**

```
- LEFT JOIN on [Main Forecast Data].[Specialist1] = [Specialist Mapping].[Specialist Associated]
  - LEFT JOIN on [Main Forecast Data].[product_service] = [JS Product Mapping].[Product/Service]
    - LEFT JOIN on [Main Forecast Data].[product_service] = [Product Service mapping].[product_service]
      - LEFT JOIN on [Main Forecast Data].[company_industry] = [Industry Mapping].[SFDC Industry]
        - Athena Custom SQL "Main Forecast Data" -> Main Forecast Data.sql
        - Excel file "Industry Mapping" table Sheet1$ (as "Industry Mapping")
      - Athena Custom SQL "Product Service mapping" -> Product Service mapping.sql
    - Google Drive Excel "JS Product_Service Grouping for Tableau _ CDP" table SFDC to Custom Groups$ (as "JS Product Mapping")
  - Google Drive Excel "Specialist 1 --_ Specialist Associated [mapping for CDP]" table Sheet1$ (as "Specialist Mapping")
```
- **Athena tables read:** `dimension_external_db.pib_leads_dimension_history`, `dimension_external_db.pib_opportunity_dimension_history`, `dimension_external_db.pib_product_services_dimension_history`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_user_dimension`, `dimension_external_db.pib_territory_dimension`, `reference_external_db.fx_rates_current`, `reference_external_db.pib_product_dimension`, `dimension_external_db.pib_campaign_influence`, `dimension_external_db.pib_campaign_dimension`, `dimension_external_db.pib_leads_dimension`, `dimension_external_db.pib_opportunity_dimension`, `dimension_external_db.pib_meeting_summary`, `dimension_external_db.pib_product_service_attributes`
- **SQL files:** [Main Forecast Data.sql](Main%20Forecast%20Data.sql), [Product Service mapping.sql](Product%20Service%20mapping.sql)

## Connected workbooks

_No connected workbooks found._
