# B2B True North Metrics

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Product |
| Owner | James Thomson |
| Created | 2025-09-16 |
| Last updated | 2026-10-08 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/3332393 |
| Archived | 2026-11-11 |

## Summary

25 data source(s) in the workbook; 18 with an Athena component (0 embedded, 18 published).
Other data sources: "Sheet1 (NF Onboard Rates)" (published); "Uptime R&C" (published); "NewsPlus NPS Pendo" (published); "MW Parsley" (published); "DJN Item Count JT" (published); "Factset2" (published); "Uptime Factiva" (published).

## "New Factiva" (published data source)

- **Published source:** "B2B True North - New Factiva" in `B2B / B2B Product / Data sources / True North Metrics Data Sources`, owner James Thomson; [archived here](../Data%20sources/True%20North%20Metrics%20Data%20Sources/B2B%20True%20North%20-%20New%20Factiva). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Onbo % (3), Overall Table (2)
- **Structure:**

```
- Athena Custom SQL "Main Metrics" -> New Factiva.sql
```
- **Athena tables read:** `reference_external_db.date_dimension`, `pib_event_data.pib_product_metrics`
- **SQL files:** [New Factiva.sql](New%20Factiva.sql)

## "Reg Users" (published data source)

- **Published source:** "B2B True North - Reg Users" in `B2B / B2B Product / Data sources / True North Metrics Data Sources`, owner Maria Peco; [archived here](../Data%20sources/True%20North%20Metrics%20Data%20Sources/B2B%20True%20North%20-%20Reg%20Users). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Reg Users, Sheet 105
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Reg Users.sql
```
- **Athena tables read:** `dimension_external_db.pib_membership_dimension`
- **SQL files:** [Reg Users.sql](Reg%20Users.sql)

## "SmartSummaryTN" (published data source)

- **Published source:** "B2B True North - SmartSummaryTN" in `B2B / B2B Product / Data sources / True North Metrics Data Sources`, owner James Thomson; [archived here](../Data%20sources/True%20North%20Metrics%20Data%20Sources/B2B%20True%20North%20-%20SmartSummaryTN). The SQL below is copied from it.
- **Shape:** Join of 2 tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Used by worksheets:** Smart Summary, Smart Summary (2), Smart Summary (3), Smart Summary Expanded, Table
- **Structure:**

```
- LEFT JOIN on [Custom SQL Query].[pib_member_id] = [Exclude].[EID] AND [Custom SQL Query].[year_month] = [Exclude].[Month]
  - Athena Custom SQL "Custom SQL Query" -> SmartSummaryTN.sql
  - Google Drive Excel "Power Searchers" table Sheet1$ (as "Exclude")
```
- **Athena tables read:** `reference_external_db.date_dimension`, `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [SmartSummaryTN.sql](SmartSummaryTN.sql)

## "Factiva Weekly retention." (published data source)

- **Published source:** "Factiva Weekly retention." in `B2B / B2B Product / Factiva`, owner James Thomson; [archived here](../Factiva/Factiva%20Weekly%20retention). The SQL below is copied from it.
- **Shape:** Join of 2 tables
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / reference_external_db)
- **Used by worksheets:** CF + NF Monthly Retention Numbers , CF + NF Monthly Retention rate %
- **Structure:**

```
- LEFT JOIN on [Custom SQL Query].[plan_id] = [pib_product_dimens].[access_code]
  - Athena Custom SQL "Custom SQL Query" -> Factiva Weekly retention.sql
  - Athena table reference_external_db.pib_product_dimension (as "pib_product_dimens")
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_corporate_dimension`, `dimension_external_db.pib_territory_dimension`, `dimension_external_db.pib_user_dimension`, `reference_external_db.pib_product_dimension`
- **SQL files:** [Factiva Weekly retention.sql](Factiva%20Weekly%20retention.sql)

## "R&C and NP Active Users " (published data source)

