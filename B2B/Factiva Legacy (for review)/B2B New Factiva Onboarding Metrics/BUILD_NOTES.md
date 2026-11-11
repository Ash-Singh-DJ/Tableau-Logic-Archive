# B2B New Factiva Onboarding Metrics

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / Factiva Legacy (for review) |
| Owner | Maria Peco |
| Created | 2025-07-28 |
| Last updated | 2026-01-12 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/3087682 |
| Archived | 2026-11-11 |

## Summary

22 data source(s) in the workbook; 22 with an Athena component (0 embedded, 22 published).

## "B2B New Factiva Onboarding Top Hat" (published data source)

- **Published source:** "B2B New Factiva Onboarding Metrics - Top Hat" in `B2B / B2B Product / Factiva / Datasources / B2B New Factiva Onboarding Data Sources`, owner Maria Peco; [archived here](../../B2B%20Product/Factiva/Datasources/B2B%20New%20Factiva%20Onboarding%20Data%20Sources/B2B%20New%20Factiva%20Onboarding%20Metrics%20-%20Top%20Hat). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Support Clicks, Top Hat Clicks
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> B2B New Factiva Onboarding Top Hat.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_membership_dimension`
- **SQL files:** [B2B New Factiva Onboarding Top Hat.sql](B2B%20New%20Factiva%20Onboarding%20Top%20Hat.sql)

## "Article Saves" (published data source)

- **Published source:** "B2B New Factiva Onboarding Metrics - Article Saves" in `B2B / B2B Product / Factiva / Datasources / B2B New Factiva Onboarding Data Sources`, owner Maria Peco; [archived here](../../B2B%20Product/Factiva/Datasources/B2B%20New%20Factiva%20Onboarding%20Data%20Sources/B2B%20New%20Factiva%20Onboarding%20Metrics%20-%20Article%20Saves). The SQL below is copied from it.
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

## "B2B New Factiva Onboarding Interests 2" (published data source)

- **Published source:** "B2B New Factiva Onboarding Metrics - Interests 2" in `B2B / B2B Product / Factiva / Datasources / B2B New Factiva Onboarding Data Sources`, owner Maria Peco; [archived here](../../B2B%20Product/Factiva/Datasources/B2B%20New%20Factiva%20Onboarding%20Data%20Sources/B2B%20New%20Factiva%20Onboarding%20Metrics%20-%20Interests%202). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Avg chart, Int Add, N Interests, Number Users, Number of Interests Dist, Pct Activity, Pct Activity 2, Pct Activity 3, Sheet 34, Sheet 36, Sheet 37, Sheet 38, Sheet 40, Sheet 41, Sheet 41 (2), Sheet 49, Total Active Users
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> B2B New Factiva Onboarding Interests 2.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_membership_dimension`
- **SQL files:** [B2B New Factiva Onboarding Interests 2.sql](B2B%20New%20Factiva%20Onboarding%20Interests%202.sql)

## "B2B New Factiva Onboarding Corp Signals" (published data source)

- **Published source:** "B2B New Factiva Onboarding Metrics - Corp Signals" in `B2B / B2B Product / Factiva / Datasources / B2B New Factiva Onboarding Data Sources`, owner Maria Peco; [archived here](../../B2B%20Product/Factiva/Datasources/B2B%20New%20Factiva%20Onboarding%20Data%20Sources/B2B%20New%20Factiva%20Onboarding%20Metrics%20-%20Corp%20Signals). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Sheet 23
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> B2B New Factiva Onboarding Corp Signals.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_membership_dimension`
- **SQL files:** [B2B New Factiva Onboarding Corp Signals.sql](B2B%20New%20Factiva%20Onboarding%20Corp%20Signals.sql)

## "B2B New Factiva Onboarding Article Data" (published data source)

- **Published source:** "B2B New Factiva Onboarding Metrics - Article Data" in `B2B / B2B Product / Factiva / Datasources / B2B New Factiva Onboarding Data Sources`, owner Maria Peco; [archived here](../../B2B%20Product/Factiva/Datasources/B2B%20New%20Factiva%20Onboarding%20Data%20Sources/B2B%20New%20Factiva%20Onboarding%20Metrics%20-%20Article%20Data). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Article Scroll Depth3, Article Views Treemap1, Article Views by Alert L, Article Views by Name, Article Views by Recommended, Article Views by Section1, Sheet 109, Sheet 135, Sheet 136, Sheet 160
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> B2B New Factiva Onboarding Article Data.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_membership_dimension`
- **SQL files:** [B2B New Factiva Onboarding Article Data.sql](B2B%20New%20Factiva%20Onboarding%20Article%20Data.sql)

