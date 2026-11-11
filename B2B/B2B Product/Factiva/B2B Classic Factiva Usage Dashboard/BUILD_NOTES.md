# B2B Classic Factiva Usage Dashboard

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Product / Factiva |
| Owner | James Thomson |
| Created | 2025-07-28 |
| Last updated | 2026-06-26 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/3090018 |
| Archived | 2026-11-11 |

## Summary

1 data source(s) in the workbook; 1 with an Athena component (0 embedded, 1 published).

## "Usage Athena" (published data source)

- **Published source:** "B2B Classic Factiva Usage Dashboard - Usage Athena" in `B2B / B2B Product / Factiva / Datasources`, owner James Thomson; [archived here](../Datasources/B2B%20Classic%20Factiva%20Usage%20Dashboard%20-%20Usage%20Athena). The SQL below is copied from it.
- **Shape:** Join of 3 tables -- Athena + BigQuery
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); BigQuery
- **Used by worksheets:** Breakdown, Breakdown user count, Company Breakdown, Factiva, Factiva (2), Factiva users, Last Month UUsers, Last Month Usage, MoM UUsers, MoM Usage, NP Breakdown, NP Table view, NP Test, NP Title breakdown, NP Title date, NP User breakdown, NewsPlus, Newsplus button, PV Title breakdown, Page breakdown, Page breakdown (2), RC Breakdown, RC Title breakdown, RC Title date, RC User breakdown, RiskCenter, Sheet 1, Sheet 22, Sheet 40, Sheet 6, Sheet 8, Sheet 9, Table view, Table view (2), Table view (3), Table view Metrics, Table view active users, Test Active days, Test Active days (2), Text, Title breakdown, Title date, Title date users, Trend Line, Trend Line UU, UU Breakdown, Update, User Breakdown 2, User breakdown, User level Table view, YoY UUsers, YoY Usage
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
