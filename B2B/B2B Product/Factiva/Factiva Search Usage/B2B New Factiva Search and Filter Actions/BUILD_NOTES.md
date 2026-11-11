# B2B New Factiva Search and Filter Actions

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Product / Factiva / Factiva Search Usage |
| Owner | svc_dj tableaucdl_b2b |
| Created | 2025-07-30 |
| Last updated | 2026-07-29 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/3100251 |
| Archived | 2026-11-11 |

## Summary

2 data source(s) in the workbook; 2 with an Athena component (0 embedded, 2 published).

## "B2B New Factiva Search and Filter Viz Draft" (published data source)

- **Published source:** "B2B New Factiva Search and Filter Actions - Viz Draft" in `B2B / B2B Product / Factiva / Datasources`, owner James Thomson; [archived here](../../Datasources/B2B%20New%20Factiva%20Search%20and%20Filter%20Actions%20-%20Viz%20Draft). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Pivot, Pivot (2), Sheet 1, Sheet 12, Sheet 16, Sheet 17, Sheet 2, Test
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> B2B New Factiva Search and Filter Viz Draft.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [B2B New Factiva Search and Filter Viz Draft.sql](B2B%20New%20Factiva%20Search%20and%20Filter%20Viz%20Draft.sql)

## "User Flow" (published data source)

- **Published source:** "B2B New Factiva Search and Filter Actions - User Flow" in `B2B / B2B Product / Factiva / Datasources`, owner Maria Peco; [archived here](../../Datasources/B2B%20New%20Factiva%20Search%20and%20Filter%20Actions%20-%20User%20Flow). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** 1to2, 2to3, Page 1, Page 2, Page 3, Sheet 4, Sheet 5, Sheet 5 (2), Sheet 5 (3)
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> User Flow.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`
- **SQL files:** [User Flow.sql](User%20Flow.sql)