## "B2B New Factiva Onboarding Industry" (published data source)

- **Published source:** "B2B New Factiva Onboarding Metrics - Industry" in `B2B / B2B Product / Factiva / Datasources / B2B New Factiva Onboarding Data Sources`, owner Maria Peco; [archived here](../../B2B%20Product/Factiva/Datasources/B2B%20New%20Factiva%20Onboarding%20Data%20Sources/B2B%20New%20Factiva%20Onboarding%20Metrics%20-%20Industry). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Industry Table, Search depth, Sheet 98, Top Companies, Top Industry
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> B2B New Factiva Onboarding Industry.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_membership_dimension`
- **SQL files:** [B2B New Factiva Onboarding Industry.sql](B2B%20New%20Factiva%20Onboarding%20Industry.sql)

## "B2B New Factiva Onboarding Content Language 2" (published data source)

- **Published source:** "B2B New Factiva Onboarding Metrics - Content Language 2" in `B2B / B2B Product / Factiva / Datasources / B2B New Factiva Onboarding Data Sources`, owner Maria Peco; [archived here](../../B2B%20Product/Factiva/Datasources/B2B%20New%20Factiva%20Onboarding%20Data%20Sources/B2B%20New%20Factiva%20Onboarding%20Metrics%20-%20Content%20Language%202). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Sheet 74, Sheet 75 (2), Sheet 76, Sheet 77, Total Default Users, Total Engaged Users
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> B2B New Factiva Onboarding Content Language 2.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_membership_dimension`
- **SQL files:** [B2B New Factiva Onboarding Content Language 2.sql](B2B%20New%20Factiva%20Onboarding%20Content%20Language%202.sql)

## "B2B New Factiva Onboarding Company Metrics" (published data source)

- **Published source:** "B2B New Factiva Onboarding Metrics - Company Metrics" in `B2B / B2B Product / Factiva / Datasources / B2B New Factiva Onboarding Data Sources`, owner Maria Peco; [archived here](../../B2B%20Product/Factiva/Datasources/B2B%20New%20Factiva%20Onboarding%20Data%20Sources/B2B%20New%20Factiva%20Onboarding%20Metrics%20-%20Company%20Metrics). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Sheet 137, Sheet 137 (2), Sheet 137 (3), Sheet 138, Sheet 138 (2), Text
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> B2B New Factiva Onboarding Company Metrics.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_membership_dimension`
- **SQL files:** [B2B New Factiva Onboarding Company Metrics.sql](B2B%20New%20Factiva%20Onboarding%20Company%20Metrics.sql)

## "B2B New Factiva Onboarding New Factiva" (published data source)

- **Published source:** "B2B New Factiva Onboarding Metrics - New Factiva" in `B2B / B2B Product / Factiva / Datasources / B2B New Factiva Onboarding Data Sources`, owner Maria Peco; [archived here](../../B2B%20Product/Factiva/Datasources/B2B%20New%20Factiva%20Onboarding%20Data%20Sources/B2B%20New%20Factiva%20Onboarding%20Metrics%20-%20New%20Factiva). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Active Days, Avg Interest no, Cohort Breakdown, Cohort Chart, Comp Break down Act, Corp Signals, Daily and Weekly, Digest Breakdown, Digest Daily Weekly, Digest Onbo, Digest Onbo (2), Digest Weekly, Digest unsubscribe, Email Alerts, Email User Count, Email enables, Interest Daily Weekly, Metrics Pivot, Onbo %, Onbo % (2), Onbo % (3), Overall Numbers, Overall Table, Overall Table (2), Pivot, Returning Users, Sheet 134, Sheet 139, Sheet 15, Sheet 161, Sheet 17, Sheet 18, Sheet 22, Sheet 3, Sheet 53, Sheet 55, Sheet 76, Table, Total Users, Total Users enabled Digest, Total Users enabled Interest, Trends, Trends (2), Trends (3), Trends (4), Trends (5), User Count1, User Count2
- **Structure:**

```
- Athena Custom SQL "Main Metrics" -> B2B New Factiva Onboarding New Factiva.sql
```
- **Athena tables read:** `dimension_external_db.pib_membership_dimension`, `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_territory_dimension`
- **SQL files:** [B2B New Factiva Onboarding New Factiva.sql](B2B%20New%20Factiva%20Onboarding%20New%20Factiva.sql)

## "B2B New Factiva Onboarding Settings Data" (published data source)

- **Published source:** "B2B New Factiva Onboarding Metrics - Settings Data" in `B2B / B2B Product / Factiva / Datasources / B2B New Factiva Onboarding Data Sources`, owner Maria Peco; [archived here](../../B2B%20Product/Factiva/Datasources/B2B%20New%20Factiva%20Onboarding%20Data%20Sources/B2B%20New%20Factiva%20Onboarding%20Metrics%20-%20Settings%20Data). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Comp Break down Act, Digest Weekly, Digest unsubscribe, Email enables, Lang Comp Breakdwon, Settings Origins, Sheet 54, Sheet 62, Total Page Views, Total Page Views (2), Total Page Views (3), Total Page Views Comp break down
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> B2B New Factiva Onboarding Settings Data.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_membership_dimension`
- **SQL files:** [B2B New Factiva Onboarding Settings Data.sql](B2B%20New%20Factiva%20Onboarding%20Settings%20Data.sql)

