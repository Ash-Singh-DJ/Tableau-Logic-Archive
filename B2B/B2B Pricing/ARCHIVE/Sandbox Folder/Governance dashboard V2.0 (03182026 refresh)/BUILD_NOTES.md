# Governance dashboard V2.0 (03182026 refresh)

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Pricing / ARCHIVE / Sandbox Folder |
| Owner | svc_dj tableaucdl_b2b |
| Created | 2026-03-18 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/4255921 |
| Archived | 2026-11-11 |

## Summary

1 data source(s) in the workbook; 1 with an Athena component (1 embedded, 0 published).

## "Opp Pricing Dataset CDP" (embedded)

- **Shape:** Join of 2 tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Used by worksheets:** Chart 1 - F, Chart 1 - H, Chart 2, Details, Discounts comparison, RSD Summary, Summary 1, Summary 2, VP Summary
- **Structure:**

```
- LEFT JOIN on lower([Opportunity Dataset].[opportunity_country]) = lower([EM].[Country])
  - Athena Custom SQL "Opportunity Dataset" -> Opp Pricing Dataset CDP.sql
  - Google Drive Excel "Emerging Markets" table Sheet1$ (as "EM")
```
- **Athena tables read:** `fact_external_db.pib_account_hierarchy_fact`, `dimension_external_db.pib_opportunity_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_corporate_dimension`, `dimension_external_db.pib_billing_account_dimension`, `google_sheets_db.master_rate_card_table_cp_datateam`, `dimension_external_db.pib_product_services_dimension`, `dimension_external_db.pib_product_service_attributes`, `dimension_external_db.pib_campaign_dimension`, `dimension_external_db.pib_user_dimension`, `dimension_external_db.pib_territory_dimension`, `reference_external_db.fx_rates_current`, `reference_external_db.pib_product_dimension`, `dimension_external_db.pib_contact_dimension`, `reference_external_db.date_dimension`, `dimension_external_db.pib_customer_service_case_dimension`, `google_sheets_db.master_rate_card_pricing_fx_rates`, `dimension_external_db.pib_country_dimension`
- **SQL files:** [Opp Pricing Dataset CDP.sql](Opp%20Pricing%20Dataset%20CDP.sql)
