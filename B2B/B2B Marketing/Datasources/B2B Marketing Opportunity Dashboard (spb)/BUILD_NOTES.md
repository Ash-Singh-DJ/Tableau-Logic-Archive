# B2B Marketing Opportunity Dashboard (spb)

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Marketing / Datasources |
| Owner | Maria Peco |
| Created | 2025-07-28 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/106742501 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Relationship model: 2 logical tables
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Structure:**

```
Logical table "UTM Data"
  - Athena Custom SQL "Custom SQL Query1" -> Custom SQL Query1.sql
Logical table "Primary Opp-Campaign Dataset"
  - Athena Custom SQL "Custom SQL Query" -> Custom SQL Query.sql
```

- **Relationships:**
  - "Primary Opp-Campaign Dataset" ↔ "UTM Data" on `[opp_contact_sfdc_id] = [contact_sfdc_id]`
- **Athena tables read:** `dimension_external_db.pib_marketing_interaction_dimension`, `dimension_external_db.pib_leads_dimension`, `dimension_external_db.pib_opportunity_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_contact_dimension`, `reference_external_db.date_dimension`, `dimension_external_db.pib_product_services_dimension`, `dimension_external_db.pib_territory_dimension`, `dimension_external_db.pib_user_dimension`, `reference_external_db.fx_rates_current`, `sandbox_spb.pib_campaign_hierarchy`, `dimension_external_db.pib_campaign_dimension`, `dimension_external_db.pib_campaign_influence`, `dimension_external_db.pib_campaign_member_dimension`, `dimension_external_db.pib_opportunity_dimension_history`, `dimension_external_db.pib_product_services_dimension_history`, `dimension_external_db.pib_campaign_influence_history`, `dimension_external_db.pib_campaign_member_dimension_history`, `dimension_external_db.pib_contact_dimension_history`, `dimension_external_db.pib_campaign_dimension_history`
- **SQL files:** [Custom SQL Query1.sql](Custom%20SQL%20Query1.sql), [Custom SQL Query.sql](Custom%20SQL%20Query.sql)

## Connected workbooks

- B2B Marketing Opportunity Dashboard (UTM) [B2B / B2B Marketing]
- B2B Marketing Opportunity Dashboard (UTM) - Testing [B2B / B2B Testing]
- plus 1 workbook(s) we do not have permission to see
