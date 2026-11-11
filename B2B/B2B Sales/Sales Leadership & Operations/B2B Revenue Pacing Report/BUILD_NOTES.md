# B2B Revenue Pacing Report

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Sales / Sales Leadership & Operations |
| Owner | Maria Peco |
| Created | 2025-07-28 |
| Last updated | 2025-08-21 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/3086842 |
| Archived | 2026-11-11 |

## Summary

1 data source(s) in the workbook; 1 with an Athena component (0 embedded, 1 published).

## "Athena SQL" (published data source)

- **Published source:** "B2B Revenue Pacing Report" in `B2B / B2B Sales / Sales Leadership & Operations / Datasources`, owner Maria Peco; [archived here](../Datasources/B2B%20Revenue%20Pacing%20Report). The SQL below is copied from it.
- **Shape:** Join of 5 tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Used by worksheets:** Advanced, Best Case, Bottom Deals Table by Region , Committed, Compare Button, Date text, Date text 2, Deals by Opp Owner sheet, Default Advanced filters, Default set, Default set 2, Diff1, Fiscal Wk 1 Opp Table1, Fiscal Wk 1 Table, Fiscal Wk 2 Opp Table1, Fiscal Wk 2 Table, Fiscal Wk 3 Opp Table, Fiscal Wk 3 Table, Fiscal Wk 4 Opp Table, Fiscal Wk 4 Table, Fiscal Wk 5 Opp Table, Fiscal Wk 5 Table, Fiscal Wk1 Chart, Fiscal Wk1 Table, Fiscal Wk2 Chart, Fiscal Wk3 Chart, Fiscal Wk4 Chart, Fiscal Wk5 Chart, Home Button, Link to Forecast, Meetings, Net , Opp Owner table, Opps Pivot, Opps breakdown, Opps breakdown (2), Opps breakdown Adv, Opps breakdown Adv (2), Opps breakdown copy, Opps breakdown home, Opps breakdown- New Metrics, Push&Pull, Push&Pull extra, Reset, Reset Filters, Sheet 43, Sheet 46, Sheet 50, Sheet 52, Sheet 53, Sheet 54, Sheet 55, Starting Point Chart, Starting Point Opp Table1, Starting Point Table, Table Default, Table Default 2, Top Deals Table by Region, Top Deals button
- **Structure:**

```
- LEFT JOIN on [Main Forecast Data].[Specialist1] = [Specialist Mapping].[Specialist Associated]
  - LEFT JOIN on [Main Forecast Data].[product_service] = [SFDC to Custom Groups].[Product/Service]
    - LEFT JOIN on [Main Forecast Data].[product_service] = [Product Service mapping].[product_service]
      - LEFT JOIN on [Main Forecast Data].[company_industry] = [Industry Mapping].[SFDC Industry]
        - Athena Custom SQL "Main Forecast Data" -> Athena SQL - Main Forecast Data.sql
        - Google Drive Excel "Industry Mapping" table Sheet1$ (as "Industry Mapping")
      - Athena Custom SQL "Product Service mapping" -> Athena SQL - Product Service mapping.sql
    - Google Drive Excel "JS Product Mapping" table SFDC to Custom Groups$ (as "SFDC to Custom Groups")
  - Google Drive Excel "Specialist Mapping" table Sheet1$ (as "Specialist Mapping")
```
- **Athena tables read:** `dimension_external_db.pib_leads_dimension_history`, `dimension_external_db.pib_opportunity_dimension_history`, `dimension_external_db.pib_product_services_dimension_history`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_user_dimension`, `dimension_external_db.pib_territory_dimension`, `reference_external_db.fx_rates_current`, `reference_external_db.pib_product_dimension`, `reference_external_db.date_dimension`, `dimension_external_db.pib_campaign_influence`, `dimension_external_db.pib_campaign_dimension`, `dimension_external_db.pib_leads_dimension`, `dimension_external_db.pib_opportunity_dimension`, `dimension_external_db.pib_meeting_summary`, `dimension_external_db.pib_product_service_attributes`
- **SQL files:** [Athena SQL - Main Forecast Data.sql](Athena%20SQL%20-%20Main%20Forecast%20Data.sql), [Athena SQL - Product Service mapping.sql](Athena%20SQL%20-%20Product%20Service%20mapping.sql)
