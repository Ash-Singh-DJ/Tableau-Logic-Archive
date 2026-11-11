# B2B Deloitte Quarterly Report

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Sales / GAT |
| Owner | Maria Peco |
| Created | 2025-06-25 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/2931115 |
| Archived | 2026-11-11 |

## Summary

13 data source(s) in the workbook; 12 with an Athena component (12 embedded, 0 published).
Other data sources: "Work Days" (Google Drive Excel).

## "Active Users Athena" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Registered users
- **Structure:**

```
- Athena Custom SQL "custom_sql_query" -> Active Users Athena.sql
```
- **Athena tables read:** `fact_external_db.omniture_event_fact`, `dimension_external_db.pib_membership_dimension`, `reference_external_db.pib_product_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [Active Users Athena.sql](Active%20Users%20Athena.sql)

## "Registered in Month" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Registered Users, Registered Users in Month
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Registered in Month.sql
```
- **Athena tables read:** `google_sheets_db.saml_master_list_b2b_current`, `dimension_external_db.pib_membership_dimension`
- **SQL files:** [Registered in Month.sql](Registered%20in%20Month.sql)

## "RCFC_Registered in Month" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Registered Users (RCFC), Registered Users in Month (RCFC)
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> RCFC_Registered in Month.sql
```
- **Athena tables read:** `google_sheets_db.rcfc_access_code`, `google_sheets_db.saml_master_list_b2b_current`, `dimension_external_db.pib_membership_dimension`
- **SQL files:** [RCFC_Registered in Month.sql](RCFC_Registered%20in%20Month.sql)

## "Page Type" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** PVs Last Month, PVs MoM, PVs YoY, Page Type, Sh 68, Sheet 67, Sheet 77
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Page Type.sql
```
- **Athena tables read:** `fact_external_db.omniture_event_fact`, `fact_external_db.pib_membership_fact`, `reference_external_db.pib_product_master`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_contract_dimension`, `fact_external_db.pib_account_hierarchy_fact`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_territory_dimension`
- **SQL files:** [Page Type.sql](Page%20Type.sql)

## "First time Login users" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Sheet 56
- **Structure:**

```
- Athena Custom SQL "First Time Login" -> First time Login users.sql
```
- **Athena tables read:** `google_sheets_db.saml_master_list_b2b_current`, `fact_external_db.omniture_event_fact`, `dimension_external_db.pib_membership_dimension`
- **SQL files:** [First time Login users.sql](First%20time%20Login%20users.sql)

## "RCFC_First time Login users" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** 1st Time Active Users (RCFC)
- **Structure:**

```
- Athena Custom SQL "First Time Login" -> RCFC_First time Login users.sql
```
- **Athena tables read:** `google_sheets_db.rcfc_access_code`, `google_sheets_db.saml_master_list_b2b_current`, `fact_external_db.omniture_event_fact`, `dimension_external_db.pib_membership_dimension`
- **SQL files:** [RCFC_First time Login users.sql](RCFC_First%20time%20Login%20users.sql)

## "Registered Users Athena " (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Registered users
- **Structure:**

```
- Athena Custom SQL "custom_sql_query" -> Registered Users Athena.sql
```
- **Athena tables read:** `dimension_external_db.pib_membership_dimension`, `reference_external_db.pib_product_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [Registered Users Athena.sql](Registered%20Users%20Athena.sql)

## "Total Registered" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Registered Users, Registered Users in Month
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Total Registered.sql
```
- **Athena tables read:** `reference_external_db.date_dimension`, `dimension_external_db.pib_membership_history`, `google_sheets_db.saml_master_list_b2b_current`, `reference_external_db.pib_product_dimension`
- **SQL files:** [Total Registered.sql](Total%20Registered.sql)

## "RCFC_Total Registered" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Registered Users (RCFC), Registered Users in Month (RCFC)
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> RCFC_Total Registered.sql
```
- **Athena tables read:** `reference_external_db.date_dimension`, `dimension_external_db.pib_membership_history`, `google_sheets_db.saml_master_list_b2b_current`, `google_sheets_db.rcfc_access_code`
- **SQL files:** [RCFC_Total Registered.sql](RCFC_Total%20Registered.sql)

## "BB Report" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Avg Monthly Users, Daily Active Users, Max date, Monthly Active MTD, Monthly Active Users, Monthly Active YoY, Monthly Newly Active Users, PM MTD, PY MTD, Quarterly Active Users, Sheet 49, Sheet 55, Sheet 75, Users Chart, Yearly Active Users
- **Structure:**

```
- Athena Custom SQL "Active Days" -> BB Report.sql
```
- **Athena tables read:** `google_sheets_db.saml_master_list_b2b_current`, `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `fact_external_db.omniture_event_fact`
- **SQL files:** [BB Report.sql](BB%20Report.sql)

## "RCFC_BB Report" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Daily Active Users (RCFC), Max date (RCFC), Monthly Active MTD (RCFC), Monthly Active Users (RCFC), Monthly Active YoY (RCFC), PY MTD (RCFC), Quarterly Active Users (RCFC), Yearly Active Users (RCFC)
- **Structure:**

```
- Athena Custom SQL "Active Days" -> RCFC_BB Report.sql
```
- **Athena tables read:** `google_sheets_db.saml_master_list_b2b_current`, `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `google_sheets_db.rcfc_access_code`, `fact_external_db.omniture_event_fact`
- **SQL files:** [RCFC_BB Report.sql](RCFC_BB%20Report.sql)

## "Usage Athena" (embedded)

- **Shape:** Join of 3 tables -- Athena + BigQuery
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); BigQuery
- **Used by worksheets:** Breakdown, Breakdown user count, Company Breakdown, Factiva, Factiva (2), Factiva users, Last Month UUsers, Last Month Usage, MoM UUsers, MoM Usage, NP Breakdown, NP Table view, NP Test, NP Title breakdown, NP Title date, NP User breakdown, NewsPlus, Newsplus button, PV Title breakdown, Page breakdown, Page breakdown (2), RC Breakdown, RC Title breakdown, RC Title date, RC User breakdown, Registered users, RiskCenter, Sheet 1, Sheet 22, Sheet 40, Sheet 6, Sheet 8, Sheet 9, Table view, Table view (2), Table view (3), Table view Metrics, Table view active users, Test Active days, Test Active days (2), Text, Title breakdown, Title date, Title date users, Trend Line, Trend Line UU, UU Breakdown, Update, User Breakdown 2, User breakdown, User level Table view, YoY UUsers, YoY Usage
- **Structure:**

```
- LEFT JOIN on [usage_main].[pib_member_id] = [Cluster data].[eid]
  - INNER JOIN on [usage_main].[year_cal_week] = [fiscal_week lookup].[cal_week]
    - Athena Custom SQL "usage_main" -> Usage Athena - usage_main.sql
    - Athena Custom SQL "fiscal_week lookup" -> Usage Athena - fiscal_week lookup.sql
  - BigQuery Custom SQL "Cluster data"
```
- **Athena tables read:** `fact_external_db.omniture_event_fact`, `pib_event_data.pib_product_metrics`, `reference_external_db.pib_product_master`, `google_sheets_db.saml_master_list_b2b_current`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_territory_dimension`, `reference_external_db.country_reference`, `reference_external_db.date_dimension`
- **Non-Athena Custom SQL (not archived):** "Cluster data" (BigQuery)
- **SQL files:** [Usage Athena - usage_main.sql](Usage%20Athena%20-%20usage_main.sql), [Usage Athena - fiscal_week lookup.sql](Usage%20Athena%20-%20fiscal_week%20lookup.sql)
