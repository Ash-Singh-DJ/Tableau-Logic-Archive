# B2B New Factiva Usage Dashboard

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Product / Factiva |
| Owner | James Thomson |
| Created | 2025-06-06 |
| Last updated | 2026-10-27 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/2847018 |
| Archived | 2026-11-11 |

## Summary

22 data source(s) in the workbook; 22 with an Athena component (22 embedded, 0 published).

## "New Factiva" (embedded)

- **Shape:** Relationship model: 4 logical tables
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Active Days, Avg Interest no, Cohort Breakdown, Cohort Chart, Comp Break down Act, Corp Signals, Daily and Weekly, Digest Breakdown, Digest Daily Weekly, Digest Onbo, Digest Onbo (2), Digest Weekly, Digest unsubscribe, Email Alerts, Email User Count, Email enables, Interest Daily Weekly, Metrics Pivot, Onbo %, Onbo % (2), Pivot, Returning Users, Sheet 134, Sheet 139, Sheet 15, Sheet 161, Sheet 164, Sheet 165, Sheet 17, Sheet 18, Sheet 22, Sheet 3, Sheet 53, Sheet 55, Sheet 76, Table, Total Users, Total Users enabled Digest, Total Users enabled Interest, Trends, Trends (2), Trends (3), Trends (4), Trends (5), User Count1, User Count2
- **Structure:**

```
Logical table "Onboard"
  - Athena Custom SQL "Onboard" -> New Factiva - Onboard.sql
Logical table "Usage"
  - Athena Custom SQL "Main Metrics" -> New Factiva - Main Metrics.sql
Logical table "Digest"
  - Athena Custom SQL "Digest" -> New Factiva - Digest.sql
Logical table "Alerts"
  - Athena Custom SQL "Alerts" -> New Factiva - Alerts.sql
```

- **Relationships:**
  - "Usage" ↔ "Onboard" on `[EID] = [EID (Custom SQL Query) #1]`
  - "Usage" ↔ "Digest" on `[EID] = [EID (Custom SQL Query)]`
  - "Usage" ↔ "Alerts" on `[user_id] = [user_id (Custom SQL Query)]`
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `reference_external_db.date_dimension`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_territory_dimension`, `dimension_external_db.pib_alerts`
- **SQL files:** [New Factiva - Onboard.sql](New%20Factiva%20-%20Onboard.sql), [New Factiva - Main Metrics.sql](New%20Factiva%20-%20Main%20Metrics.sql), [New Factiva - Digest.sql](New%20Factiva%20-%20Digest.sql), [New Factiva - Alerts.sql](New%20Factiva%20-%20Alerts.sql)

## "Interests 2" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Avg chart, Int Add, N Interests, Number Users, Number of Interests Dist, Pct Activity, Pct Activity 2, Pct Activity 3, Sheet 34, Sheet 36, Sheet 37, Sheet 38, Sheet 40, Sheet 41, Sheet 41 (2), Sheet 49, Total Active Users
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Interests 2.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_membership_dimension`
- **SQL files:** [Interests 2.sql](Interests%202.sql)

## "Article Saves" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Avg Article Net Saves & Removes , Avg Article Removes, Avg Article Saves, Sheet 84, Sheet 85
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Article Saves.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_membership_dimension`, `reference_external_db.date_dimension`
- **SQL files:** [Article Saves.sql](Article%20Saves.sql)

## "Searches" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Sheet 13
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Searches.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_membership_dimension`
- **SQL files:** [Searches.sql](Searches.sql)

## "Content Language 2" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Sheet 74, Sheet 75 (2), Sheet 76, Sheet 77, Total Default Users, Total Engaged Users
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Content Language 2.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_membership_dimension`
- **SQL files:** [Content Language 2.sql](Content%20Language%202.sql)

## "Plat Pref2" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Pref1, Pref2
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Plat Pref2.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_membership_dimension`
- **SQL files:** [Plat Pref2.sql](Plat%20Pref2.sql)

## "Time Spent" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Time Spent by Section, Time Spent by Section (2)
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Time Spent.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [Time Spent.sql](Time%20Spent.sql)

