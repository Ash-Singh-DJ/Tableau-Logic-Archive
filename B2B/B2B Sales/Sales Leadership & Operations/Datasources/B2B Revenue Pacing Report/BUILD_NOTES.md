# B2B Revenue Pacing Report

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Sales / Sales Leadership & Operations / Datasources |
| Owner | Maria Peco |
| Created | 2025-07-28 |
| Last updated | 2026-07-23 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/121459935 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Join of 5 tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Structure:**

```
- LEFT JOIN on [Main Forecast Data].[Specialist1] = [Specialist Mapping].[Specialist Associated]
  - LEFT JOIN on [Main Forecast Data].[product_service] = [SFDC to Custom Groups].[Product/Service]
    - LEFT JOIN on [Main Forecast Data].[product_service] = [Product Service mapping].[product_service]
      - LEFT JOIN on [Main Forecast Data].[company_industry] = [Industry Mapping].[SFDC Industry]
        - Athena Custom SQL "Main Forecast Data" -> Main Forecast Data.sql
        - Google Drive Excel "Industry Mapping" table Sheet1$ (as "Industry Mapping")
      - Athena Custom SQL "Product Service mapping" -> Product Service mapping.sql
    - Google Drive Excel "JS Product Mapping" table SFDC to Custom Groups$ (as "SFDC to Custom Groups")
  - Google Drive Excel "Specialist Mapping" table Sheet1$ (as "Specialist Mapping")
```
- **Athena tables read:** `dimension_external_db.pib_leads_dimension_history`, `dimension_external_db.pib_opportunity_dimension_history`, `dimension_external_db.pib_product_services_dimension_history`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_user_dimension`, `dimension_external_db.pib_territory_dimension`, `reference_external_db.fx_rates_current`, `reference_external_db.pib_product_dimension`, `reference_external_db.date_dimension`, `dimension_external_db.pib_campaign_influence`, `dimension_external_db.pib_campaign_dimension`, `dimension_external_db.pib_leads_dimension`, `dimension_external_db.pib_opportunity_dimension`, `dimension_external_db.pib_meeting_summary`, `dimension_external_db.pib_product_service_attributes`
- **SQL files:** [Main Forecast Data.sql](Main%20Forecast%20Data.sql), [Product Service mapping.sql](Product%20Service%20mapping.sql)

## Connected workbooks

- [B2B Revenue Pacing Report](../../B2B%20Revenue%20Pacing%20Report) [B2B / B2B Sales / Sales Leadership & Operations]
