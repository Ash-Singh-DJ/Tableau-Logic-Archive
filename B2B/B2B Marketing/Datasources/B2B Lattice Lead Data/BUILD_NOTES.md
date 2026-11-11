# B2B Lattice Lead Data

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Marketing / Datasources |
| Owner | svc_dj tableaucdl_b2b |
| Created | 2025-07-29 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/132389459 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Relationship model: 2 logical tables
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Structure:**

```
Logical table "Addl Opp Data"
  - Athena Custom SQL "Custom SQL Query1" -> Custom SQL Query1.sql
Logical table "Lead Data"
  - Athena Custom SQL "Custom SQL Query" -> Custom SQL Query.sql
```

- **Relationships:**
  - "Lead Data" ↔ "Addl Opp Data" on `[pib_opportunity_sfdc_id] = [pib_opportunity_sfdc_id (Custom SQL Query1)]`
- **Athena tables read:** `dimension_external_db.pib_opportunity_dimension`, `dimension_external_db.pib_product_services_dimension`, `reference_external_db.pib_product_dimension`, `reference_external_db.fx_rates_current`, `dimension_external_db.pib_leads_dimension_history`, `dimension_external_db.pib_leads_dimension`, `dimension_external_db.pib_contact_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [Custom SQL Query1.sql](Custom%20SQL%20Query1.sql), [Custom SQL Query.sql](Custom%20SQL%20Query.sql)

## Connected workbooks

_No connected workbooks found._