- **Published source:** "B2B True North - R&C and NP Active Users" in `B2B / B2B Product / Data sources / True North Metrics Data Sources`, owner James Thomson; [archived here](../Data%20sources/True%20North%20Metrics%20Data%20Sources/B2B%20True%20North%20-%20R%26C%20and%20NP%20Active%20Users). The SQL below is copied from it.
- **Shape:** Join of 2 tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Used by worksheets:** Latest Month NP, Latest Month R&C, Latest Month Yom, MAU Breakdown, NP Last 30 days, NP Last 30 days (2), NP Latest Month Pct, NP MAUs, NP MAUs (2), NP Prev day, NP WAU, New Latest Month NP (2), New NP Last 30 days (3), New NP MAUs (3), New NP Prev day (2), New NP WAU, New Weekly NP, Newsplus Active 2, R&C Latest Month Pct, R&C MAUs, R&C WAU, RCFC Active, RiskJournal Active, Sheet 206, Sheet 209 (2), Sheet 210, WAU / MAU %, WAU / MAU Table, WAU / MAU Table (2), WAU / MAU Table (3), WAU / MAU Table (4), WAU Breakdown , WAU Pct NP change, WAU Pct RC change, Weekly NP, Weekly NP (2), Weekly R&C, Weekly R&C (2), Weekly R&C (3), Yom  WAU, Yom MAUs, Yom PVs, Yom Prev day, Yom by comp, Yomuri Active 2, Yomuri Last 30 days
- **Structure:**

```
- LEFT JOIN on [Custom SQL Query].[year_month_day] = STR([Day Lookup].[Date])
  - Athena Custom SQL "Custom SQL Query" -> R&C and NP Active Users.sql
  - Google Drive Excel "Day lookup" table Sheet1$ (as "Day Lookup")
```
- **Athena tables read:** `reference_external_db.date_dimension`, `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `fact_external_db.omniture_event_fact`, `fact_external_db.omniture_event_fact_hourly`
- **SQL files:** [R&C and NP Active Users.sql](R%26C%20and%20NP%20Active%20Users.sql)

## "RiskJournal retetention" (published data source)

- **Published source:** "B2B True North - RiskJournal retetention" in `B2B / B2B Product / Data sources / True North Metrics Data Sources`, owner Maria Peco; [archived here](../Data%20sources/True%20North%20Metrics%20Data%20Sources/B2B%20True%20North%20-%20RiskJournal%20retetention). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** RJ retention numbers, RJ retention rate
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> RiskJournal retetention.sql
```
- **Athena tables read:** `fact_external_db.omniture_event_fact_hourly`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_corporate_dimension`, `dimension_external_db.pib_territory_dimension`, `dimension_external_db.pib_user_dimension`
- **SQL files:** [RiskJournal retetention.sql](RiskJournal%20retetention.sql)

## "DJRJ" (published data source)

- **Published source:** "B2B True North - DJRJ" in `B2B / B2B Product / Data sources / True North Metrics Data Sources`, owner Maria Peco; [archived here](../Data%20sources/True%20North%20Metrics%20Data%20Sources/B2B%20True%20North%20-%20DJRJ). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / abc_matrix)
- **Used by worksheets:** Modules, Modules (2), Modules2
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> DJRJ.sql
```
- **Athena tables read:** `fact_external_db.omniture_event_fact_hourly`, `subscription_external_db.identity_lookup`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_corporate_dimension`, `dimension_external_db.pib_territory_dimension`, `dimension_external_db.pib_user_dimension`
- **SQL files:** [DJRJ.sql](DJRJ.sql)

## "R&C Financial Crime Migration - Membership" (published data source)

- **Published source:** "B2B True North - R&C Financial Crime Migration - Membership" in `B2B / B2B Product / Data sources / True North Metrics Data Sources`, owner Maria Peco; [archived here](../Data%20sources/True%20North%20Metrics%20Data%20Sources/B2B%20True%20North%20-%20R%26C%20Financial%20Crime%20Migration%20-%20Membership). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** AME Donut Migration, APAC Donut Migration, Donut Migration, EMEA Donut Migration, GAT Donut Migration, Migrated %, Migrated % (2), Migration Trend, Table Migration
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> R&C Financial Crime Migration - Membership.sql
```
- **Athena tables read:** `dimension_external_db.pib_membership_history`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_user_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_territory_dimension`
- **SQL files:** [R&C Financial Crime Migration - Membership.sql](R%26C%20Financial%20Crime%20Migration%20-%20Membership.sql)

## "North Star" (published data source)

- **Published source:** "B2B True North - North Star" in `B2B / B2B Product / Data sources / True North Metrics Data Sources`, owner James Thomson; [archived here](../Data%20sources/True%20North%20Metrics%20Data%20Sources/B2B%20True%20North%20-%20North%20Star). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Active %, Active %  v2, Active %  v3, Active Users v2, Active Users v2 NF, CF Active User %, CF Active User % trend, CF Reg, CF Reg V2, CF Reg V3, CF Reg users, CF Reg users APIs, CF Reg users v2, Classic active trend, Classic active trend (2), FC Active, FC Active %, FC Active User % trend, FC Reg, FC Reg users Number, FC Reg users pct, FC Reg users trend, FC active trend, Factiva Active, Factiva Active v2, Factiva Active v3, Month Year, NF Active User %, NF Active User % trend, NF Reg users, NP Active % , NP Reg, NP Reg users trend, NP active trend , Newsplus Active, Sheet 1, Sheet 1 (3), Sheet 10, Sheet 15, Sheet 3 (2), Sheet 3 (3), Sheet 5, Sheet 63
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> North Star.sql
```
- **Athena tables read:** `reference_external_db.date_dimension`, `dimension_external_db.pib_membership_history`, `reference_external_db.pib_product_dimension`
- **SQL files:** [North Star.sql](North%20Star.sql)

