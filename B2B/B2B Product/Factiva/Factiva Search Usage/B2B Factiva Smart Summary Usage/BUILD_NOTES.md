# B2B Factiva Smart Summary Usage

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Product / Factiva / Factiva Search Usage |
| Owner | svc_dj tableaucdl_b2b |
| Created | 2025-06-17 |
| Last updated | 2026-10-06 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/2890252 |
| Archived | 2026-11-11 |

## Summary

10 data source(s) in the workbook; 7 with an Athena component (0 embedded, 7 published).
Other data sources: "B2B Factiva Search AI Summary Usage - Feedback" (published); "Smart Summary SNOWFLAKE" (published); "AI_CHAT_METRICS_SNOWFLAKE" (published).

## "Chat Metrics Unbounded V2" (published data source)

- **Published source:** "Chat Metrics Unbounded V2" in `B2B / B2B Testing`, owner James Thomson; not archived separately: it sits outside the archive scope (B2B Testing). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** _none (data source is unused in this workbook)_
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Chat Metrics Unbounded V2.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [Chat Metrics Unbounded V2.sql](Chat%20Metrics%20Unbounded%20V2.sql)

## "Chat metrics" (published data source)

- **Published source:** "Chat metrics" in `B2B / B2B Testing`, owner James Thomson; not archived separately: it sits outside the archive scope (B2B Testing). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** _none (data source is unused in this workbook)_
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Chat metrics.sql
```
- **Athena tables read:** `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [Chat metrics.sql](Chat%20metrics.sql)

## "Pendo Feedback 2" (published data source)

- **Published source:** "Pendo Feedback 2" in `B2B / B2B Content Licensing- PAL`, owner svc_dj tableaucdl_b2b; [archived here](../../../../B2B%20Content%20Licensing-%20PAL/Pendo%20Feedback%202). The SQL below is copied from it.
- **Shape:** Relationship model: 3 logical tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Used by worksheets:** Smart Summary Comments
- **Structure:**

```
Logical table "Sheet12"
  - Google Drive Excel "Smart Summary Pendo SVR" table Sheet1$ (as "Sheet12")
Logical table "JF"
  - Google Drive Excel "Job Function" table Sheet1$ (as "Sheet11")
Logical table "Usage data"
  - Athena Custom SQL "Custom SQL Query" -> Pendo Feedback 2.sql
```

- **Relationships:**
  - "Usage data" ↔ "JF" on `[department_code] = [Code]`
  - "Sheet12" ↔ "Usage data" on `[Visitor ID (Sheet12)] = [EID]`
- **Athena tables read:** `dimension_external_db.pib_membership_dimension`, `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [Pendo Feedback 2.sql](Pendo%20Feedback%202.sql)

## "Pendo Feedback" (published data source)

- **Published source:** "Pendo Feedback" in `B2B / B2B Product`, owner James Thomson; [archived here](../../../Pendo%20Feedback). The SQL below is copied from it.
- **Shape:** Relationship model: 3 logical tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Used by worksheets:** _none (data source is unused in this workbook)_
- **Structure:**

```
Logical table "Sheet1"
  - Google Drive Excel "Samrt Summary Pendo" table Sheet1$ (as "Sheet1")
Logical table "JF"
  - Google Drive Excel "Job Function" table Sheet1$ (as "Sheet11")
Logical table "Usage data"
  - Athena Custom SQL "Custom SQL Query" -> Pendo Feedback.sql
```

- **Relationships:**
  - "Usage data" ↔ "JF" on `[department_code] = [Code]`
  - "Sheet1" ↔ "Usage data" on `[Visitor ID] = [EID]`
- **Athena tables read:** `dimension_external_db.pib_membership_dimension`, `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [Pendo Feedback.sql](Pendo%20Feedback.sql)

## "B2B Factiva GenAI Summary usage" (published data source)

- **Published source:** "B2B Factiva  Smart Summary Usage - Data Source" in `B2B / B2B Product / Factiva / Datasources`, owner James Thomson; [archived here](../../Datasources/B2B%20Factiva%20Smart%20Summary%20Usage%20-%20Data%20Source). The SQL below is copied from it.
- **Shape:** Relationship model: 2 logical tables (with joins inside) -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Used by worksheets:** Feedback, Floating / Regular, Sheet 1, Sheet 1 (2), Sheet 1 (3), Sheet 1 (4), Sheet 1 (5), Sheet 1 (6), Sheet 1 (7), Sheet 1 (8), Sheet 1 (9), Sheet 16, Sheet 18, Sheet 19, Sheet 2, Sheet 21, Sheet 3, Sheet 7, Trend
- **Structure:**

```
Logical table "Pivot"
  - Google Drive Excel "ThumbUpDown" table Pivot$ (as "Pivot")
Logical table "Custom SQL Query"
  - LEFT JOIN on [Custom SQL Query].[department_code] = [Job Function].[Code]
    - Athena Custom SQL "Custom SQL Query" -> B2B Factiva GenAI Summary usage.sql
    - Google Drive Excel "Job Function2" table Sheet1$ (as "Job Function")
```

- **Relationships:**
  - "Custom SQL Query" ↔ "Pivot" on `[cycle_date] = [Date] AND [pib_member_id] = [Visitor]`
- **Athena tables read:** `dimension_external_db.pib_membership_dimension`, `reference_external_db.date_dimension`, `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [B2B Factiva GenAI Summary usage.sql](B2B%20Factiva%20GenAI%20Summary%20usage.sql)

## "Smart Summary V2" (published data source)

- **Published source:** "Smart Summary V2" in `B2B / B2B Product / Factiva / Factiva Search Usage`, owner svc_dj tableaucdl_b2b; [archived here](../Smart%20Summary%20V2). The SQL below is copied from it.
- **Shape:** Standalone Custom SQL
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** _none (data source is unused in this workbook)_
- **Structure:**

```
- Athena Custom SQL "Custom SQL Query" -> Smart Summary V2.sql
```
- **Athena tables read:** `dimension_external_db.pib_membership_dimension`, `reference_external_db.date_dimension`, `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [Smart Summary V2.sql](Smart%20Summary%20V2.sql)

## "AHA!" (published data source)

- **Published source:** "AHA!" in `B2B / B2B Product`, owner James Thomson; [archived here](../../../AHA%21). The SQL below is copied from it.
- **Shape:** Relationship model: 2 logical tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Used by worksheets:** Sheet 37
- **Structure:**

```
Logical table "JF Lookup"
  - Google Drive Excel "Job Function" table Sheet1$ (as "Sheet1")
Logical table "Custom SQL Query"
  - Athena Custom SQL "Custom SQL Query" -> AHA!.sql
```

- **Relationships:**
  - "Custom SQL Query" ↔ "JF Lookup" on `[department_code] = [Code]`
- **Athena tables read:** `dimension_external_db.pib_membership_dimension`, `dimension_external_db.aha_ideas_current`, `pib_event_data.pib_product_metrics`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`
- **SQL files:** [AHA!.sql](AHA%21.sql)
