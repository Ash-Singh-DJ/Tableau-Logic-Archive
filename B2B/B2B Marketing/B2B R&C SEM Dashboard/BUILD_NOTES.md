# B2B R&C SEM Dashboard

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Marketing |
| Owner | Steve Bishop |
| Created | 2025-07-28 |
| Last updated | 2025-08-21 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/3088195 |
| Archived | 2026-11-11 |

## Summary

1 data source(s) in the workbook; 1 with an Athena component (0 embedded, 1 published).

## "Marketing Paid Media Dataset" (published data source)

- **Published source:** "B2B Marketing Paid Media Dataset" in `B2B / B2B Marketing / Datasources`, owner Maria Peco; [archived here](../Datasources/B2B%20Marketing%20Paid%20Media%20Dataset). The SQL below is copied from it.
- **Shape:** Relationship model: 3 logical tables (with joins inside) -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Used by worksheets:** Campaigns Ranked by Revenue, Contacts & Leads, Deal Velocity, Leads & Contacts, Meeting Details, Meetings, Opp/PS Table, Opportunities, Opportunity Revenue, Products Pitched, SEM Ranked by Revenue, Sheet 15, Sheet 16, Total ROI, Total Spend
- **Structure:**

```
Logical table "Opportunity-Campaign Data"
  - LEFT JOIN on [Custom SQL Query].[company_industry] = [R&C Prop Mapping].[Industry]
    - FULL JOIN on [Custom SQL Query].[geo_region] = [Cost Mapping].[Region] AND [Custom SQL Query].[campaign_category_main] = [Cost Mapping].[Search_Engine]
      - Athena Custom SQL "Custom SQL Query" -> Marketing Paid Media Dataset - Custom SQL Query.sql
      - Google Drive Excel "R&C Paid Media Campaigns" table Cost Mapping$ (as "Cost Mapping")
    - Google Drive Excel "R&C Proposition Mapping SPB" table Sheet1$ (as "R&C Prop Mapping")
Logical table "Campaign Member"
  - Athena Custom SQL "Custom SQL Query1" -> Marketing Paid Media Dataset - Custom SQL Query1.sql
Logical table "pib_meeting_summar"
  - Athena table dimension_external_db.pib_meeting_summary (as "pib_meeting_summar")
```

- **Relationships:**
  - "Opportunity-Campaign Data" ↔ "Campaign Member" on `[sfdc_campaign_id (Custom SQL Query)] = [campaign_id]`
  - "Opportunity-Campaign Data" ↔ "pib_meeting_summar" on `[pib_opportunity_sfdc_id] = [pib_opportunity_sfdc_id (pib_meeting_summar)]`
- **Athena tables read:** `dimension_external_db.pib_opportunity_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_contact_dimension`, `reference_external_db.date_dimension`, `dimension_external_db.pib_product_services_dimension`, `dimension_external_db.pib_territory_dimension`, `dimension_external_db.pib_user_dimension`, `reference_external_db.fx_rates_current`, `sandbox_spb.pib_campaign_hierarchy`, `dimension_external_db.pib_campaign_dimension`, `dimension_external_db.pib_campaign_influence`, `dimension_external_db.pib_campaign_member_dimension`, `sandbox_spb.paid_media_campaigns`, `dimension_external_db.pib_leads_dimension`, `dimension_external_db.pib_meeting_summary`
- **SQL files:** [Marketing Paid Media Dataset - Custom SQL Query.sql](Marketing%20Paid%20Media%20Dataset%20-%20Custom%20SQL%20Query.sql), [Marketing Paid Media Dataset - Custom SQL Query1.sql](Marketing%20Paid%20Media%20Dataset%20-%20Custom%20SQL%20Query1.sql)