## "DJY Usage" (published data source)

- **Published source:** "DJY Usage" in `B2B / B2B Product / Factiva / Factiva Search Usage`, owner James Thomson; [archived here](../Factiva/Factiva%20Search%20Usage/DJY%20Usage). The SQL below is copied from it.
- **Shape:** Join of 2 tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Used by worksheets:** Latest Month Yom (2), Sheet 236, Yom  WAU (2), Yom MAUs (2), Yom PVs (2), Yom Prev day (2), Yomuri Active 2 (2), Yomuri Last 30 days (2)
- **Structure:**

```
- LEFT JOIN on [Custom SQL Query].[year_month_day] = STR([Day Lookup].[Date])
  - Athena Custom SQL "Custom SQL Query" -> DJY Usage.sql
  - Google Drive Excel "Day lookup" table Sheet1$ (as "Day Lookup")
```
- **Athena tables read:** `reference_external_db.date_dimension`, `fact_external_db.omniture_event_fact_hourly`, `subscription_external_db.identity_lookup`, `dimension_external_db.pib_membership_dimension`, `pib_event_data.pib_platform_trace`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [DJY Usage.sql](DJY%20Usage.sql)

## "DJY Retention" (published data source)

- **Published source:** "B2B True North - DJY Retention" in `B2B / B2B Product / Data sources / True North Metrics Data Sources`, owner James Thomson; [archived here](../Data%20sources/True%20North%20Metrics%20Data%20Sources/B2B%20True%20North%20-%20DJY%20Retention). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** DJY Retention numbers, DJY Retention rate
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> DJY Retention.sql
```
- **Athena tables read:** `subscription_external_db.identity_lookup`, `dimension_external_db.pib_membership_dimension`, `fact_external_db.omniture_event_fact_hourly`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_corporate_dimension`, `dimension_external_db.pib_territory_dimension`, `dimension_external_db.pib_user_dimension`
- **SQL files:** [DJY Retention.sql](DJY%20Retention.sql)

## "API 2" (published data source)

- **Published source:** "B2B True North - API 2" in `B2B / B2B Product / Data sources / True North Metrics Data Sources`, owner James Thomson; [archived here](../Data%20sources/True%20North%20Metrics%20Data%20Sources/B2B%20True%20North%20-%20API%202). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** NewsP, NewsP (2), NewsP (3), Sheet 187 (2), Sheet 187 (3)
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> API 2.sql
```
- **Athena tables read:** `pib_event_data.pib_platform_trace`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [API 2.sql](API%202.sql)

## "DJDN Source Usage" (published data source)

- **Published source:** "B2B True North - DJDN Source Usage" in `B2B / B2B Product / Data sources / True North Metrics Data Sources`, owner Maria Peco; [archived here](../Data%20sources/True%20North%20Metrics%20Data%20Sources/B2B%20True%20North%20-%20DJDN%20Source%20Usage). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Sheet 151, Sheet 151 (2)
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> DJDN Source Usage.sql
```
- **Athena tables read:** `fact_external_db.omniture_event_fact`, `dimension_external_db.pib_membership_dimension`
- **SQL files:** [DJDN Source Usage.sql](DJDN%20Source%20Usage.sql)

## "Factiva Active Users" (published data source)

