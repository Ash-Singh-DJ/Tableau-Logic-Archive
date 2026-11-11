# Search Sequence II

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Product / Factiva / Factiva Search Usage |
| Owner | James Thomson |
| Created | 2025-10-02 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/107315948 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Relationship model: 2 logical tables (with joins inside)
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Structure:**

```
Logical table "Custom SQL Query"
  - LEFT JOIN on [Custom SQL Query].[EID] = [Usage].[EID]
    - Athena Custom SQL "Custom SQL Query" -> Custom SQL Query.sql
    - Athena Custom SQL "Usage" -> Usage.sql
Logical table "Lang config"
  - Athena Custom SQL "Custom SQL Query1" -> Custom SQL Query1.sql
```

- **Relationships:**
  - "Custom SQL Query" ↔ "Lang config" on `[EID] = [user_info_user_ref]`
- **Athena tables read:** `reference_external_db.date_dimension`, `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [Custom SQL Query.sql](Custom%20SQL%20Query.sql), [Usage.sql](Usage.sql), [Custom SQL Query1.sql](Custom%20SQL%20Query1.sql)

## Connected workbooks

- [B2B New Factiva Lexical and Semantic Search Metrics](../B2B%20New%20Factiva%20Lexical%20and%20Semantic%20Search%20Metrics) [B2B / B2B Product / Factiva / Factiva Search Usage]
