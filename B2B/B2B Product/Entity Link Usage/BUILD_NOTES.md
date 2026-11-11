# Entity Link Usage

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Product |
| Owner | James Thomson |
| Created | 2026-01-23 |
| Last updated | 2026-01-23 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/3891276 |
| Archived | 2026-11-11 |

## Summary

8 data source(s) in the workbook; 6 with an Athena component (0 embedded, 6 published).
Other data sources: "search_dashboard_wsj_weekly (jaddii)" (published); "search_dashboard_wsj_monthly (jaddii)" (published).

## "NF Search Metrics 2025" (published data source)

- **Published source:** "B2B DJ Search Dashboard - NF Search Metrics 2025" in `B2B / B2B Product / Data sources`, owner James Thomson; [archived here](../Data%20sources/B2B%20DJ%20Search%20Dashboard%20-%20NF%20Search%20Metrics%202025). The SQL below is copied from it.
- **Shape:** Join of 3 tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Used by worksheets:** CTR  1 to 5, CTR Trend, CTR: CF, CTR: NF Lex, CTR: NF Lex details, CTR: NF Sem, CTR: NF Sem details, CTR: NF Sem details (2), Conver Trend, Conversion%, Conversion: CF, Conversion: NF Lex, Conversion: NF Sem, Latest Month, MRR, Refromulation Trend, Sheet 1, Sheet 2, Sheet 28, Sheet 29, Sheet 30, Sheet 5, Sheet 5 (2), Sheet 5 (3), Sheet 5 (4), Sheet 8, Table2, Table2 (2), Top CF outcomes, Top CF outcomes (2), Total NF Searches, Total Searches, Total Searches (2)
- **Structure:**

```
- LEFT JOIN on [Custom SQL Query].[company_industry] = [Industry Lookup].[SFDC Industry]
  - LEFT JOIN on [Custom SQL Query].[department_code] = [Job Function].[Code]
    - Athena Custom SQL "Custom SQL Query" -> NF Search Metrics 2025.sql
    - Google Drive Excel "Job Function2" table Sheet1$ (as "Job Function")
  - Google Drive Excel "Industry Mapping 3" table Sheet1$ (as "Industry Lookup")
```
- **Athena tables read:** `dimension_external_db.pib_membership_dimension`, `reference_external_db.date_dimension`, `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [NF Search Metrics 2025.sql](NF%20Search%20Metrics%202025.sql)

## "User Level search data" (published data source)

- **Published source:** "B2B DJ Search Dashboard - User Level search data" in `B2B / B2B Product / Data sources`, owner James Thomson; [archived here](../Data%20sources/B2B%20DJ%20Search%20Dashboard%20-%20User%20Level%20search%20data). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** CF Searches, CF Searches (2), CF Searches (3), CF Searches Big Rocks, NF Searches, NF Searches , NF Searches (3), NF Searches Big Rocks, Search Visits, Search Visits %, Search Vists Per User, Sheet 50, Sheet 55, Table, Total Search Visits, Trend Search Visits per User, Unique Search Users, Unique Users
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> User Level search data.sql
```
- **Athena tables read:** `dimension_external_db.pib_membership_dimension`, `reference_external_db.date_dimension`, `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [User Level search data.sql](User%20Level%20search%20data.sql)

## "Entity links" (published data source)

- **Published source:** "Entity links" in `B2B / B2B Product / Factiva / Datasources`, owner James Thomson; [archived here](../Factiva/Datasources/Entity%20links). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Sheet 117, Sheet 4 (2), Sheet 7, Sheet 7 (4), Sheet 7 (5)
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Entity links.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [Entity links.sql](Entity%20links.sql)

## "Factiva Source breakdown 2" (published data source)

- **Published source:** "Factiva Source breakdown 2" in `B2B / B2B Sales / Product Usage`, owner James Thomson; [archived here](../../B2B%20Sales/Product%20Usage/Factiva%20Source%20breakdown%202). The SQL below is copied from it.
- **Shape:** Relationship model: 4 logical tables (with joins inside) -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / reference_external_db); Google Drive Excel
- **Used by worksheets:** AVs from search, Article Age, Article views by Variable, Article views by Variable (2), Band Chart, Band Table, Bands %, Sheet 101, Sheet 116, Sheet 93, Sheet 94 (2)
- **Structure:**

```
Logical table "Bands"
  - Google Drive Excel "Band Look up" table Bands$ (as "Bands")
