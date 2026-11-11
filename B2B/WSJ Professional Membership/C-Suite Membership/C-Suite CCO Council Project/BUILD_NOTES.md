# C-Suite CCO Council Project

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / WSJ Professional Membership / C-Suite Membership |
| Owner | Maria Peco |
| Created | 2025-07-24 |
| Last updated | 2026-02-09 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/3072258 |
| Archived | 2026-11-11 |

## Summary

3 data source(s) in the workbook; 3 with an Athena component (0 embedded, 3 published).

## "dimension_external_db" (published data source)

- **Published source:** "C-Suite Membership Datasource" in `B2B / WSJ Professional Membership / C-Suite Membership / Data Sources`, owner Maria Peco; [archived here](../Data%20Sources/C-Suite%20Membership%20Datasource). The SQL below is copied from it.
- **Shape:** Empty (connection defined, no tables or Custom SQL)
- **Extract:** no (live)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** _none (data source is unused in this workbook)_
- **Structure:**

```
```
- **SQL files:** _none -- Athena is read as plain table(s), no Custom SQL_

## "Custom SQL Query+ (sandbox_pecom)" (published data source)

- **Published source:** "CCO Datasource" in `B2B / WSJ Professional Membership / C-Suite Membership / Data Sources`, owner Maria Peco; [archived here](../Data%20Sources/CCO%20Datasource). The SQL below is copied from it.
- **Shape:** Relationship model: 4 logical tables
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / sandbox_pecom)
- **Used by worksheets:** All Created Opportunities, CCO Created Opportunity Value, CCO Created Opportunity Value + Current Revenue, CCO Created Opportunity Value pivot, CCO Events, Campaign Influence, Job Title Category, Job Titles, Opp+Revenue Drill/Down, Opportunity Drill-down, Opportunity Drill-down pivot, Sheet 1, Sheet 13, Sheet 14, Sheet 18, Sheet 2, Sheet 3, events
- **Structure:**

```
Logical table "opp_data"
  - Athena Custom SQL "opp_rev_data" -> Custom SQL Query+ (sandbox_pecom) - opp_rev_data.sql
Logical table "Campaign Influence"
  - Athena Custom SQL "campaign_influence" -> Custom SQL Query+ (sandbox_pecom) - campaign_influence.sql
Logical table "lead_campaign"
  - Athena Custom SQL "Custom SQL Query" -> Custom SQL Query+ (sandbox_pecom) - Custom SQL Query.sql
Logical table "csuite_contacts"
  - Athena Custom SQL "csuite_contacts" -> Custom SQL Query+ (sandbox_pecom) - csuite_contacts.sql
```

- **Relationships:**
  - "lead_campaign" ↔ "opp_data" on `[account_id] = [company_sfdc_id]`
  - "opp_data" ↔ "Campaign Influence" on `[opp_crm_id] = [pib_opportunity_sfdc_id]`
  - "lead_campaign" ↔ "csuite_contacts" on `[email] = [csuite_email]`
- **Athena tables read:** `dimension_external_db.pib_opportunity_dimension`, `reference_external_db.fx_rates_current`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_territory_dimension`, `dimension_external_db.pib_user_dimension`, `sandbox_hvc.date_alignment`, `sandbox_hvc.rev_b2b`, `dimension_external_db.pib_product_services_dimension`, `sandbox_hvc.prod_master`, `dnb_firmographic_db.company_information_current`, `dnb_firmographic_db.corporate_linkage_current`, `dimension_external_db.pib_corporate_dimension`, `dimension_external_db.pib_campaign_dimension`, `dimension_external_db.pib_campaign_influence`, `csuite_external_db.event`, `csuite_external_db.event_customfielddetail`, `dimension_external_db.pib_campaign_member_dimension`, `dimension_external_db.pib_contact_dimension`, `dimension_external_db.pib_leads_dimension`, `dimension_external_db.pib_membership_dimension`, `sandbox_mk.1p_job_function_department_code_mapping`, `csuite_external_db.cvent_contact`, `csuite_external_db.registration`
- **SQL files:** [Custom SQL Query+ (sandbox_pecom) - opp_rev_data.sql](Custom%20SQL%20Query%2B%20%28sandbox_pecom%29%20-%20opp_rev_data.sql), [Custom SQL Query+ (sandbox_pecom) - campaign_influence.sql](Custom%20SQL%20Query%2B%20%28sandbox_pecom%29%20-%20campaign_influence.sql), [Custom SQL Query+ (sandbox_pecom) - Custom SQL Query.sql](Custom%20SQL%20Query%2B%20%28sandbox_pecom%29%20-%20Custom%20SQL%20Query.sql), [Custom SQL Query+ (sandbox_pecom) - csuite_contacts.sql](Custom%20SQL%20Query%2B%20%28sandbox_pecom%29%20-%20csuite_contacts.sql)

## "Campaign Influence" (published data source)

- **Published source:** "CCO Membership Campaign Influence" in `B2B / WSJ Professional Membership / C-Suite Membership / Data Sources`, owner Maria Peco; [archived here](../Data%20Sources/CCO%20Membership%20Campaign%20Influence). The SQL below is copied from it.
- **Shape:** Relationship model: 2 logical tables
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Sheet 19, Sheet 20
- **Structure:**

```
Logical table "opportunities"
  - Athena Custom SQL "Custom SQL Query1" -> Campaign Influence - Custom SQL Query1.sql
Logical table "campaign_influence"
  - Athena Custom SQL "Custom SQL Query" -> Campaign Influence - Custom SQL Query.sql
```

- **Relationships:**
  - "campaign_influence" ↔ "opportunities" on `[opportunity_id] = [pib_opportunity_sfdc_id]`
- **Athena tables read:** `dimension_external_db.pib_opportunity_dimension`, `dimension_external_db.pib_product_services_dimension`, `reference_external_db.fx_rates_current`, `dimension_external_db.pib_campaign_dimension`, `dimension_external_db.pib_campaign_influence`, `csuite_external_db.event`, `csuite_external_db.event_customfielddetail`
- **SQL files:** [Campaign Influence - Custom SQL Query1.sql](Campaign%20Influence%20-%20Custom%20SQL%20Query1.sql), [Campaign Influence - Custom SQL Query.sql](Campaign%20Influence%20-%20Custom%20SQL%20Query.sql)
