# B2B Internal User Factiva Search Terms

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / Factiva Legacy (for review) |
| Owner | Maria Peco |
| Created | 2025-07-29 |
| Last updated | 2026-01-12 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/3093448 |
| Archived | 2026-11-11 |

## Summary

5 data source(s) in the workbook; 5 with an Athena component (0 embedded, 5 published).

## "Company Codes" (published data source)

- **Published source:** "B2B Internal Usage Factiva Search Terms - Company Codes" in `B2B / B2B Product / Factiva / Datasources`, owner Maria Peco; [archived here](../../B2B%20Product/Factiva/Datasources/B2B%20Internal%20Usage%20Factiva%20Search%20Terms%20-%20Company%20Codes). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Company Codes
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Company Codes.sql
```
- **Athena tables read:** `pib_event_data.pib_platform_trace`
- **SQL files:** [Company Codes.sql](Company%20Codes.sql)

## "B2B Internal Usage Factiva Search Terms - News Subjects" (published data source)

- **Published source:** "B2B Internal Usage Factiva Search Terms - News Subjects" in `B2B / B2B Product / Factiva / Datasources`, owner Maria Peco; [archived here](../../B2B%20Product/Factiva/Datasources/B2B%20Internal%20Usage%20Factiva%20Search%20Terms%20-%20News%20Subjects). The SQL below is copied from it.
- **Shape:** Join of 2 tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Used by worksheets:** NS Codes, Search Terms
- **Structure:**

```
- LEFT JOIN on upper([Custom SQL Query].[metric]) = [NS].[Code]
  - Athena Custom SQL "Custom SQL Query" -> B2B Internal Usage Factiva Search Terms - News Subjects.sql
  - Google Drive Excel "Untitled spreadsheet" table NS$ (as "NS")
```
- **Athena tables read:** `pib_event_data.pib_platform_trace`
- **SQL files:** [B2B Internal Usage Factiva Search Terms - News Subjects.sql](B2B%20Internal%20Usage%20Factiva%20Search%20Terms%20-%20News%20Subjects.sql)

## "Int search terms" (published data source)

- **Published source:** "B2B Internal Usage Factiva Search Terms - Int search terms" in `B2B / B2B Product / Factiva / Datasources`, owner Maria Peco; [archived here](../../B2B%20Product/Factiva/Datasources/B2B%20Internal%20Usage%20Factiva%20Search%20Terms%20-%20Int%20search%20terms). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Boolean Frequency, Boolean Frequency (2), Boolean Frequency (3), Detail, Detail (2), Search Length Frequency, Sheet 1 (2), Sheet 10, Sheet 11, Sheet 12, Sheet 14, Sheet 14 (2), Sheet 21, Sheet 9, Top Search
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Int search terms.sql
```
- **Athena tables read:** `pib_event_data.pib_platform_trace`
- **SQL files:** [Int search terms.sql](Int%20search%20terms.sql)

## "GenAI Summary usage" (published data source)

- **Published source:** "B2B Internal Usage Factiva Search Terms - GenAI Summary usage" in `B2B / B2B Product / Factiva / Datasources`, owner Maria Peco; [archived here](../../B2B%20Product/Factiva/Datasources/B2B%20Internal%20Usage%20Factiva%20S...h%20Terms%20-%20GenAI%20Summary%20usage). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Sheet 7
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> GenAI Summary usage.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [GenAI Summary usage.sql](GenAI%20Summary%20usage.sql)

## "Industry" (published data source)

- **Published source:** "B2B Internal Usage Factiva Search Terms - Industry" in `B2B / B2B Product / Factiva / Datasources`, owner Maria Peco; [archived here](../../B2B%20Product/Factiva/Datasources/B2B%20Internal%20Usage%20Factiva%20Search%20Terms%20-%20Industry). The SQL below is copied from it.
- **Shape:** Join of 2 tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Used by worksheets:** Ind Search Terms, Ind Terms
- **Structure:**

```
- LEFT JOIN on lower([Custom SQL Query].[metric]) = [Industry].[IND Code]
  - Athena Custom SQL "Custom SQL Query" -> Industry.sql
  - Google Drive Excel "NS Code Lookup" table Industry$ (as "Industry")
```
- **Athena tables read:** `pib_event_data.pib_platform_trace`
- **SQL files:** [Industry.sql](Industry.sql)
