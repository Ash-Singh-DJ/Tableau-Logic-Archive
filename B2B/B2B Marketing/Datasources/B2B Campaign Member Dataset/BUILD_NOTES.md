# B2B Campaign Member Dataset

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Marketing / Datasources |
| Owner | Maria Peco |
| Created | 2025-07-28 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/152596224 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Relationship model: 2 logical tables
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Structure:**

```
Logical table "Migrated Data"
  - Athena Custom SQL "Campaign Members" -> Campaign Members.sql
Logical table "Custom SQL Query"
  - Athena Custom SQL "Custom SQL Query" -> Custom SQL Query.sql
```

- **Relationships:**
  - "Migrated Data" ↔ "Custom SQL Query" on `IF ISNULL([contact_id]) THEN [lead_id] ELSE [contact_id] END = IF ISNULL([contact_sfdc_id]) THEN [lead_sfdc_id] ELSE [contact_sfdc_id] END`
- **Athena tables read:** `sandbox_spb.pib_campaign_hierarchy`, `dimension_external_db.pib_campaign_dimension`, `dimension_external_db.pib_campaign_member_dimension`, `dimension_external_db.pib_leads_dimension`, `dimension_external_db.pib_contact_dimension`, `dimension_external_db.pib_user_dimension`, `dimension_external_db.pib_marketing_interaction_dimension`
- **SQL files:** [Campaign Members.sql](Campaign%20Members.sql), [Custom SQL Query.sql](Custom%20SQL%20Query.sql)

## Connected workbooks

- B2B Funnel + Lead + Campaign Member Dashboard (remove ds) [B2B / B2B Testing]
