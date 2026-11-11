# B2B BBC Usage Report

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Sales / GAT |
| Owner | Shirley Chu |
| Created | 2025-06-13 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/2878826 |
| Archived | 2026-11-11 |

## Summary

7 data source(s) in the workbook; 7 with an Athena component (7 embedded, 0 published).

## "Active_Days" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / adtech_dash_reimagine)
- **Used by worksheets:** Frequency, Frequency (2), traffic
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Active_Days.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`
- **SQL files:** [Active_Days.sql](Active_Days.sql)

## "Register User" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / abc_matrix)
- **Used by worksheets:** Reg vs Act
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Register User.sql
```
- **Athena tables read:** `reference_external_db.date_dimension`, `dimension_external_db.pib_membership_history`, `reference_external_db.pib_product_dimension`
- **SQL files:** [Register User.sql](Register%20User.sql)

## "Classic Factiva Top Sources" (embedded)

- **Shape:** Join of 3 tables
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / sandbox_mk)
- **Used by worksheets:** Pivot (External)
- **Structure:**

```
- LEFT JOIN on [omnit_user_source_usage].[pib_member_id] = [User Seg].[eid]
  - LEFT JOIN on [omnit_user_source_usage].[Source_code] = [SourceInfo].[SourceCode]
    - Athena Custom SQL "omnit_user_source_usage" -> Classic Factiva Top Sources - omnit_user_source_usage.sql
    - Athena Custom SQL "SourceInfo" -> Classic Factiva Top Sources - SourceInfo.sql
  - Athena Custom SQL "User Seg" -> Classic Factiva Top Sources - User Seg.sql
```
- **Athena tables read:** `fact_external_db.omniture_event_fact`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `reference_external_db.pib_product_dimension`, `dimension_external_db.pib_territory_dimension`, `reference_external_db.country_reference`, `sandbox_mk.factiva_content_source_current`, `sandbox_mk.factiva_content_source_group_current`, `sandbox_mk.full_roo_table`, `sandbox_mk.factiva_user_seg_12mo`
- **SQL files:** [Classic Factiva Top Sources - omnit_user_source_usage.sql](Classic%20Factiva%20Top%20Sources%20-%20omnit_user_source_usage.sql), [Classic Factiva Top Sources - SourceInfo.sql](Classic%20Factiva%20Top%20Sources%20-%20SourceInfo.sql), [Classic Factiva Top Sources - User Seg.sql](Classic%20Factiva%20Top%20Sources%20-%20User%20Seg.sql)

## "Search Draft" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** USER BEHAVIORS (brief)
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Search Draft.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [Search Draft.sql](Search%20Draft.sql)

## "Factiva User" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / abc_matrix)
- **Used by worksheets:** Reg vs Act
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Factiva User.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `fact_external_db.omniture_event_fact`
- **SQL files:** [Factiva User.sql](Factiva%20User.sql)

## "open rates email" (embedded)

- **Shape:** Join of 2 tables
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Alert Folder
- **Structure:**

```
- LEFT JOIN on [Custom SQL Query].[nlid] = [NLID].[nlid]
  - Athena Custom SQL "Custom SQL Query" -> open rates email - Custom SQL Query.sql
  - Athena Custom SQL "NLID" -> open rates email - NLID.sql
```
- **Athena tables read:** `fact_external_db.omniture_event_fact`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `pib_event_data.pib_product_metrics`, `pib.email_open_rates`, `dimension_external_db.pib_alerts`, `dimension_external_db.pib_territory_dimension`, `dimension_external_db.pib_user_dimension`
- **SQL files:** [open rates email - Custom SQL Query.sql](open%20rates%20email%20-%20Custom%20SQL%20Query.sql), [open rates email - NLID.sql](open%20rates%20email%20-%20NLID.sql)

## "Usage Athena" (embedded)

- **Shape:** Join of 3 tables -- Athena + BigQuery
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); BigQuery
- **Used by worksheets:** traffic
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
