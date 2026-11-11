# B2B Factiva Counter Reporting Dashboard

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Content Licensing- PAL |
| Owner | James Thomson |
| Created | 2025-07-28 |
| Last updated | 2025-09-15 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/3087008 |
| Archived | 2026-11-11 |

## Summary

2 data source(s) in the workbook; 2 with an Athena component (0 embedded, 2 published).

## "B2B Factiva Daily Counter Report Usage" (published data source)

- **Published source:** "B2B Factiva Counter Reporting Dashboard - Usage" in `B2B / B2B Content Licensing- PAL / Datasources`, owner Maria Peco; [archived here](../Datasources/B2B%20Factiva%20Counter%20Reporting%20Dashboard%20-%20Usage). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Alert Test, Country Abusers, IP Report, PV Abusers, Sheet 5
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> B2B Factiva Daily Counter Report Usage.sql
```
- **Athena tables read:** `fact_external_db.omniture_event_fact`, `dimension_external_db.pib_membership_dimension`, `reference_external_db.country_reference`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_territory_dimension`, `pib_event_data.pib_product_metrics`
- **SQL files:** [B2B Factiva Daily Counter Report Usage.sql](B2B%20Factiva%20Daily%20Counter%20Report%20Usage.sql)

## "B2B Factiva Counter Report Query (dimension_external_db)" (published data source)

- **Published source:** "B2B Factiva Counter Reporting Dashboard - Data Source" in `B2B / B2B Product / Factiva / Datasources`, owner Maria Peco; [archived here](../../B2B%20Product/Factiva/Datasources/B2B%20Factiva%20Counter%20Reporting%20Dashboard%20-%20Data%20Source). The SQL below is copied from it.
- **Shape:** Join of 2 tables
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / sandbox_mk)
- **Used by worksheets:** Billing Account Abuse Report, Database Report, Journal Report
- **Structure:**

```
- LEFT JOIN on [Counter Report Query].[source_code] = [Factiva Content Source].[sourcecode]
  - Athena Custom SQL "Counter Report Query" -> B2B Factiva Counter Report Query (dimension_external_db) - Counter Report Query.sql
  - Athena Custom SQL "Factiva Content Source" -> B2B Factiva Counter Report Query (dimension_external_db) - Factiva Content Source.sql
```
- **Athena tables read:** `fact_external_db.omniture_event_fact`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_territory_dimension`, `sandbox_mk.factiva_content_source_current`
- **SQL files:** [B2B Factiva Counter Report Query (dimension_external_db) - Counter Report Query.sql](B2B%20Factiva%20Counter%20Report%20Query%20%28dimension_external_db%29%20-%20Counter%20Report%20Query.sql), [B2B Factiva Counter Report Query (dimension_external_db) - Factiva Content Source.sql](B2B%20Factiva%20Counter%20Report%20Query%20%28dimension_external_db%29%20-%20Factiva%20Content%20Source.sql)
