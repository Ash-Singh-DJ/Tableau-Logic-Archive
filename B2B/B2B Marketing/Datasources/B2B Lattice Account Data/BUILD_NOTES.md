# B2B Lattice Account Data

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Marketing / Datasources |
| Owner | svc_dj tableaucdl_b2b |
| Created | 2025-07-28 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/132398236 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Relationship model: 2 logical tables
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Structure:**

```
Logical table "Lattice Account Data"
  - Athena Custom SQL "Lattice Account Data" -> Lattice Account Data.sql
Logical table "Addl Opp Data"
  - Athena Custom SQL "Custom SQL Query" -> Custom SQL Query.sql
```

- **Relationships:**
  - "Lattice Account Data" ↔ "Addl Opp Data" on `[pib_opportunity_sfdc_id] = [pib_opportunity_sfdc_id (Custom SQL Query)]`
- **Athena tables read:** `dimension_external_db.pib_opportunity_dimension`, `dimension_external_db.pib_product_services_dimension`, `reference_external_db.pib_product_dimension`, `reference_external_db.fx_rates_current`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_territory_dimension`
- **SQL files:** [Lattice Account Data.sql](Lattice%20Account%20Data.sql), [Custom SQL Query.sql](Custom%20SQL%20Query.sql)

## Connected workbooks

_No connected workbooks found._