Logical table "Source Lookup"
  - Google Drive Excel "Source Sheet Lookup" table Sheet1$ (as "Sheet1")
Logical table "Custom SQL Query"
  - LEFT JOIN on [Custom SQL Query].[post_evar3] = [Lang config].[user_info_user_ref]
    - Athena Custom SQL "Custom SQL Query" -> Factiva Source breakdown 2 - Custom SQL Query.sql
    - Athena Custom SQL "Lang config" -> Factiva Source breakdown 2 - Lang config.sql
Logical table "country_reference"
  - Athena table reference_external_db.country_reference (as "country_reference")
```

- **Relationships:**
  - "Custom SQL Query" ↔ "Bands" on `[Source_code] = [Source Code]`
  - "Custom SQL Query" ↔ "Source Lookup" on `[Source_code] = [Source Code (sc)]`
  - "Source Lookup" ↔ "country_reference" on `[Region of Origin - Country] = [country_name]`
- **Athena tables read:** `fact_external_db.omniture_event_fact`, `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `reference_external_db.pib_product_dimension`, `dimension_external_db.pib_territory_dimension`, `reference_external_db.country_reference`
- **SQL files:** [Factiva Source breakdown 2 - Custom SQL Query.sql](Factiva%20Source%20breakdown%202%20-%20Custom%20SQL%20Query.sql), [Factiva Source breakdown 2 - Lang config.sql](Factiva%20Source%20breakdown%202%20-%20Lang%20config.sql)

## "Article Age" (published data source)

- **Published source:** "B2B DJ Search Dashboard - Article Age" in `B2B / B2B Product / Data sources`, owner James Thomson; [archived here](../Data%20sources/B2B%20DJ%20Search%20Dashboard%20-%20Article%20Age). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Article Age
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Article Age.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [Article Age.sql](Article%20Age.sql)

## "Factiva Source breakdown" (published data source)

- **Published source:** "B2B DJ Search Dashboard - Factiva Source breakdown" in `B2B / B2B Product / Data sources`, owner James Thomson; [archived here](../Data%20sources/B2B%20DJ%20Search%20Dashboard%20-%20Factiva%20Source%20breakdown). The SQL below is copied from it.
- **Shape:** Relationship model: 4 logical tables -- Athena + Google Drive Excel + Excel file
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / reference_external_db); Excel file; Google Drive Excel
- **Used by worksheets:** _none (data source is unused in this workbook)_
- **Structure:**

```
Logical table "Source Sheet"
  - Excel file "Data for Tableau Factiva Source Dashboard 2025-06-02" table 9453_20250602$ (as "9453_20250602")
Logical table "Bands"
  - Google Drive Excel "Band Look up" table Bands$ (as "Bands")
Logical table "Custom SQL Query"
  - Athena Custom SQL "Custom SQL Query" -> Factiva Source breakdown.sql
Logical table "country_reference"
  - Athena table reference_external_db.country_reference (as "country_reference")
```

- **Relationships:**
  - "Custom SQL Query" ↔ "Source Sheet" on `[Source_code] = [Source Code (sc)]`
  - "Custom SQL Query" ↔ "Bands" on `[Source_code] = [Source Code]`
  - "Source Sheet" ↔ "country_reference" on `[Region of Origin - Country] = [country_name]`
- **Athena tables read:** `fact_external_db.omniture_event_fact`, `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `reference_external_db.pib_product_dimension`, `dimension_external_db.pib_territory_dimension`, `reference_external_db.country_reference`
- **SQL files:** [Factiva Source breakdown.sql](Factiva%20Source%20breakdown.sql)
