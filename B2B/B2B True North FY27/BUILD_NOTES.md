# B2B True North FY27

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B |
| Owner | svc_dj tableaucdl_b2b |
| Created | 2026-06-24 |
| Last updated | 2026-11-02 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/4968586 |
| Archived | 2026-11-11 |

## Summary

5 data source(s) in the workbook; 1 with an Athena component (0 embedded, 1 published).
Other data sources: "WAU MAU Rolling" (published); "B2B Rolling WAU MAU by Company" (published); "Smart Summary and AI SILVER" (published); "True North FY27 Draft1" (published).

## "SS and AI Usage" (published data source)

- **Published source:** "SS and AI Usage" in `B2B`, owner svc_dj tableaucdl_b2b; [archived here](../SS%20and%20AI%20Usage). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** _none (data source is unused in this workbook)_
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> SS and AI Usage.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [SS and AI Usage.sql](SS%20and%20AI%20Usage.sql)
