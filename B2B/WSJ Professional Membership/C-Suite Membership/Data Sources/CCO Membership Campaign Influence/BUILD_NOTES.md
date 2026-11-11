# CCO Membership Campaign Influence

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / WSJ Professional Membership / C-Suite Membership / Data Sources |
| Owner | Maria Peco |
| Created | 2025-07-24 |
| Last updated | 2026-07-06 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/136375739 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Relationship model: 2 logical tables
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Structure:**

```
Logical table "opportunities"
  - Athena Custom SQL "Custom SQL Query1" -> Custom SQL Query1.sql
Logical table "campaign_influence"
  - Athena Custom SQL "Custom SQL Query" -> Custom SQL Query.sql
```

- **Relationships:**
  - "campaign_influence" ↔ "opportunities" on `[opportunity_id] = [pib_opportunity_sfdc_id]`
- **Athena tables read:** `dimension_external_db.pib_opportunity_dimension`, `dimension_external_db.pib_product_services_dimension`, `reference_external_db.fx_rates_current`, `dimension_external_db.pib_campaign_dimension`, `dimension_external_db.pib_campaign_influence`, `csuite_external_db.event`, `csuite_external_db.event_customfielddetail`
- **SQL files:** [Custom SQL Query1.sql](Custom%20SQL%20Query1.sql), [Custom SQL Query.sql](Custom%20SQL%20Query.sql)

## Connected workbooks

- [C-Suite CCO Council Project](../../C-Suite%20CCO%20Council%20Project) [B2B / WSJ Professional Membership / C-Suite Membership]