## "B2B New Factiva Onboarding Interests" (published data source)

- **Published source:** "B2B New Factiva Onboarding Metrics - Interests" in `B2B / B2B Product / Factiva / Datasources / B2B New Factiva Onboarding Data Sources`, owner Maria Peco; [archived here](../../B2B%20Product/Factiva/Datasources/B2B%20New%20Factiva%20Onboarding%20Data%20Sources/B2B%20New%20Factiva%20Onboarding%20Metrics%20-%20Interests). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Sheet 116, Sheet 117, Sheet 33
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> B2B New Factiva Onboarding Interests.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_membership_dimension`
- **SQL files:** [B2B New Factiva Onboarding Interests.sql](B2B%20New%20Factiva%20Onboarding%20Interests.sql)

## "B2B New Factiva Onboarding Article Views" (published data source)

- **Published source:** "B2B New Factiva Onboarding Metrics - Article Views" in `B2B / B2B Product / Factiva / Datasources / B2B New Factiva Onboarding Data Sources`, owner Maria Peco; [archived here](../../B2B%20Product/Factiva/Datasources/B2B%20New%20Factiva%20Onboarding%20Data%20Sources/B2B%20New%20Factiva%20Onboarding%20Metrics%20-%20Article%20Views). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Article Table, Article Views
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> B2B New Factiva Onboarding Article Views.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_membership_dimension`
- **SQL files:** [B2B New Factiva Onboarding Article Views.sql](B2B%20New%20Factiva%20Onboarding%20Article%20Views.sql)

## "B2B New Factiva Onboarding SRE open rates" (published data source)

- **Published source:** "B2B New Factiva Onboarding Metrics - SRE open rates" in `B2B / B2B Product / Factiva / Datasources / B2B New Factiva Onboarding Data Sources`, owner Maria Peco; [archived here](../../B2B%20Product/Factiva/Datasources/B2B%20New%20Factiva%20Onboarding%20Data%20Sources/B2B%20New%20Factiva%20Onboarding%20Metrics%20-%20SRE%20open%20rates). The SQL below is copied from it.
- **Shape:** Relationship model: 2 logical tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Used by worksheets:** Open Rate
- **Structure:**

```
Logical table "Sheet1"
  - Google Drive Excel "Delivery Dates" table Sheet1$ (as "Sheet1")
Logical table "Custom SQL Query"
  - Athena Custom SQL "Custom SQL Query" -> B2B New Factiva Onboarding SRE open rates.sql
```

