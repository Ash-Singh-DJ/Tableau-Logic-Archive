# B2B Classic vs New Factiva Search Dashboard

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / Factiva Legacy (for review) |
| Owner | Maria Peco |
| Created | 2025-07-29 |
| Last updated | 2025-09-12 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/3093372 |
| Archived | 2026-11-11 |

## Summary

4 data source(s) in the workbook; 4 with an Athena component (0 embedded, 4 published).

## "B2B Classic vs New Factiva Search Dashboard - Search Draft" (published data source)

- **Published source:** "B2B Classic vs New Factiva Search Dashboard - Search Draft" in `B2B / B2B Product / Factiva / Datasources`, owner Maria Peco; [archived here](../../B2B%20Product/Factiva/Datasources/B2B%20Classic%20vs%20New%20Factiva%20Search%20Dashboard%20-%20Search%20Draft). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Sheet 1, Sheet 1 (2), Sheet 31, Test
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> B2B Classic vs New Factiva Search Dashboard - Search Draft.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [B2B Classic vs New Factiva Search Dashboard - Search Draft.sql](B2B%20Classic%20vs%20New%20Factiva%20Search%20Dashboard%20-%20Search%20Draft.sql)

## "B2B Classic vs New Factiva Search - Search journey" (published data source)

- **Published source:** "B2B Classic vs New Factiva Search Dashboard - Search journey" in `B2B / B2B Product / Factiva / Datasources`, owner Maria Peco; [archived here](../../B2B%20Product/Factiva/Datasources/B2B%20Classic%20vs%20New%20Factiva%20Search%20Dashboard%20-%20Search%20journey). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Art 1_5, Art 1_6+, Art 2, Avg Ordinal, Avg Ordinal (2), Comp, Comp Total, Homepage, Industry, Industry Total, Line chart, Metric, Searches, Sheet 18, Sheet 5, Sheet 6, Sheet 7, Toggle, Total art, Visit ends, Visit ends (2)
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> B2B Classic vs New Factiva Search - Search journey.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [B2B Classic vs New Factiva Search - Search journey.sql](B2B%20Classic%20vs%20New%20Factiva%20Search%20-%20Search%20journey.sql)

## "B2B Classic vs New Factiva Search - All Factiva Content Lang" (published data source)

- **Published source:** "B2B Classic vs New Factiva Search Dashboard - All Factiva Content Lang" in `B2B / B2B Product / Factiva / Datasources`, owner Maria Peco; [archived here](../../B2B%20Product/Factiva/Datasources/B2B%20Classic%20vs%20New%20Factiva%20S...rd%20-%20All%20Factiva%20Content%20Lang). The SQL below is copied from it.
- **Shape:** Relationship model: 3 logical tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Used by worksheets:** Content Langauge Value2, Sheet 4, Summary
- **Structure:**

```
Logical table "Lang"
  - Google Drive Excel "ISO Codes2" table Sheet1$ (as "Sheet1")
Logical table "Revenue"
  - Google Drive Excel "Revenue Lang" table Sheet 1$ (as "Sheet 1")
Logical table "Custom SQL Query"
  - Athena Custom SQL "Custom SQL Query" -> B2B Classic vs New Factiva Search - All Factiva Content Lang.sql
```

- **Relationships:**
  - "Custom SQL Query" ↔ "Lang" on `[lang] = [code]`
  - "Custom SQL Query" ↔ "Revenue" on `[company_sfdc_id] = [company sfdc id]`
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [B2B Classic vs New Factiva Search - All Factiva Content Lang.sql](B2B%20Classic%20vs%20New%20Factiva%20Search%20-%20All%20Factiva%20Content%20Lang.sql)

## "B2B Classic vs New Factiva Search Dashboard - AVs by Publish date" (published data source)

- **Published source:** "B2B Classic vs New Factiva Search Dashboard - AVs by Publish date" in `B2B / B2B Product / Factiva / Datasources`, owner Maria Peco; [archived here](../../B2B%20Product/Factiva/Datasources/B2B%20Classic%20vs%20New%20Factiva%20S...shboard%20-%20AVs%20by%20Publish%20date). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Sheet 28, Sheet 28 (2), Sheet 28 (3)
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> B2B Classic vs New Factiva Search Dashboard - AVs by Publish date.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [B2B Classic vs New Factiva Search Dashboard - AVs by Publish date.sql](B2B%20Classic%20vs%20New%20Factiva%20Search%20Dashboard%20-%20AVs%20by%20Publish%20date.sql)
