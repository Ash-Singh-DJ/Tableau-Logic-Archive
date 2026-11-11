# B2B Eloqua Forms - Snapshots Test

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Marketing / Datasources |
| Owner | Maria Peco |
| Created | 2026-01-15 |
| Last updated | 2026-01-15 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/123245887 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Relationship model: 2 logical tables
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Structure:**

```
Logical table "funnel"
  - Athena Custom SQL "Custom SQL Query" -> Custom SQL Query.sql
Logical table "opps"
  - Athena Custom SQL "opportunities" -> opportunities.sql
```

- **Relationships:**
  - "funnel" ↔ "opps" on `[account_join_id] = [company_sfdc_id] AND [submitted_date] <= date([opportunity_open_date])`
- **Athena tables read:** `dimension_external_db.pib_marketing_interaction_dimension`, `dimension_external_db.pib_leads_dimension`, `dimension_external_db.pib_campaign_dimension`, `dimension_external_db.pib_leads_dimension_history`, `dimension_external_db.pib_contact_dimension`, `dimension_external_db.pib_user_dimension`, `dimension_external_db.pib_opportunity_dimension_history`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_territory_dimension`, `dimension_external_db.pib_product_services_dimension`, `reference_external_db.fx_rates_current`
- **SQL files:** [Custom SQL Query.sql](Custom%20SQL%20Query.sql), [opportunities.sql](opportunities.sql)

## Connected workbooks

_No connected workbooks found._