- **Relationships:**
  - "Custom SQL Query" ↔ "Sheet1" on `[ymd] = [Delivery Date]`
- **Athena tables read:** `pib.email_open_rates`, `dimension_external_db.pib_alerts`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_territory_dimension`, `dimension_external_db.pib_user_dimension`
- **SQL files:** [B2B New Factiva Onboarding SRE open rates.sql](B2B%20New%20Factiva%20Onboarding%20SRE%20open%20rates.sql)

## "B2B New Factiva Onboarding Source Pages" (published data source)

- **Published source:** "B2B New Factiva Onboarding Metrics - Source Pages" in `B2B / B2B Product / Factiva / Datasources / B2B New Factiva Onboarding Data Sources`, owner Maria Peco; [archived here](../../B2B%20Product/Factiva/Datasources/B2B%20New%20Factiva%20Onboarding%20Data%20Sources/B2B%20New%20Factiva%20Onboarding%20Metrics%20-%20Source%20Pages). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Enable Pie, Enable Table, Enable location, Enable vs Disable, SR Chart, SR Pie, SR Pie (2), SR Table, Sheet 147 (2), Sheet 150, Sheet 154, Source Table, Source Usage Chart, Source Usage Chart (2)
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> B2B New Factiva Onboarding Source Pages.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_membership_dimension`
- **SQL files:** [B2B New Factiva Onboarding Source Pages.sql](B2B%20New%20Factiva%20Onboarding%20Source%20Pages.sql)

## "B2B New Factiva Onboarding Default Platform" (published data source)

- **Published source:** "B2B New Factiva Onboarding Metrics - Default Platform" in `B2B / B2B Product / Factiva / Datasources / B2B New Factiva Onboarding Data Sources`, owner Maria Peco; [archived here](../../B2B%20Product/Factiva/Datasources/B2B%20New%20Factiva%20Onboarding%20Data%20Sources/B2B%20New%20Factiva%20Onboarding%20Metrics%20-%20Default%20Platform). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** NF Platform %, NF Platform % (2), NF Platform % (3), Sheet 123, Sheet 123 (2), Sheet 124, Sheet 124 (2), Sheet 124 (3), Txt
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> B2B New Factiva Onboarding Default Platform.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_membership_dimension`
- **SQL files:** [B2B New Factiva Onboarding Default Platform.sql](B2B%20New%20Factiva%20Onboarding%20Default%20Platform.sql)

## "B2B New Factiva Onboarding Searches" (published data source)

- **Published source:** "B2B New Factiva Onboarding Metrics - Searches" in `B2B / B2B Product / Factiva / Datasources / B2B New Factiva Onboarding Data Sources`, owner Maria Peco; [archived here](../../B2B%20Product/Factiva/Datasources/B2B%20New%20Factiva%20Onboarding%20Data%20Sources/B2B%20New%20Factiva%20Onboarding%20Metrics%20-%20Searches). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Sheet 13
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> B2B New Factiva Onboarding Searches.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_membership_dimension`
- **SQL files:** [B2B New Factiva Onboarding Searches.sql](B2B%20New%20Factiva%20Onboarding%20Searches.sql)

## "B2B New Factiva Onboarding SRE Subscribers" (published data source)

