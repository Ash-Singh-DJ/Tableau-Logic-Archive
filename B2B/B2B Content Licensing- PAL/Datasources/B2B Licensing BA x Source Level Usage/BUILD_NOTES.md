# B2B Licensing BA x Source Level Usage

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Content Licensing- PAL / Datasources |
| Owner | Ashish Kumar |
| Created | 2025-07-28 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/138096890 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Structure:**

```
- Athena Custom SQL "BA x Source Level Usage" -> BA x Source Level Usage.sql
```
- **Athena tables read:** `dimension_external_db.cdb_source_docs_current`, `fact_external_db.omniture_event_fact`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `reference_external_db.pib_product_dimension`, `dimension_external_db.pib_territory_dimension`, `dimension_external_db.ip_rights_data_current`, `reference_external_db.country_reference`
- **SQL files:** [BA x Source Level Usage.sql](BA%20x%20Source%20Level%20Usage.sql)

## Connected workbooks

- B2B Licensing Dashboard [B2B / B2B Content Licensing- PAL]
