# Pricing Bundle Workbook

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Pricing |
| Owner | Steve Bishop |
| Created | 2025-09-19 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/3354747 |
| Archived | 2026-11-11 |

## Summary

2 data source(s) in the workbook; 2 with an Athena component (2 embedded, 0 published).

## "Pricing_Bundle_Dataset_TM1" (embedded)

- **Shape:** Join of 2 tables -- Athena + Excel file
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Excel file
- **Used by worksheets:** Product Bundle Pivot
- **Structure:**

```
- LEFT JOIN on [Custom SQL Query].[territory_name] = [NEW FILE].[Sales Territory]
  - Athena Custom SQL "Custom SQL Query" -> Pricing_Bundle_Dataset_TM1.sql
  - Excel file "Geo Region rollup Table FY21 (Oct 2021 update)" table NEW FILE$ (as "NEW FILE")
```
- **Athena tables read:** `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_corporate_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_user_dimension`, `dimension_external_db.pib_territory_dimension`, `reference_external_db.pib_product_dimension`, `finance_external_db.cibs_products_rules`, `finance_external_db.tm1_cibs_gltransrel`, `finance_external_db.cibs_products`, `google_sheets_db.master_rate_card_table_cp_datateam`, `fact_external_db.tm1_fact`, `dimension_external_db.pib_product_service_attributes`, `dimension_external_db.pib_cibs_billing_charges_dimension`, `dimension_external_db.pib_contract_dimension`, `reference_external_db.date_dimension`, `reference_external_db.fx_rates_history`, `google_sheets_db.master_rate_card_pricing_fx_rates`, `reference_external_db.cibs_currency_code_mapping`
- **SQL files:** [Pricing_Bundle_Dataset_TM1.sql](Pricing_Bundle_Dataset_TM1.sql)

## "TM1 Raw Data for Pricing" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Company View, Product Market Basket, Product Table
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> TM1 Raw Data for Pricing.sql
```
- **Athena tables read:** `fact_external_db.tm1_fact`, `dimension_external_db.pib_product_service_attributes`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_contract_dimension`, `reference_external_db.pib_product_dimension`
- **SQL files:** [TM1 Raw Data for Pricing.sql](TM1%20Raw%20Data%20for%20Pricing.sql)
