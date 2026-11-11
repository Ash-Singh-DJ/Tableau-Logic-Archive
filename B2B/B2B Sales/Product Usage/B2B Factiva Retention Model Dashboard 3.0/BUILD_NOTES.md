# B2B Factiva Retention Model Dashboard 3.0

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Sales / Product Usage |
| Owner | Porfirio Hernandez |
| Created | 2025-05-23 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/2786593 |
| Archived | 2026-11-11 |

## Summary

3 data source(s) in the workbook; 3 with an Athena component (3 embedded, 0 published).

## "Churn Outputs and Explanations" (embedded)

- **Shape:** Join of 5 tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / zoolander_db); Google Drive Excel
- **Used by worksheets:** Active Over Reg Counts, Beeswarm Plot, Company List Risk Scores, Company Name, Feature List, Glossary Page, Metric Analysis, New Factiva Buckets, New Factiva Companies Count, Risk Category Counts, Risk Score Distribution, Risk Score Distribution (2), Risky Meetings Counts, Shap Values, Shap Values v1, Shap Values v2, Sheet 1 (2), Sheet 23, Target, Top Features, dependence plot, total shap
- **Structure:**

```
- LEFT JOIN on [Churn Prediction Explanations].[feature] = [feature_glossary_v3].[field]
  - LEFT JOIN on [Churn Output Analysis].[company_sfdc_id] = [TM1 Revenue].[company_sfdc_id]
    - LEFT JOIN on [Churn Output Analysis].[company_sfdc_id] = [Territories, Owners, Etc].[company_sfdc_id]
      - LEFT JOIN on [Churn Output Analysis].[company_sfdc_id] = [Churn Prediction Explanations].[company_sfdc_id]
        - Athena Custom SQL "Churn Output Analysis" -> Churn Outputs and Explanations - Churn Output Analysis.sql
        - Athena Custom SQL "Churn Prediction Explanations" -> Churn Outputs and Explanations - Churn Prediction Explanations.sql
      - Athena Custom SQL "Territories, Owners, Etc" -> Churn Outputs and Explanations - Territories, Owners, Etc.sql
    - Athena Custom SQL "TM1 Revenue" -> Churn Outputs and Explanations - TM1 Revenue.sql
  - Google Drive Excel "feature_glossary" table feature_glossary_v3$ (as "feature_glossary_v3")
```
- **Athena tables read:** `zoolander_db.churn_v2_output_analysis`, `zoolander_db.churn_v2_prediction_explanations`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_territory_dimension`, `dimension_external_db.pib_user_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_contract_dimension`, `fact_external_db.pib_account_hierarchy_fact`, `reference_external_db.pib_product_master`, `fact_external_db.tm1_fact`
- **SQL files:** [Churn Outputs and Explanations - Churn Output Analysis.sql](Churn%20Outputs%20and%20Explanations%20-%20Churn%20Output%20Analysis.sql), [Churn Outputs and Explanations - Churn Prediction Explanations.sql](Churn%20Outputs%20and%20Explanations%20-%20Churn%20Prediction%20Explanations.sql), [Churn Outputs and Explanations - Territories, Owners, Etc.sql](Churn%20Outputs%20and%20Explanations%20-%20Territories%2C%20Owners%2C%20Etc.sql), [Churn Outputs and Explanations - TM1 Revenue.sql](Churn%20Outputs%20and%20Explanations%20-%20TM1%20Revenue.sql)

## "Churn_Company_Filtered_Data_v2" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / zoolander_db)
- **Used by worksheets:** AoR Trend, AoR Trend (3), Company List Risk Scores, Custom Metric Trend, Link to User-Level Metrics, Metrics Tables, New Factiva Buckets, New Factiva Companies, New Factiva Companies Count, New Factiva Flag, Sheet 31, WPV Trend
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Churn_Company_Filtered_Data_v2.sql
```
- **Athena tables read:** `fact_external_db.omniture_event_fact`, `pib_event_data.pib_product_metrics`, `fact_external_db.pib_membership_fact`, `reference_external_db.pib_product_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_contract_dimension`, `fact_external_db.pib_account_hierarchy_fact`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_territory_dimension`, `reference_external_db.date_dimension`, `dimension_external_db.pib_membership_history`, `dimension_external_db.pib_contact_dimension_history`, `dimension_external_db.pib_alerts`, `fact_external_db.tm1_fact`, `dimension_external_db.pib_customer_service_case_dimension`, `dimension_external_db.pib_meeting_summary`, `dimension_external_db.pib_opportunity_dimension_history`, `dimension_external_db.pib_opportunity_dimension`, `dimension_external_db.pib_product_services_dimension`, `reference_external_db.fx_rates_current`, `dimension_external_db.pib_training_summary_dimension`
- **SQL files:** [Churn_Company_Filtered_Data_v2.sql](Churn_Company_Filtered_Data_v2.sql)

## "Churn_v2_Output_Analysis_History" (embedded)

- **Shape:** Standalone table
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / zoolander_db)
- **Used by worksheets:** Company List Risk Scores
- **Structure:**

```
- Athena table zoolander_db.churn_v2_output_analysis (as "churn_v2_output_an")
```
- **Athena tables read:** `zoolander_db.churn_v2_output_analysis`
- **SQL files:** _none -- Athena is read as plain table(s), no Custom SQL_
