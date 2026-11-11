# Factiva Source breakdown 2

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Sales / Product Usage |
| Owner | James Thomson |
| Created | 2025-10-15 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/107355441 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Relationship model: 4 logical tables (with joins inside) -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / reference_external_db); Google Drive Excel
- **Structure:**

```
Logical table "Bands"
  - Google Drive Excel "Band Look up" table Bands$ (as "Bands")
Logical table "Source Lookup"
  - Google Drive Excel "Source Sheet Lookup" table Sheet1$ (as "Sheet1")
Logical table "Custom SQL Query"
  - LEFT JOIN on [Custom SQL Query].[post_evar3] = [Lang config].[user_info_user_ref]
    - Athena Custom SQL "Custom SQL Query" -> Custom SQL Query.sql
    - Athena Custom SQL "Lang config" -> Lang config.sql
Logical table "country_reference"
  - Athena table reference_external_db.country_reference (as "country_reference")
```

- **Relationships:**
  - "Custom SQL Query" ↔ "Bands" on `[Source_code] = [Source Code]`
  - "Custom SQL Query" ↔ "Source Lookup" on `[Source_code] = [Source Code (sc)]`
  - "Source Lookup" ↔ "country_reference" on `[Region of Origin - Country] = [country_name]`
- **Athena tables read:** `fact_external_db.omniture_event_fact`, `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `reference_external_db.pib_product_dimension`, `dimension_external_db.pib_territory_dimension`, `reference_external_db.country_reference`
- **SQL files:** [Custom SQL Query.sql](Custom%20SQL%20Query.sql), [Lang config.sql](Lang%20config.sql)

## Connected workbooks

- [Entity Link Usage](../../../B2B%20Product/Entity%20Link%20Usage) [B2B / B2B Product]
