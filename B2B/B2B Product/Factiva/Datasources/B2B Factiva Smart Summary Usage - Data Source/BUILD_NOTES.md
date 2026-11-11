# B2B Factiva  Smart Summary Usage - Data Source

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Product / Factiva / Datasources |
| Owner | James Thomson |
| Created | 2025-09-04 |
| Last updated | 2026-01-21 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/122600031 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Relationship model: 2 logical tables (with joins inside) -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Structure:**

```
Logical table "Pivot"
  - Google Drive Excel "ThumbUpDown" table Pivot$ (as "Pivot")
Logical table "Custom SQL Query"
  - LEFT JOIN on [Custom SQL Query].[department_code] = [Job Function].[Code]
    - Athena Custom SQL "Custom SQL Query" -> Custom SQL Query.sql
    - Google Drive Excel "Job Function2" table Sheet1$ (as "Job Function")
```

- **Relationships:**
  - "Custom SQL Query" ↔ "Pivot" on `[cycle_date] = [Date] AND [pib_member_id] = [Visitor]`
- **Athena tables read:** `dimension_external_db.pib_membership_dimension`, `reference_external_db.date_dimension`, `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [Custom SQL Query.sql](Custom%20SQL%20Query.sql)

## Connected workbooks

- [B2B Factiva Smart Summary Usage](../../Factiva%20Search%20Usage/B2B%20Factiva%20Smart%20Summary%20Usage) [B2B / B2B Product / Factiva / Factiva Search Usage]