- **Published source:** "B2B New Factiva Onboarding Metrics - SRE Subscribers" in `B2B / B2B Product / Factiva / Datasources / B2B New Factiva Onboarding Data Sources`, owner Maria Peco; [archived here](../../B2B%20Product/Factiva/Datasources/B2B%20New%20Factiva%20Onboarding%20Data%20Sources/B2B%20New%20Factiva%20Onboarding%20Metrics%20-%20SRE%20Subscribers). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Sheet 156
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> B2B New Factiva Onboarding SRE Subscribers.sql
```
- **Athena tables read:** `dimension_external_db.pib_alerts`
- **SQL files:** [B2B New Factiva Onboarding SRE Subscribers.sql](B2B%20New%20Factiva%20Onboarding%20SRE%20Subscribers.sql)

## "B2B New Factiva Onboarding Metrics Analyst Reports" (published data source)

- **Published source:** "B2B New Factiva Onboarding Metrics - Analyst Reports" in `B2B / B2B Product / Factiva / Datasources / B2B New Factiva Onboarding Data Sources`, owner Maria Peco; [archived here](../../B2B%20Product/Factiva/Datasources/B2B%20New%20Factiva%20Onboarding%20Data%20Sources/B2B%20New%20Factiva%20Onboarding%20Metrics%20-%20Analyst%20Reports). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Analyst reports, Avg Scroll depth, Avg Scroll depth %, Sheet 89 (2), Sheet 90, Sheet 91, Sheet 91 (2), Sheet 97, Table Analyst reports
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> B2B New Factiva Onboarding Metrics Analyst Reports.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_membership_dimension`
- **SQL files:** [B2B New Factiva Onboarding Metrics Analyst Reports.sql](B2B%20New%20Factiva%20Onboarding%20Metrics%20Analyst%20Reports.sql)

## "B2B New Factiva Onboarding Home" (published data source)

- **Published source:** "B2B New Factiva Onboarding Metrics - Home" in `B2B / B2B Product / Factiva / Datasources / B2B New Factiva Onboarding Data Sources`, owner Maria Peco; [archived here](../../B2B%20Product/Factiva/Datasources/B2B%20New%20Factiva%20Onboarding%20Data%20Sources/B2B%20New%20Factiva%20Onboarding%20Metrics%20-%20Home). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Home Page Views, Home Page Views (2), Home Search Depth, Sheet 111, Table Home
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> B2B New Factiva Onboarding Home.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_membership_dimension`
- **SQL files:** [B2B New Factiva Onboarding Home.sql](B2B%20New%20Factiva%20Onboarding%20Home.sql)

## "B2B New Factiva Onboarding Digest Subs" (published data source)

- **Published source:** "B2B New Factiva Onboarding Metrics - Digest Subs" in `B2B / B2B Product / Factiva / Datasources / B2B New Factiva Onboarding Data Sources`, owner Maria Peco; [archived here](../../B2B%20Product/Factiva/Datasources/B2B%20New%20Factiva%20Onboarding%20Data%20Sources/B2B%20New%20Factiva%20Onboarding%20Metrics%20-%20Digest%20Subs). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Digest Enable Pref
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> B2B New Factiva Onboarding Digest Subs.sql
```
- **Athena tables read:** `reference_external_db.date_dimension`, `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_membership_dimension`
- **SQL files:** [B2B New Factiva Onboarding Digest Subs.sql](B2B%20New%20Factiva%20Onboarding%20Digest%20Subs.sql)

## "B2B New Factiva Onboarding Plat Pref2" (published data source)

- **Published source:** "B2B New Factiva Onboarding Metrics - Plat Pref2" in `B2B / B2B Product / Factiva / Datasources / B2B New Factiva Onboarding Data Sources`, owner Maria Peco; [archived here](../../B2B%20Product/Factiva/Datasources/B2B%20New%20Factiva%20Onboarding%20Data%20Sources/B2B%20New%20Factiva%20Onboarding%20Metrics%20-%20Plat%20Pref2). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Pref1, Pref2
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> B2B New Factiva Onboarding Plat Pref2.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_membership_dimension`
- **SQL files:** [B2B New Factiva Onboarding Plat Pref2.sql](B2B%20New%20Factiva%20Onboarding%20Plat%20Pref2.sql)

## "B2B New Factiva Onboarding Time Spent" (published data source)

- **Published source:** "B2B New Factiva Onboarding Metrics - Time Spent" in `B2B / B2B Product / Factiva / Datasources / B2B New Factiva Onboarding Data Sources`, owner Maria Peco; [archived here](../../B2B%20Product/Factiva/Datasources/B2B%20New%20Factiva%20Onboarding%20Data%20Sources/B2B%20New%20Factiva%20Onboarding%20Metrics%20-%20Time%20Spent). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Time Spent by Section, Time Spent by Section (2)
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> B2B New Factiva Onboarding Time Spent.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [B2B New Factiva Onboarding Time Spent.sql](B2B%20New%20Factiva%20Onboarding%20Time%20Spent.sql)
