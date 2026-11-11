# B2B Factiva Business Metrics: Registered and Active Users

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Product / Factiva |
| Owner | James Thomson |
| Created | 2025-09-14 |
| Last updated | 2026-10-07 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/3323212 |
| Archived | 2026-11-11 |

## Summary

4 data source(s) in the workbook; 4 with an Athena component (0 embedded, 4 published).

## "First time Login users" (published data source)

- **Published source:** "B2B Factiva Business Metrics: Registered and Active Users - First time Login users" in `B2B / B2B Product / Factiva / Datasources`, owner James Thomson; [archived here](../Datasources/B2B%20Factiva%20Business%20Metrics...sers%20-%20First%20time%20Login%20users). The SQL below is copied from it.
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

## "Total Registered" (published data source)

- **Published source:** "B2B Factiva Business Metrics Registered and Active Users - Total Registered" in `B2B / B2B Product / Factiva / Datasources`, owner James Thomson; [archived here](../Datasources/B2B%20Factiva%20Business%20Metrics...tive%20Users%20-%20Total%20Registered). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Company Table, MoM, Registered Users, Registered Users (2), Registered Users YoY, Table MAUs, YYoy, YoY, table
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Total Registered.sql
```
- **Athena tables read:** `reference_external_db.date_dimension`, `dimension_external_db.pib_membership_history`, `google_sheets_db.saml_master_list_b2b_current`, `reference_external_db.pib_product_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [Total Registered.sql](Total%20Registered.sql)

## "Registered in Month" (published data source)

- **Published source:** "B2B Factiva Business Metrics Registered and Active Users - Registered in Month" in `B2B / B2B Product / Factiva / Datasources`, owner James Thomson; [archived here](../Datasources/B2B%20Factiva%20Business%20Metrics...e%20Users%20-%20Registered%20in%20Month). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Last month 2, MTD, MTD (2), Registered Users in Month, Registered Users in Month (2), Sheet 103
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Registered in Month.sql
```
- **Athena tables read:** `google_sheets_db.saml_master_list_b2b_current`, `dimension_external_db.pib_membership_dimension`
- **SQL files:** [Registered in Month.sql](Registered%20in%20Month.sql)

## "BB Report" (published data source)

- **Published source:** "B2B Factiva Business Metrics: Registered and Active Users - BB Report" in `B2B / B2B Product / Factiva / Datasources`, owner James Thomson; [archived here](../Datasources/B2B%20Factiva%20Business%20Metrics...and%20Active%20Users%20-%20BB%20Report). The SQL below is copied from it.
- **Shape:** Relationship model: 2 logical tables (with joins inside) -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Used by worksheets:** Avg Monthly Users, Daily Active Users, Max date, Monthly Active MTD, Monthly Active Users, Monthly Active YoY, Monthly Active YoY (2), Monthly Newly Active Users, PM MTD, PY MTD, Quarterly Active Users, Sheet 104, Sheet 105, Sheet 49, Sheet 55, Sheet 75, Sheet 99, Table MAUs, Title, Users Chart, Yearly Active Users
- **Structure:**

```
Logical table "Sheet1"
  - Google Drive Excel "Industry Mapping" table Sheet1$ (as "INDUSTRY MAPPING")
Logical table "Custom SQL Query"
  - LEFT JOIN on [Active Days].[billing_account_id] = [Reg in month].[billing_account_id] AND STR([Active Days].[year_month_day]) = [Reg in month].[year_month]
    - Athena Custom SQL "Active Days" -> BB Report - Active Days.sql
    - Athena Custom SQL "Reg in month" -> BB Report - Reg in month.sql
```

- **Relationships:**
  - "Custom SQL Query" ↔ "Sheet1" on `UPPER([company_industry]) = [SFDC Industry]`
- **Athena tables read:** `google_sheets_db.saml_master_list_b2b_current`, `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `fact_external_db.omniture_event_fact`
- **SQL files:** [BB Report - Active Days.sql](BB%20Report%20-%20Active%20Days.sql), [BB Report - Reg in month.sql](BB%20Report%20-%20Reg%20in%20month.sql)
