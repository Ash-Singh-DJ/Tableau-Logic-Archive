# B2B Opportunity Pricing Dashboard & Deal Desk

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Pricing / ARCHIVE |
| Owner | Maria Peco |
| Created | 2025-05-19 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/2770796 |
| Archived | 2026-11-11 |

## Summary

1 data source(s) in the workbook; 1 with an Athena component (1 embedded, 0 published).

## "Opp Pricing Dataset CDP" (embedded)

- **Shape:** Join of 2 tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Used by worksheets:** $ Discount by Region, $ Discount by Region (Multi-Prod), Annualized Discount $ by Volume Tier & Discount Bin, Count of Opportunities by % of Rate Card Price, Count of Opportunities by % of Rate Card Price (Multi-Prod), Discount Dispersion by Region, Discount by Period, Opportunities $ by % of Rate Card, Product Velocity, Revenue by Region, Revenue by Region (Multi-Prod), Summary by Product, Summary by Product (Multi-Prod), Time Series Aggregate, Top Opportunities, Top Opportunities (DEAL DESK), Top Products By Annualized Disocunts, Top Products by Discount$ & Revenue, Unit Price by Period, Unit Price vs Volume by Region, Win/Loss Tornado by Product
- **Structure:**

```
- LEFT JOIN on lower([Opportunity Dataset].[opportunity_country]) = lower([EM].[Country])
  - Athena Custom SQL "Opportunity Dataset" -> Opp Pricing Dataset CDP.sql
  - Google Drive Excel "Emerging Markets" table Sheet1$ (as "EM")
```
- **Athena tables read:** `fact_external_db.pib_account_hierarchy_fact`, `dimension_external_db.pib_opportunity_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_corporate_dimension`, `dimension_external_db.pib_billing_account_dimension`, `google_sheets_db.master_rate_card_table_cp_datateam`, `dimension_external_db.pib_product_services_dimension`, `dimension_external_db.pib_product_service_attributes`, `dimension_external_db.pib_campaign_dimension`, `dimension_external_db.pib_user_dimension`, `dimension_external_db.pib_territory_dimension`, `reference_external_db.fx_rates_current`, `reference_external_db.pib_product_dimension`, `dimension_external_db.pib_contact_dimension`, `reference_external_db.date_dimension`, `dimension_external_db.pib_customer_service_case_dimension`, `google_sheets_db.master_rate_card_pricing_fx_rates`
- **SQL files:** [Opp Pricing Dataset CDP.sql](Opp%20Pricing%20Dataset%20CDP.sql)
