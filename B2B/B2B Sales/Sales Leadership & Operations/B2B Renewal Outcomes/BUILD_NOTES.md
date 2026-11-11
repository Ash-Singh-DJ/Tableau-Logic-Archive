# B2B Renewal Outcomes

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Sales / Sales Leadership & Operations |
| Owner | James Thomson |
| Created | 2025-09-08 |
| Last updated | 2025-09-17 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/3286522 |
| Archived | 2026-11-11 |

## Summary

1 data source(s) in the workbook; 1 with an Athena component (0 embedded, 1 published).

## "Renewals Dashboard" (published data source)

- **Published source:** "B2B Renewal Outcomes - Data Source" in `B2B / B2B Sales / Data Sources`, owner Maria Peco; [archived here](../../Data%20Sources/B2B%20Renewal%20Outcomes%20-%20Data%20Source). The SQL below is copied from it.
- **Shape:** Relationship model: 2 logical tables (with joins inside) -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / sandbox_spb); Google Drive Excel
- **Used by worksheets:** Data as of String, Details, Pivot Chart, Post Renewal Metric Warning, Row Level Detail Warning
- **Structure:**

```
Logical table "billing_account_opp_details"
  - LEFT JOIN on [billing_account_opp_details].[record_type_identifier] = [BA Crosswalk].[Billing Account]
    - Athena Custom SQL "billing_account_opp_details" -> Renewals Dashboard - billing_account_opp_details.sql
    - Google Drive Excel "BA --_ BU Crosswalk for Renewals Outcome Tableau Dashboard (July FY23 RT Report)" table BA Crosswalk$ (as "BA Crosswalk")
Logical table "fact_renewals"
  - LEFT JOIN on [fact_renewals].[contract_territory] = [geo_region_rollup].[sales_territory]
    - LEFT JOIN on [fact_renewals].[contract_id] = [Contract Crosswalk].[Contract]
      - LEFT JOIN on [fact_renewals].[contract_territory] = [contract_territories].[contract_territory]
        - Athena Custom SQL "fact_renewals" -> Renewals Dashboard - fact_renewals.sql
        - Google Drive Excel "Salesforce Contract Territories" table contract_territories$ (as "contract_territories")
      - Google Drive Excel "BA --_ BU Crosswalk for Renewals Outcome Tableau Dashboard (July FY23 RT Report)" table Contract Crosswalk$ (as "Contract Crosswalk")
    - Google Drive Excel "Geo Region Rollup" table geo_region_rollup$ (as "geo_region_rollup")
```

- **Relationships:**
  - "fact_renewals" ↔ "billing_account_opp_details" on `[monthly_snapshot_date] = [monthly_snapshot_date (Custom SQL Query)] AND [sfdc_contract_id] = [sfdc_contract_id (Custom SQL Query)]`
- **Athena tables read:** `sandbox_gazzanom.fact_renewals`, `sandbox_spb.tm1_renewals`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_opportunity_dimension`, `reference_external_db.fx_rates_current`, `sandbox_spb.fact_renewals`, `fact_external_db.tm1_fact`, `dimension_external_db.pib_territory_dimension`, `dimension_external_db.pib_user_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [Renewals Dashboard - billing_account_opp_details.sql](Renewals%20Dashboard%20-%20billing_account_opp_details.sql), [Renewals Dashboard - fact_renewals.sql](Renewals%20Dashboard%20-%20fact_renewals.sql)
