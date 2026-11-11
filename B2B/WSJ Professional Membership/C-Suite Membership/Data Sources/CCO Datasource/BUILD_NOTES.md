# CCO Datasource

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / WSJ Professional Membership / C-Suite Membership / Data Sources |
| Owner | Maria Peco |
| Created | 2025-07-24 |
| Last updated | 2026-07-06 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/126559379 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Relationship model: 4 logical tables
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / sandbox_pecom)
- **Structure:**

```
Logical table "opp_data"
  - Athena Custom SQL "opp_rev_data" -> opp_rev_data.sql
Logical table "Campaign Influence"
  - Athena Custom SQL "campaign_influence" -> campaign_influence.sql
Logical table "lead_campaign"
  - Athena Custom SQL "Custom SQL Query" -> Custom SQL Query.sql
Logical table "csuite_contacts"
  - Athena Custom SQL "csuite_contacts" -> csuite_contacts.sql
```

- **Relationships:**
  - "lead_campaign" ↔ "opp_data" on `[account_id] = [company_sfdc_id]`
  - "opp_data" ↔ "Campaign Influence" on `[opp_crm_id] = [pib_opportunity_sfdc_id]`
  - "lead_campaign" ↔ "csuite_contacts" on `[email] = [csuite_email]`
- **Athena tables read:** `dimension_external_db.pib_opportunity_dimension`, `reference_external_db.fx_rates_current`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_territory_dimension`, `dimension_external_db.pib_user_dimension`, `sandbox_hvc.date_alignment`, `sandbox_hvc.rev_b2b`, `dimension_external_db.pib_product_services_dimension`, `sandbox_hvc.prod_master`, `dnb_firmographic_db.company_information_current`, `dnb_firmographic_db.corporate_linkage_current`, `dimension_external_db.pib_corporate_dimension`, `dimension_external_db.pib_campaign_dimension`, `dimension_external_db.pib_campaign_influence`, `csuite_external_db.event`, `csuite_external_db.event_customfielddetail`, `dimension_external_db.pib_campaign_member_dimension`, `dimension_external_db.pib_contact_dimension`, `dimension_external_db.pib_leads_dimension`, `dimension_external_db.pib_membership_dimension`, `sandbox_mk.1p_job_function_department_code_mapping`, `csuite_external_db.cvent_contact`, `csuite_external_db.registration`
- **SQL files:** [opp_rev_data.sql](opp_rev_data.sql), [campaign_influence.sql](campaign_influence.sql), [Custom SQL Query.sql](Custom%20SQL%20Query.sql), [csuite_contacts.sql](csuite_contacts.sql)

## Connected workbooks

- [C-Suite CCO Council Project](../../C-Suite%20CCO%20Council%20Project) [B2B / WSJ Professional Membership / C-Suite Membership]
