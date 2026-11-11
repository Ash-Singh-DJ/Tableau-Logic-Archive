# Unique Users on DJ Platform

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Product |
| Owner | James Thomson |
| Created | 2026-03-13 |
| Last updated | 2026-05-26 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/4224351 |
| Archived | 2026-11-11 |

## Summary

2 data source(s) in the workbook; 2 with an Athena component (0 embedded, 2 published).

## "Unique Users on DJ Platform2" (published data source)

- **Published source:** "Unique Users on DJ Platform2" in `B2B / B2B Content Licensing- PAL`, owner James Thomson; [archived here](../../B2B%20Content%20Licensing-%20PAL/Unique%20Users%20on%20DJ%20Platform2). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** External, Internal, Sheet 5, Total Users, Total Users (2), Total Users (3), Total Users (4)
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Unique Users on DJ Platform2.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `fact_external_db.omniture_event_fact_hourly`
- **SQL files:** [Unique Users on DJ Platform2.sql](Unique%20Users%20on%20DJ%20Platform2.sql)

## "Unique Users on DJ Platform" (published data source)

- **Published source:** "Unique Users on DJ Platform" in `B2B / B2B Sales / Product Usage`, owner James Thomson; [archived here](../../B2B%20Sales/Product%20Usage/Unique%20Users%20on%20DJ%20Platform). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** _none (data source is unused in this workbook)_
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Unique Users on DJ Platform.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `fact_external_db.omniture_event_fact_hourly`
- **SQL files:** [Unique Users on DJ Platform.sql](Unique%20Users%20on%20DJ%20Platform.sql)
