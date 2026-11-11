# B2B Marketing Paid Media Dataset

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Marketing / Datasources |
| Owner | Maria Peco |
| Created | 2025-07-28 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/123012490 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Relationship model: 3 logical tables (with joins inside) -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Structure:**

```
Logical table "Opportunity-Campaign Data"
  - LEFT JOIN on [Custom SQL Query].[company_industry] = [R&C Prop Mapping].[Industry]
    - FULL JOIN on [Custom SQL Query].[geo_region] = [Cost Mapping].[Region] AND [Custom SQL Query].[campaign_category_main] = [Cost Mapping].[Search_Engine]
      - Athena Custom SQL "Custom SQL Query" -> Custom SQL Query.sql
      - Google Drive Excel "R&C Paid Media Campaigns" table Cost Mapping$ (as "Cost Mapping")
    - Google Drive Excel "R&C Proposition Mapping SPB" table Sheet1$ (as "R&C Prop Mapping")
Logical table "Campaign Member"
  - Athena Custom SQL "Custom SQL Query1" -> Custom SQL Query1.sql
Logical table "pib_meeting_summar"
  - Athena table dimension_external_db.pib_meeting_summary (as "pib_meeting_summar")
```

- **Relationships:**
  - "Opportunity-Campaign Data" ↔ "Campaign Member" on `[sfdc_campaign_id (Custom SQL Query)] = [campaign_id]`
  - "Opportunity-Campaign Data" ↔ "pib_meeting_summar" on `[pib_opportunity_sfdc_id] = [pib_opportunity_sfdc_id (pib_meeting_summar)]`
- **Athena tables read:** `dimension_external_db.pib_opportunity_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_contact_dimension`, `reference_external_db.date_dimension`, `dimension_external_db.pib_product_services_dimension`, `dimension_external_db.pib_territory_dimension`, `dimension_external_db.pib_user_dimension`, `reference_external_db.fx_rates_current`, `sandbox_spb.pib_campaign_hierarchy`, `dimension_external_db.pib_campaign_dimension`, `dimension_external_db.pib_campaign_influence`, `dimension_external_db.pib_campaign_member_dimension`, `sandbox_spb.paid_media_campaigns`, `dimension_external_db.pib_leads_dimension`, `dimension_external_db.pib_meeting_summary`
- **SQL files:** [Custom SQL Query.sql](Custom%20SQL%20Query.sql), [Custom SQL Query1.sql](Custom%20SQL%20Query1.sql)

## Connected workbooks

- [B2B R&C SEM Dashboard](../../B2B%20R%26C%20SEM%20Dashboard) [B2B / B2B Marketing]
