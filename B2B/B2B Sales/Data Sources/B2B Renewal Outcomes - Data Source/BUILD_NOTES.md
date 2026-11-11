# B2B Renewal Outcomes - Data Source

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Sales / Data Sources |
| Owner | Maria Peco |
| Created | 2025-09-08 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/97048656 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Relationship model: 2 logical tables (with joins inside) -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / sandbox_spb); Google Drive Excel
- **Structure:**

```
Logical table "billing_account_opp_details"
  - LEFT JOIN on [billing_account_opp_details].[record_type_identifier] = [BA Crosswalk].[Billing Account]
    - Athena Custom SQL "billing_account_opp_details" -> billing_account_opp_details.sql
    - Google Drive Excel "BA --_ BU Crosswalk for Renewals Outcome Tableau Dashboard (July FY23 RT Report)" table BA Crosswalk$ (as "BA Crosswalk")
Logical table "fact_renewals"
  - LEFT JOIN on [fact_renewals].[contract_territory] = [geo_region_rollup].[sales_territory]
    - LEFT JOIN on [fact_renewals].[contract_id] = [Contract Crosswalk].[Contract]
      - LEFT JOIN on [fact_renewals].[contract_territory] = [contract_territories].[contract_territory]
        - Athena Custom SQL "fact_renewals" -> fact_renewals.sql
        - Google Drive Excel "Salesforce Contract Territories" table contract_territories$ (as "contract_territories")
      - Google Drive Excel "BA --_ BU Crosswalk for Renewals Outcome Tableau Dashboard (July FY23 RT Report)" table Contract Crosswalk$ (as "Contract Crosswalk")
    - Google Drive Excel "Geo Region Rollup" table geo_region_rollup$ (as "geo_region_rollup")
```

- **Relationships:**
  - "fact_renewals" ↔ "billing_account_opp_details" on `[monthly_snapshot_date] = [monthly_snapshot_date (Custom SQL Query)] AND [sfdc_contract_id] = [sfdc_contract_id (Custom SQL Query)]`
- **Athena tables read:** `sandbox_gazzanom.fact_renewals`, `sandbox_spb.tm1_renewals`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_opportunity_dimension`, `reference_external_db.fx_rates_current`, `sandbox_spb.fact_renewals`, `fact_external_db.tm1_fact`, `dimension_external_db.pib_territory_dimension`, `dimension_external_db.pib_user_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [billing_account_opp_details.sql](billing_account_opp_details.sql), [fact_renewals.sql](fact_renewals.sql)

## Connected workbooks

- [B2B Renewal Outcomes](../../Sales%20Leadership%20%26%20Operations/B2B%20Renewal%20Outcomes) [B2B / B2B Sales / Sales Leadership & Operations]
- [B2B Renewal Outcomes - Snowflake Test](../../Sales%20Leadership%20%26%20Operations/B2B%20Renewal%20Outcomes%20-%20Snowflake%20Test) [B2B / B2B Sales / Sales Leadership & Operations]
