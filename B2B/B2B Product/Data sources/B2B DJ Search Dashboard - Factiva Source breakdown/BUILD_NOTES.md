# B2B DJ Search Dashboard - Factiva Source breakdown

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Product / Data sources |
| Owner | James Thomson |
| Created | 2025-09-15 |
| Last updated | 2026-07-06 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/98535765 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Relationship model: 4 logical tables -- Athena + Google Drive Excel + Excel file
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / reference_external_db); Excel file; Google Drive Excel
- **Structure:**

```
Logical table "Source Sheet"
  - Excel file "Data for Tableau Factiva Source Dashboard 2025-06-02" table 9453_20250602$ (as "9453_20250602")
Logical table "Bands"
  - Google Drive Excel "Band Look up" table Bands$ (as "Bands")
Logical table "Custom SQL Query"
  - Athena Custom SQL "Custom SQL Query" -> Custom SQL Query.sql
Logical table "country_reference"
  - Athena table reference_external_db.country_reference (as "country_reference")
```

- **Relationships:**
  - "Custom SQL Query" ↔ "Source Sheet" on `[Source_code] = [Source Code (sc)]`
  - "Custom SQL Query" ↔ "Bands" on `[Source_code] = [Source Code]`
  - "Source Sheet" ↔ "country_reference" on `[Region of Origin - Country] = [country_name]`
- **Athena tables read:** `fact_external_db.omniture_event_fact`, `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `reference_external_db.pib_product_dimension`, `dimension_external_db.pib_territory_dimension`, `reference_external_db.country_reference`
- **SQL files:** [Custom SQL Query.sql](Custom%20SQL%20Query.sql)

## Connected workbooks

- [Entity Link Usage](../../Entity%20Link%20Usage) [B2B / B2B Product]