## "Source Pages" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Enable Pie, Enable Table, Enable location, Enable vs Disable, SR Chart, SR Pie, SR Pie (2), SR Table, Sheet 147 (2), Sheet 150, Sheet 154, Source Table, Source Usage Chart, Source Usage Chart (2)
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Source Pages.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_membership_dimension`
- **SQL files:** [Source Pages.sql](Source%20Pages.sql)

## "Default Platform" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** NF Platform %, NF Platform % (2), NF Platform % (3), Sheet 123, Sheet 123 (2), Sheet 124, Sheet 124 (2), Sheet 124 (3), Txt
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Default Platform.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_membership_dimension`
- **SQL files:** [Default Platform.sql](Default%20Platform.sql)

## "Company Metrics" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Sheet 137, Sheet 137 (2), Sheet 137 (3), Sheet 138, Sheet 138 (2), Text
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Company Metrics.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_membership_dimension`
- **SQL files:** [Company Metrics.sql](Company%20Metrics.sql)

## "Digest Subs" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Digest Enable Pref
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Digest Subs.sql
```
- **Athena tables read:** `reference_external_db.date_dimension`, `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_membership_dimension`
- **SQL files:** [Digest Subs.sql](Digest%20Subs.sql)

## "Article Data" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Article Scroll Depth3, Article Views Treemap1, Article Views by Alert L, Article Views by Name, Article Views by Recommended, Article Views by Section1, Sheet 109, Sheet 135, Sheet 136, Sheet 160
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Article Data.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_membership_dimension`
- **SQL files:** [Article Data.sql](Article%20Data.sql)

## "Settings Data" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Comp Break down Act, Digest Weekly, Digest unsubscribe, Email enables, Lang Comp Breakdwon, Settings Origins, Sheet 54, Sheet 62, Total Page Views, Total Page Views (2), Total Page Views (3), Total Page Views Comp break down
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Settings Data.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_membership_dimension`
- **SQL files:** [Settings Data.sql](Settings%20Data.sql)

## "Corp Signals" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Sheet 23
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Corp Signals.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_membership_dimension`
- **SQL files:** [Corp Signals.sql](Corp%20Signals.sql)

## "Home" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Home Page Views, Home Page Views (2), Home Search Depth, Sheet 111, Table Home
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Home.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_membership_dimension`
- **SQL files:** [Home.sql](Home.sql)

## "Industry" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Industry Table, Search depth, Sheet 98, Top Companies, Top Industry
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Industry.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_membership_dimension`
- **SQL files:** [Industry.sql](Industry.sql)

## "Article Views" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Article Table, Article Views
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Article Views.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_membership_dimension`
- **SQL files:** [Article Views.sql](Article%20Views.sql)

## "Interests" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Sheet 116, Sheet 117, Sheet 33
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Interests.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_membership_dimension`
- **SQL files:** [Interests.sql](Interests.sql)

## "SRE Subscribers" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Sheet 156
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> SRE Subscribers.sql
```
- **Athena tables read:** `dimension_external_db.pib_alerts`
- **SQL files:** [SRE Subscribers.sql](SRE%20Subscribers.sql)

## "Top Hat" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Support Clicks, Top Hat Clicks
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Top Hat.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_membership_dimension`
- **SQL files:** [Top Hat.sql](Top%20Hat.sql)

## "Analyst Reports" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Analyst reports, Avg Scroll depth, Avg Scroll depth %, Sheet 89 (2), Sheet 90, Sheet 91, Sheet 91 (2), Sheet 97, Table Analyst reports
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Analyst Reports.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_membership_dimension`
- **SQL files:** [Analyst Reports.sql](Analyst%20Reports.sql)

## "SRE open rates" (embedded)

- **Shape:** Join of 2 tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Used by worksheets:** Open Rate
- **Structure:**

```
- LEFT JOIN on [Custom SQL Query].[ymd] = [Sheet1].[Delivery Date]
  - Athena Custom SQL "Custom SQL Query" -> SRE open rates.sql
  - Google Drive Excel "Delivery Dates v2" table Sheet1$ (as "Sheet1")
```
- **Athena tables read:** `pib.email_open_rates`, `dimension_external_db.pib_alerts`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_territory_dimension`, `dimension_external_db.pib_user_dimension`
- **SQL files:** [SRE open rates.sql](SRE%20open%20rates.sql)
