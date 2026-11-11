# take2

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Pricing / ARCHIVE / Sandbox Folder |
| Owner | SEBASTIEN DESIR |
| Created | 2025-11-30 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/3673099 |
| Archived | 2026-11-11 |

## Summary

2 data source(s) in the workbook; 2 with an Athena component (2 embedded, 0 published).

## "Historical Pricing TM1 B2B Close" (embedded)

- **Shape:** Join of 2 tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Used by worksheets:** Billing Accounts by Region Trend, Country Revenue, Customers by % of Rate Card, Discounts by Region Trend, Individual DB Table (2), Individual DB Table 1, Industry Revenue , Pricing by Volume Tier, Pricing by Volume Tier (draft 1), Product Discounting, Regional Discounting, Revenue by Region Trend, SD_Pivot Table, Summary by BU, Table for Popout, Trend Revenue, Unit Price vs. Volume, Volumes by Region Trend, [Product 1] Number of Customers by Volume Tier & Discount Bin, [Product 1] Regional Revenue Vs. Discount, [Product 1] Top Customers, [Product 1] Total Revenue vs Rate Card Time Series, [Product 1] Unit Price vs. Volume, [Product 2] Number of Customers by Volume Tier & Discount Bin, [Product 2] Regional Revenue Vs. Discount, [Product 2] Top Customers, [Product 2] Total Revenue vs Rate Card Time Series, [Product 2] Unit Price vs. Volume
- **Structure:**

```
- LEFT JOIN on lower([Custom SQL Query].[bill_acct_country]) = lower([Emerging Markets].[Country])
  - Athena Custom SQL "Custom SQL Query" -> Historical Pricing TM1 B2B Close.sql
  - Google Drive Excel "Emerging Markets" table Sheet1$ (as "Emerging Markets")
```
- **Athena tables read:** `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_corporate_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_user_dimension`, `dimension_external_db.pib_territory_dimension`, `reference_external_db.pib_product_dimension`, `finance_external_db.cibs_products_rules`, `finance_external_db.tm1_cibs_gltransrel`, `finance_external_db.cibs_products`, `google_sheets_db.master_rate_card_table_cp_datateam`, `fact_external_db.tm1_fact`, `dimension_external_db.pib_product_service_attributes`, `dimension_external_db.pib_cibs_billing_charges_dimension`, `dimension_external_db.pib_contract_dimension`, `reference_external_db.date_dimension`, `reference_external_db.fx_rates_history`, `google_sheets_db.master_rate_card_pricing_fx_rates`, `dimension_external_db.dnb_company_information`, `dimension_external_db.dnb_industry_and_activity`, `reference_external_db.industry_codes_sic`, `reference_external_db.industry_codes_naics`, `finance_external_db.jasper_gfo105_account_details_for_bu_history`, `sandbox_mk.date_alignment`, `reference_external_db.fx_rates_current`, `reference_external_db.cibs_currency_code_mapping`
- **SQL files:** [Historical Pricing TM1 B2B Close.sql](Historical%20Pricing%20TM1%20B2B%20Close.sql)

## "Opp Pricing Dataset CDP" (embedded)

- **Shape:** Join of 2 tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Used by worksheets:** Summary by BU
- **Structure:**

```
- LEFT JOIN on lower([Opportunity Dataset].[opportunity_country]) = lower([EM].[Country])
  - Athena Custom SQL "Opportunity Dataset" -> Opp Pricing Dataset CDP.sql
  - Google Drive Excel "Emerging Markets" table Sheet1$ (as "EM")
```
- **Athena tables read:** `fact_external_db.pib_account_hierarchy_fact`, `dimension_external_db.pib_opportunity_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_corporate_dimension`, `dimension_external_db.pib_billing_account_dimension`, `google_sheets_db.master_rate_card_table_cp_datateam`, `dimension_external_db.pib_product_services_dimension`, `dimension_external_db.pib_product_service_attributes`, `dimension_external_db.pib_campaign_dimension`, `dimension_external_db.pib_user_dimension`, `dimension_external_db.pib_territory_dimension`, `reference_external_db.fx_rates_current`, `reference_external_db.pib_product_dimension`, `dimension_external_db.pib_contact_dimension`, `reference_external_db.date_dimension`, `dimension_external_db.pib_customer_service_case_dimension`, `google_sheets_db.master_rate_card_pricing_fx_rates`
- **SQL files:** [Opp Pricing Dataset CDP.sql](Opp%20Pricing%20Dataset%20CDP.sql)
