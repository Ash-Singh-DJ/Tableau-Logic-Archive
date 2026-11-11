# B2B Marketing Events Dataset - Test

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Marketing / Datasources |
| Owner | Maria Peco |
| Created | 2025-10-08 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/168990047 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Relationship model: 3 logical tables
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Structure:**

```
Logical table "Opportunity-Campaign Data"
  - Athena Custom SQL "Custom SQL Query" -> Custom SQL Query.sql
Logical table "Campaign Member"
  - Athena Custom SQL "Custom SQL Query1" -> Custom SQL Query1.sql
Logical table "pib_meeting_summar"
  - Athena table dimension_external_db.pib_meeting_summary (as "pib_meeting_summar")
```

- **Relationships:**
  - "Opportunity-Campaign Data" ↔ "Campaign Member" on `[sfdc_campaign_id (Custom SQL Query)] = [campaign_id]`
  - "Opportunity-Campaign Data" ↔ "pib_meeting_summar" on `[pib_opportunity_sfdc_id] = [pib_opportunity_sfdc_id (pib_meeting_summar)] AND [event_date] <= [meeting_date]`
- **Athena tables read:** `dimension_external_db.pib_opportunity_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_contact_dimension`, `reference_external_db.date_dimension`, `dimension_external_db.pib_product_services_dimension`, `dimension_external_db.pib_territory_dimension`, `dimension_external_db.pib_user_dimension`, `reference_external_db.fx_rates_current`, `sandbox_spb.pib_campaign_hierarchy`, `dimension_external_db.pib_campaign_dimension`, `dimension_external_db.pib_campaign_influence`, `dimension_external_db.pib_campaign_member_dimension`, `google_sheets_db.event_campaign_children`, `dimension_external_db.pib_leads_dimension`, `dimension_external_db.pib_meeting_summary`
- **SQL files:** [Custom SQL Query.sql](Custom%20SQL%20Query.sql), [Custom SQL Query1.sql](Custom%20SQL%20Query1.sql)

## Connected workbooks

- B2B Events Dashboard - Testing [B2B / B2B Testing]
