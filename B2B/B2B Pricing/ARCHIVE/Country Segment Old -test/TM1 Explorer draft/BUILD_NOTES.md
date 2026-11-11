# TM1 Explorer draft

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Pricing / ARCHIVE / Country Segment Old /test |
| Owner | Jonas Coelho |
| Created | 2025-12-12 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/3728799 |
| Archived | 2026-11-11 |

## Summary

1 data source(s) in the workbook; 1 with an Athena component (1 embedded, 0 published).

## "Historical Pricing TM1" (embedded)

- **Shape:** Join of 2 tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Used by worksheets:** TM1 Explorer
- **Structure:**

```
- LEFT JOIN on lower([Custom SQL Query].[bill_acct_country]) = lower([Emerging Market Countries].[Country])
  - Athena Custom SQL "Custom SQL Query" -> Historical Pricing TM1.sql
  - Google Drive Excel "(2)" table Sheet1$ (as "Emerging Market Countries")
```
- **Athena tables read:** `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_corporate_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_user_dimension`, `dimension_external_db.pib_territory_dimension`, `dimension_external_db.pib_contract_dimension`, `reference_external_db.pib_product_dimension`, `finance_external_db.cibs_products_rules`, `finance_external_db.tm1_cibs_gltransrel`, `finance_external_db.cibs_products`, `google_sheets_db.master_rate_card_table_cp_datateam`, `fact_external_db.tm1_fact`, `dimension_external_db.pib_product_service_attributes`, `dimension_external_db.pib_cibs_billing_charges_dimension`, `reference_external_db.date_dimension`, `reference_external_db.fx_rates_history`, `google_sheets_db.master_rate_card_pricing_fx_rates`, `dimension_external_db.dnb_company_information`, `dimension_external_db.dnb_industry_and_activity`, `reference_external_db.industry_codes_sic`, `reference_external_db.industry_codes_naics`, `dnb_firmographic_db.financials_current`, `reference_external_db.fx_rates_current`, `dnb_firmographic_db.organization_size_current`, `dnb_firmographic_db.corporate_linkage_current`, `google_sheets_db.ubo_usage_monthly_unpivot`, `finance_external_db.jasper_gfo105_account_details_for_bu_history`, `sandbox_mk.date_alignment`, `reference_external_db.cibs_currency_code_mapping`, `dimension_external_db.pib_country_dimension`
- **SQL files:** [Historical Pricing TM1.sql](Historical%20Pricing%20TM1.sql)
