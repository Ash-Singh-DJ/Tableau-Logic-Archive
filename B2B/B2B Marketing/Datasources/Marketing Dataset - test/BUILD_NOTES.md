# Marketing Dataset - test

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Marketing / Datasources |
| Owner | Maria Peco |
| Created | 2026-01-15 |
| Last updated | 2026-01-15 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/123220685 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Relationship model: 4 logical tables (with joins inside) -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Structure:**

```
Logical table "Lead Contact Data"
  - LEFT JOIN on [Marketing Dataset].[company_industry] = [Fin Corp Industry Mapping1].[SFDC Industry]
    - Athena Custom SQL "Marketing Dataset" -> Marketing Dataset.sql
    - Google Drive Excel "Grouped Industry Mapping" table Sheet1$ (as "Fin Corp Industry Mapping1")
Logical table "Campaign Data"
  - Athena Custom SQL "Custom SQL Query" -> Custom SQL Query.sql
Logical table "UTM Data (Arrays)"
  - Athena Custom SQL "Custom SQL Query2" -> Custom SQL Query2.sql
Logical table "UTM Data"
  - Athena Custom SQL "Custom SQL Query1" -> Custom SQL Query1.sql
```

- **Relationships:**
  - "Lead Contact Data" ↔ "Campaign Data" on `IF ISNULL([contact_sfdc_id]) THEN [lead_sfdc_id] ELSE [contact_sfdc_id] END = IF ISNULL([contact_sfdc_id (Custom SQL Query)]) THEN [lead_sfdc_id (Custom SQL Query)] ELSE [contact_sfdc_id (Custom SQL Query)] END`
  - "Lead Contact Data" ↔ "UTM Data (Arrays)" on `IF ISNULL([contact_sfdc_id]) THEN [lead_sfdc_id] ELSE [contact_sfdc_id] END = IF ISNULL([contact_sfdc_id (Custom SQL Query2)]) THEN [lead_sfdc_id (Custom SQL Query2)] ELSE [contact_sfdc_id (Custom SQL Query2)] END`
  - "Lead Contact Data" ↔ "UTM Data" on `IF ISNULL([contact_sfdc_id]) THEN [lead_sfdc_id] ELSE [contact_sfdc_id] END = IF ISNULL([contact_sfdc_id (Custom SQL Query1)]) THEN [lead_sfdc_id (Custom SQL Query1)] ELSE [contact_sfdc_id (Custom SQL Query1)] END`
- **Athena tables read:** `dimension_external_db.pib_leads_dimension_history`, `csuite_external_db.eloqua_contact_history`, `zoolander_db.eloqua_contacts_rating_factiva`, `zoolander_db.eloqua_contacts_rating_newswires`, `zoolander_db.eloqua_contacts_rating_rnc_corporate`, `zoolander_db.eloqua_contacts_rating_rnc_financial`, `dimension_external_db.pib_user_dimension`, `dimension_external_db.pib_territory_dimension`, `dimension_external_db.pib_opportunity_dimension`, `dimension_external_db.pib_leads_dimension`, `dimension_external_db.pib_contact_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_product_services_dimension`, `reference_external_db.pib_product_dimension`, `reference_external_db.fx_rates_current`, `dimension_external_db.pib_campaign_dimension`, `dimension_external_db.pib_campaign_member_dimension`, `sandbox_spb.pib_campaign_hierarchy`, `dimension_external_db.pib_marketing_interaction_dimension`
- **SQL files:** [Marketing Dataset.sql](Marketing%20Dataset.sql), [Custom SQL Query.sql](Custom%20SQL%20Query.sql), [Custom SQL Query2.sql](Custom%20SQL%20Query2.sql), [Custom SQL Query1.sql](Custom%20SQL%20Query1.sql)

## Connected workbooks

_No connected workbooks found._
