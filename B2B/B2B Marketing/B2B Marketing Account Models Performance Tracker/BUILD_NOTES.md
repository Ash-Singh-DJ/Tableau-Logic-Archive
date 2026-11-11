# B2B Marketing Account Models Performance Tracker

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Marketing |
| Owner | Porfirio Hernandez |
| Created | 2025-07-27 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/3083919 |
| Archived | 2026-11-11 |

## Summary

4 data source(s) in the workbook; 3 with an Athena component (3 embedded, 0 published).
Other data sources: "Account Models Feature Importances - Sheet2" (Google Drive CSV).

## "SQL Query Feat Importances" (embedded)

- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / zoolander_db)
- **Used by worksheets:** Top Features
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> SQL Query Feat Importances.sql
```
- **Athena tables read:** `zoolander_db.account_model_factiva_feat_importance`, `zoolander_db.account_model_newswires_feat_importance`, `zoolander_db.account_model_rnc_corporate_feat_importance`, `zoolander_db.account_model_rnc_financial_feat_importance`
- **SQL files:** [SQL Query Feat Importances.sql](SQL%20Query%20Feat%20Importances.sql)

## "Lead Data" (embedded)

- **Shape:** Relationship model: 2 logical tables
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Base Rates, Closed Opps (Leads), Distinct Contacts FY24, Individual Leads All, Individual Leads Corr, Individual Leads Old, Opened Opps (Leads), Opened Opps (Leads) Old, Performance (Opened Opps), Product-Specific Opened Opps (Leads), Qualified Leads, Qualified Leads Old, Sheet 24
- **Structure:**

```
Logical table "Lead Data"
  - Athena Custom SQL "Custom SQL Query" -> Lead Data - Custom SQL Query.sql
Logical table "Addl Opp Data"
  - Athena Custom SQL "Custom SQL Query1" -> Lead Data - Custom SQL Query1.sql
```

- **Relationships:**
  - "Lead Data" ↔ "Addl Opp Data" on `[pib_opportunity_sfdc_id] = [pib_opportunity_sfdc_id (Custom SQL Query1)]`
- **Athena tables read:** `dimension_external_db.pib_leads_dimension_history`, `csuite_external_db.eloqua_contact_history`, `zoolander_db.eloqua_contacts_rating_factiva`, `zoolander_db.eloqua_contacts_rating_newswires`, `zoolander_db.eloqua_contacts_rating_rnc_corporate`, `zoolander_db.eloqua_contacts_rating_rnc_financial`, `dimension_external_db.pib_opportunity_dimension`, `dimension_external_db.pib_product_services_dimension`, `reference_external_db.pib_product_dimension`, `reference_external_db.fx_rates_current`, `dimension_external_db.pib_leads_dimension`, `dimension_external_db.pib_contact_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_user_dimension`
- **SQL files:** [Lead Data - Custom SQL Query.sql](Lead%20Data%20-%20Custom%20SQL%20Query.sql), [Lead Data - Custom SQL Query1.sql](Lead%20Data%20-%20Custom%20SQL%20Query1.sql)

## "Account Data" (embedded)

- **Shape:** Relationship model: 3 logical tables
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Account Base, Closed Opps, Closed Opps vs Base Rate, Opened Opps, opened opportunities, opened opportunities agg, opened opportunities general, opened opportunities prod line
- **Structure:**

```
Logical table "Additional Opp Data"
  - Athena Custom SQL "Custom SQL Query1" -> Account Data - Custom SQL Query1.sql
Logical table "Total Number of Scored Accounts"
  - Athena Custom SQL "Custom SQL Query2" -> Account Data - Custom SQL Query2.sql
Logical table "account_models_data"
  - Athena Custom SQL "Custom SQL Query" -> Account Data - Custom SQL Query.sql
```

- **Relationships:**
  - "account_models_data" ↔ "Additional Opp Data" on `[pib_opportunity_sfdc_id] = [pib_opportunity_sfdc_id (Custom SQL Query1)]`
  - "account_models_data" ↔ "Total Number of Scored Accounts" on `[company_sfdc_id] = [sfdc_id]`
- **Athena tables read:** `dimension_external_db.pib_opportunity_dimension`, `dimension_external_db.pib_product_services_dimension`, `reference_external_db.pib_product_dimension`, `reference_external_db.fx_rates_current`, `zoolander_db.pib_account_model_newswires`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_territory_dimension`, `zoolander_db.pib_account_model_factiva`, `zoolander_db.pib_account_model_rnc_corporate`, `zoolander_db.pib_account_model_rnc_financial`
- **SQL files:** [Account Data - Custom SQL Query1.sql](Account%20Data%20-%20Custom%20SQL%20Query1.sql), [Account Data - Custom SQL Query2.sql](Account%20Data%20-%20Custom%20SQL%20Query2.sql), [Account Data - Custom SQL Query.sql](Account%20Data%20-%20Custom%20SQL%20Query.sql)
