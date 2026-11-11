# B2B Eloqua Forms - Test

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Marketing / Datasources |
| Owner | Maria Peco |
| Created | 2025-10-31 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/107643232 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Relationship model: 5 logical tables
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / sandbox_pecom)
- **Structure:**

```
Logical table "wide_net"
  - Athena Custom SQL "wide_net" -> wide_net.sql
Logical table "opps"
  - Athena Custom SQL "opps" -> opps.sql
Logical table "date_opps"
  - Athena Custom SQL "date_opps" -> date_opps.sql
Logical table "funnel"
  - Athena Custom SQL "funnel" -> funnel.sql
Logical table "date_forms"
  - Athena Custom SQL "date_froms" -> date_froms.sql
```

- **Relationships:**
  - "funnel" ↔ "wide_net" on `[company_sfdc_id] = [company_sfdc_id (Custom SQL Query) #1]`
  - "funnel" ↔ "opps" on `[pib_opportunity_sfdc_id] = [opp_crm_id]`
  - "opps" ↔ "date_opps" on `[cycle_date] = [date_opp]`
  - "funnel" ↔ "date_forms" on `[submitted_date] = [date_form]`
- **Athena tables read:** `sandbox_pecom.wide_net`, `reference_external_db.fx_rates_current`, `reference_external_db.fx_rates_history`, `dimension_external_db.pib_opportunity_dimension_history`, `dimension_external_db.pib_product_services_dimension_history`, `sandbox_hvc.ftva_prod_override`, `sandbox_hvc.nwrs_prod_override`, `sandbox_hvc.rnc_prod_override`, `dimension_external_db.pib_product_service_attributes`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_territory_dimension`, `dimension_external_db.pib_user_dimension`, `reference_external_db.date_dimension`, `dimension_external_db.pib_marketing_interaction_dimension`, `dimension_external_db.pib_leads_dimension`, `dimension_external_db.pib_campaign_dimension`, `dimension_external_db.pib_leads_dimension_history`, `csuite_external_db.eloqua_contact_history`, `zoolander_db.eloqua_contacts_rating_factiva`, `zoolander_db.eloqua_contacts_rating_newswires`, `zoolander_db.eloqua_contacts_rating_rnc_corporate`, `zoolander_db.eloqua_contacts_rating_rnc_financial`, `dimension_external_db.pib_opportunity_dimension`, `dimension_external_db.pib_contact_dimension`, `dimension_external_db.pib_product_services_dimension`, `reference_external_db.pib_product_dimension`
- **SQL files:** [wide_net.sql](wide_net.sql), [opps.sql](opps.sql), [date_opps.sql](date_opps.sql), [funnel.sql](funnel.sql), [date_froms.sql](date_froms.sql)

## Connected workbooks

_No connected workbooks found._
- plus 1 workbook(s) we do not have permission to see
