# Lazard Freres Factiva Usage

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Sales / Product Usage |
| Owner | James Thomson |
| Created | 2026-01-12 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/3829594 |
| Archived | 2026-11-11 |

## Summary

4 data source(s) in the workbook; 4 with an Athena component (4 embedded, 0 published).

## "Lazard Reg in Month Query" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Sheet 6, Sheet 6 (2)
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Lazard Reg in Month Query.sql
```
- **Athena tables read:** `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [Lazard Reg in Month Query.sql](Lazard%20Reg%20in%20Month%20Query.sql)

## "FT data" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Sheet 4, Sheet 4 (2)
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> FT data.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [FT data.sql](FT%20data.sql)

## "Lazard User Level" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Sheet 1, Sheet 1 (2), Sheet 2
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Lazard User Level.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `fact_external_db.omniture_event_fact`
- **SQL files:** [Lazard User Level.sql](Lazard%20User%20Level.sql)

## "Total Registered" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Sheet 6, Sheet 8
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Total Registered.sql
```
- **Athena tables read:** `reference_external_db.date_dimension`, `dimension_external_db.pib_membership_history`, `reference_external_db.pib_product_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [Total Registered.sql](Total%20Registered.sql)