- **Published source:** "B2B True North - Factiva Active Users" in `B2B / B2B Product / Data sources / True North Metrics Data Sources`, owner James Thomson; [archived here](../Data%20sources/True%20North%20Metrics%20Data%20Sources/B2B%20True%20North%20-%20Factiva%20Active%20Users). The SQL below is copied from it.
- **Shape:** Join of 2 tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Used by worksheets:** 1 Factiva KPI 2025 (2), 1 Factiva KPI Number, 1 Factiva KPI pct, 1 Factiva MAU KPI 2025 (3), 1 MAUs, 1 MAUs NF, 1 New Factiva KPI 2025, 2 Weekly, 2 Weekly NF, 3 Daily, 3 Daily NF, AVs - Most recent, Conversion, DAU, Fact Factiva KPI pct (2), Fact Factiva KPI pct (3), Factiva KPI Chart, Factiva MAUs -ve change, Factiva MAUs Change, Factiva PVS Change, Factiva PVS Change (2), Latest month, Latest month (2), MAU Trend 2025 (6), MAU Trend 2025 (7), N Factiva KPI Chart, NF Factiva KPI pct, NF Weekly Trend 2025, NF Weekly Trend 2025 (2), NF Weekly Trend 2025 (3), NF Weekly Trend 2025 (4), NF Weekly Trend 2025 (5), NF Weekly Trend 2025 (6), NF Weekly Trend 2025 (7), NF top 25, NF top 25 p2, PVs per User KPI, PVs per user Fact Factiva KPI pct (3), Sheet 159, Sheet 205, Sheet 208, Sheet 208 (2), Sheet 208 (3), Sheet 208 (4), Sheet 208 (5), Sheet 87, Sheet 88, Sheet 89, U Users - Most recent, U Users - Most recent (2), WAU Pct NF change, WAU Pct change, Week N Factiva KPI pct, Weekly N Factiva KPI Char, Wk Lookup
- **Structure:**

```
- LEFT JOIN on [Custom SQL Query].[year_month_day] = STR([Sheet1].[Date])
  - Athena Custom SQL "Custom SQL Query" -> Factiva Active Users.sql
  - Google Drive Excel "Day lookup" table Sheet1$ (as "Sheet1")
```
- **Athena tables read:** `reference_external_db.date_dimension`, `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `fact_external_db.omniture_event_fact`
- **SQL files:** [Factiva Active Users.sql](Factiva%20Active%20Users.sql)

## "User Level search data" (published data source)

- **Published source:** "B2B True North - User Level search data" in `B2B / B2B Product / Data sources / True North Metrics Data Sources`, owner James Thomson; [archived here](../Data%20sources/True%20North%20Metrics%20Data%20Sources/B2B%20True%20North%20-%20User%20Level%20search%20data). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Sheet 109, Sheet 109 (2)
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> User Level search data.sql
```
- **Athena tables read:** `dimension_external_db.pib_membership_dimension`, `reference_external_db.date_dimension`, `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [User Level search data.sql](User%20Level%20search%20data.sql)

## "Smart Summary V2 True North" (published data source)

- **Published source:** "Smart Summary V2 True North" in `B2B / B2B Product / Factiva / Datasources`, owner James Thomson; [archived here](../Factiva/Datasources/Smart%20Summary%20V2%20True%20North). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Smart Summary CTR%
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Smart Summary V2 True North.sql
```
- **Athena tables read:** `dimension_external_db.pib_membership_dimension`, `reference_external_db.date_dimension`, `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [Smart Summary V2 True North.sql](Smart%20Summary%20V2%20True%20North.sql)

## "NF SB Conversion" (published data source)

- **Published source:** "NF SB Conversion" in `B2B / B2B Product / Factiva / Factiva Search Usage`, owner James Thomson; [archived here](../Factiva/Factiva%20Search%20Usage/NF%20SB%20Conversion). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** NF SB Success Rate, Sheet 249
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> NF SB Conversion.sql
```
- **Athena tables read:** `reference_external_db.date_dimension`, `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`
- **SQL files:** [NF SB Conversion.sql](NF%20SB%20Conversion.sql)

## "Semantic Search" (published data source)

- **Published source:** "B2B True North - Semantic Search" in `B2B / B2B Product / Data sources / True North Metrics Data Sources`, owner James Thomson; [archived here](../Data%20sources/True%20North%20Metrics%20Data%20Sources/B2B%20True%20North%20-%20Semantic%20Search). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Ent Link %, MMR, MMR KPI %, Sem Search, Sem Search both, Standard Search, sem search pct change, sem search pct change (2)
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Semantic Search.sql
```
- **Athena tables read:** `reference_external_db.date_dimension`, `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [Semantic Search.sql](Semantic%20Search.sql)
