# B2B Consumer Usage Dashboard - Data Source

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Sales / Data Sources |
| Owner | James Thomson |
| Created | 2025-08-27 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/163712300 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Join of 3 tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Structure:**

```
- LEFT JOIN on [Custom SQL Query].[company_industry] = [Industry Rollup Table (no gov&o1].[SFDC Industry]
  - LEFT JOIN on [Custom SQL Query].[territory_name] = [Geo Region Rollup].[Sales Territory]
    - Athena Custom SQL "Custom SQL Query" -> Custom SQL Query.sql
    - Google Drive Excel "Geo Region rollup Table FY21" table Sheet1$ (as "Geo Region Rollup")
  - Google Drive Excel "Industry Rollup Table (no gov&other)  js v2" table Industry Rollup Table (no gov&o$ (as "Industry Rollup Table (no gov&o1")
```
- **Athena tables read:** `fact_external_db.omniture_event_fact`, `reference_external_db.date_dimension`, `dimension_external_db.pib_membership_dimension`, `subscription_external_db.identity_lookup`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_user_dimension`, `dimension_external_db.pib_territory_dimension`, `reference_external_db.country_reference`
- **SQL files:** [Custom SQL Query.sql](Custom%20SQL%20Query.sql)

## Connected workbooks

- [PIB WSJ & Barrons Usage](../../../B2B%20Product/PIB%20WSJ%20%26%20Barrons%20Usage) [B2B / B2B Product]
- [B2B Consumer Usage Dashboard](../../Product%20Usage/B2B%20Consumer%20Usage%20Dashboard) [B2B / B2B Sales / Product Usage]
