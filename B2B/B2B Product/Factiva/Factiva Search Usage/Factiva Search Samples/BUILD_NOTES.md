# Factiva Search Samples

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Product / Factiva / Factiva Search Usage |
| Owner | James Thomson |
| Created | 2026-01-15 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/3853828 |
| Archived | 2026-11-11 |

## Summary

4 data source(s) in the workbook; 4 with an Athena component (4 embedded, 0 published).

## "NF Searches samp" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** New Factiva Search
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> NF Searches samp.sql
```
- **Athena tables read:** `pib_event_data.pib_platform_trace`, `dimension_external_db.pib_membership_dimension`
- **SQL files:** [NF Searches samp.sql](NF%20Searches%20samp.sql)

## "MO request" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Saved Searches
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> MO request.sql
```
- **Athena tables read:** `pib_event_data.pib_platform_trace`, `dimension_external_db.pib_membership_dimension`
- **SQL files:** [MO request.sql](MO%20request.sql)

## "Expert Searches" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Expert Searches
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Expert Searches.sql
```
- **Athena tables read:** `pib_event_data.pib_platform_trace`, `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [Expert Searches.sql](Expert%20Searches.sql)

## "Simple + Saved Search" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Simple & Search Builder Searches
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Simple + Saved Search.sql
```
- **Athena tables read:** `pib_event_data.pib_platform_trace`, `dimension_external_db.pib_membership_dimension`
- **SQL files:** [Simple + Saved Search.sql](Simple%20%2B%20Saved%20Search.sql)
