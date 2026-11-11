#  B2B Factiva Newsletter Upsell & Retention Dashboard

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / Factiva Legacy (for review) |
| Owner | James Thomson |
| Created | 2025-07-30 |
| Last updated | 2026-10-13 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/3100130 |
| Archived | 2026-11-11 |

## Summary

2 data source(s) in the workbook; 2 with an Athena component (0 embedded, 2 published).

## "Headline-Level Data" (published data source)

- **Published source:** "B2B Factiva Newsletter Upsell & Retention - Headline-Level Data" in `B2B / B2B Sales / Data Sources`, owner Maria Peco; [archived here](../../B2B%20Sales/Data%20Sources/B2B%20Factiva%20Newsletter%20Upsel...tention%20-%20Headline-Level%20Data). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Headline Report
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Headline-Level Data.sql
```
- **Athena tables read:** `fact_external_db.omniture_event_fact`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_territory_dimension`, `dimension_external_db.pib_user_dimension`, `sandbox_mk.factiva_content_source_current`
- **SQL files:** [Headline-Level Data.sql](Headline-Level%20Data.sql)

## "Newsletter Retention Dash Data" (published data source)

- **Published source:** "B2B Factiva Newsletter Upsell & Retention -  Dash Data" in `B2B / B2B Sales / Data Sources`, owner Maria Peco; [archived here](../../B2B%20Sales/Data%20Sources/B2B%20Factiva%20Newsletter%20Upsell%20%26%20Retention%20-%20Dash%20Data). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Accounts at Risk, Last Updated, Newsletter Name Usage Data, Newsletter Publishes by Billing Account, User-Level Newsletter Data
- **Structure:**

```
- Athena Custom SQL "Newsletter Retention Data" -> Newsletter Retention Dash Data.sql
```
- **Athena tables read:** `fact_external_db.omniture_event_fact`, `dimension_external_db.pib_membership_dimension`, `reference_external_db.date_dimension`, `fact_external_db.pib_membership_fact`, `dimension_external_db.pib_billing_account_dimension`, `fact_external_db.pib_account_hierarchy_fact`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_territory_dimension`, `dimension_external_db.pib_user_dimension`
- **SQL files:** [Newsletter Retention Dash Data.sql](Newsletter%20Retention%20Dash%20Data.sql)
