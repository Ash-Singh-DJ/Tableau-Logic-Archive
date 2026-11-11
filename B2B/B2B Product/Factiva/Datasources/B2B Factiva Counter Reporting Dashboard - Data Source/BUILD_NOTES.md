# B2B Factiva Counter Reporting Dashboard - Data Source

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Product / Factiva / Datasources |
| Owner | Maria Peco |
| Created | 2025-09-04 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/154246555 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Join of 2 tables
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / sandbox_mk)
- **Structure:**

```
- LEFT JOIN on [Counter Report Query].[source_code] = [Factiva Content Source].[sourcecode]
  - Athena Custom SQL "Counter Report Query" -> Counter Report Query.sql
  - Athena Custom SQL "Factiva Content Source" -> Factiva Content Source.sql
```
- **Athena tables read:** `fact_external_db.omniture_event_fact`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_territory_dimension`, `sandbox_mk.factiva_content_source_current`
- **SQL files:** [Counter Report Query.sql](Counter%20Report%20Query.sql), [Factiva Content Source.sql](Factiva%20Content%20Source.sql)

## Connected workbooks

- [B2B Factiva Counter Reporting Dashboard](../../../../B2B%20Content%20Licensing-%20PAL/B2B%20Factiva%20Counter%20Reporting%20Dashboard) [B2B / B2B Content Licensing- PAL]
