# Factiva Retention

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Product / Factiva |
| Owner | James Thomson |
| Created | 2026-02-10 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/3993928 |
| Archived | 2026-11-11 |

## Summary

4 data source(s) in the workbook; 4 with an Athena component (3 embedded, 1 published).

## "Factiva Monthly retention Clusters" (embedded)

- **Shape:** Join of 4 tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / reference_external_db); Google Drive Excel
- **Used by worksheets:** CF + NF Monthly Retention Numbers , CF + NF Monthly Retention rate %, Sheet 1, Sheet 5, Weekly retention numbers, Weekly retention numbers (3)
- **Structure:**

```
- LEFT JOIN on [Custom SQL Query].[plan_id] = [Codes].[Code]
  - LEFT JOIN on [Custom SQL Query].[plan_id] = [pib_product_dimens].[access_code]
    - LEFT JOIN on [Custom SQL Query].[company_industry] = [Industry Mapping].[SFDC Industry]
      - Athena Custom SQL "Custom SQL Query" -> Factiva Monthly retention Clusters.sql
      - Google Drive Excel "Industry Mapping" table Sheet1$ (as "Industry Mapping")
    - Athena table reference_external_db.pib_product_dimension (as "pib_product_dimens")
  - Google Drive Excel "RCFC codes" table Codes$ (as "Codes")
```
- **Athena tables read:** `zoolander_db.factiva_micro_user_seg_6mo`, `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_corporate_dimension`, `dimension_external_db.pib_territory_dimension`, `dimension_external_db.pib_user_dimension`, `reference_external_db.pib_product_dimension`
- **SQL files:** [Factiva Monthly retention Clusters.sql](Factiva%20Monthly%20retention%20Clusters.sql)

## "New Factiva Retention" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** NF Monthly Retention Numbers1, NF Monthly Retention rate %1
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> New Factiva Retention.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_corporate_dimension`, `dimension_external_db.pib_territory_dimension`, `dimension_external_db.pib_user_dimension`
- **SQL files:** [New Factiva Retention.sql](New%20Factiva%20Retention.sql)

## "Classic Factiva Retention" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** CF Monthly Retention Numbers, CF Monthly Retention rate %
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Classic Factiva Retention.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_corporate_dimension`, `dimension_external_db.pib_territory_dimension`, `dimension_external_db.pib_user_dimension`
- **SQL files:** [Classic Factiva Retention.sql](Classic%20Factiva%20Retention.sql)

## "Factiva Weekly retention" (published data source)

- **Published source:** "Factiva Weekly retention" in `B2B / B2B Testing`, owner James Thomson; not archived separately: it sits outside the archive scope (B2B Testing). The SQL below is copied from it.
- **Shape:** Join of 4 tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / reference_external_db); Google Drive Excel
- **Used by worksheets:** _none (data source is unused in this workbook)_
- **Structure:**

```
- LEFT JOIN on [Custom SQL Query].[plan_id] = [Codes].[Code]
  - LEFT JOIN on [Custom SQL Query].[plan_id] = [pib_product_dimens].[access_code]
    - LEFT JOIN on [Custom SQL Query].[company_industry] = [Industry Mapping].[SFDC Industry]
      - Athena Custom SQL "Custom SQL Query" -> Factiva Weekly retention.sql
      - Google Drive Excel "Industry Mapping" table Sheet1$ (as "Industry Mapping")
    - Athena table reference_external_db.pib_product_dimension (as "pib_product_dimens")
  - Google Drive Excel "RCFC codes" table Codes$ (as "Codes")
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_corporate_dimension`, `dimension_external_db.pib_territory_dimension`, `dimension_external_db.pib_user_dimension`, `reference_external_db.pib_product_dimension`
- **SQL files:** [Factiva Weekly retention.sql](Factiva%20Weekly%20retention.sql)
