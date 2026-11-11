# Pendo Feedback 2

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Content Licensing- PAL |
| Owner | svc_dj tableaucdl_b2b |
| Created | 2025-12-17 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/173223850 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Relationship model: 3 logical tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Structure:**

```
Logical table "Sheet12"
  - Google Drive Excel "Smart Summary Pendo SVR" table Sheet1$ (as "Sheet12")
Logical table "JF"
  - Google Drive Excel "Job Function" table Sheet1$ (as "Sheet11")
Logical table "Usage data"
  - Athena Custom SQL "Custom SQL Query" -> Custom SQL Query.sql
```

- **Relationships:**
  - "Usage data" ↔ "JF" on `[department_code] = [Code]`
  - "Sheet12" ↔ "Usage data" on `[Visitor ID (Sheet12)] = [EID]`
- **Athena tables read:** `dimension_external_db.pib_membership_dimension`, `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [Custom SQL Query.sql](Custom%20SQL%20Query.sql)

## Connected workbooks

- [B2B Factiva Smart Summary Usage](../../B2B%20Product/Factiva/Factiva%20Search%20Usage/B2B%20Factiva%20Smart%20Summary%20Usage) [B2B / B2B Product / Factiva / Factiva Search Usage]
