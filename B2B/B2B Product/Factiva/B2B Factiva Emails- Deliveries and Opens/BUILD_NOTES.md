# B2B Factiva Emails: Deliveries and Opens

_Tableau dashboard (workbook) with an Athena component._

| | |
|---|---|
| Type | Workbook (.twbx) |
| Location | B2B / B2B Product / Factiva |
| Owner | Maria Peco |
| Created | 2025-06-16 |
| Last updated | 2025-09-12 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/workbooks/2885786 |
| Archived | 2026-11-11 |

## Summary

3 data source(s) in the workbook; 3 with an Athena component (0 embedded, 3 published).

## "Newsletters" (published data source)

- **Published source:** "B2B Factiva Emails: Deliveries and Opens - Newsletters" in `B2B / B2B Product / Factiva / Datasources`, owner Maria Peco; [archived here](../Datasources/B2B%20Factiva%20Emails-%20Deliveries%20and%20Opens%20-%20Newsletters). The SQL below is copied from it.
- **Shape:** Join of 3 tables
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** NL V2
- **Structure:**

```
- LEFT JOIN on [Custom SQL Query].[nlid] = [NLID AVs].[nlid] AND [Custom SQL Query].[year_month] = [NLID AVs].[year_month]
  - LEFT JOIN on [Custom SQL Query].[nlid] = [NLID].[nlid]
    - Athena Custom SQL "Custom SQL Query" -> Newsletters - Custom SQL Query.sql
    - Athena Custom SQL "NLID" -> Newsletters - NLID.sql
  - Athena Custom SQL "NLID AVs" -> Newsletters - NLID AVs.sql
```
- **Athena tables read:** `pib.email_open_rates`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_territory_dimension`, `dimension_external_db.pib_user_dimension`, `fact_external_db.omniture_event_fact`
- **SQL files:** [Newsletters - Custom SQL Query.sql](Newsletters%20-%20Custom%20SQL%20Query.sql), [Newsletters - NLID.sql](Newsletters%20-%20NLID.sql), [Newsletters - NLID AVs.sql](Newsletters%20-%20NLID%20AVs.sql)

## "open rates email" (published data source)

- **Published source:** "B2B Factiva Emails: Deliveries and Opens - Open Rates Email" in `B2B / B2B Product / Factiva / Datasources`, owner Maria Peco; [archived here](../Datasources/B2B%20Factiva%20Emails-%20Deliveries%20and%20Opens%20-%20Open%20Rates%20Email). The SQL below is copied from it.
- **Shape:** Join of 2 tables
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db)
- **Used by worksheets:** Newsletters Admin, Newsletters1, Newsletters1 (2), Sheet 1, Sheet 10, Sheet 2, Sheet 3, Sheet 3 (2), Sheet 5
- **Structure:**

```
- LEFT JOIN on [Custom SQL Query].[nlid] = [NLID].[nlid]
  - Athena Custom SQL "Custom SQL Query" -> open rates email - Custom SQL Query.sql
  - Athena Custom SQL "NLID" -> open rates email - NLID.sql
```
- **Athena tables read:** `fact_external_db.omniture_event_fact`, `dimension_external_db.pib_membership_dimension`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `pib_event_data.pib_product_metrics`, `pib.email_open_rates`, `dimension_external_db.pib_alerts`, `dimension_external_db.pib_territory_dimension`, `dimension_external_db.pib_user_dimension`
- **SQL files:** [open rates email - Custom SQL Query.sql](open%20rates%20email%20-%20Custom%20SQL%20Query.sql), [open rates email - NLID.sql](open%20rates%20email%20-%20NLID.sql)

## "B2B Factiva Emails: Deliveries and Opens - Aggregate" (published data source)

- **Published source:** "B2B Factiva Emails: Deliveries and Opens - Aggregate" in `B2B / B2B Product / Factiva / Datasources`, owner Maria Peco; [archived here](../Datasources/B2B%20Factiva%20Emails-%20Deliveries%20and%20Opens%20-%20Aggregate). The SQL below is copied from it.
- **Shape:** Join of 2 tables -- Athena + Google Drive Excel
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Athena (AwsDataCatalog / dimension_external_db); Google Drive Excel
- **Used by worksheets:** Sheet 11
- **Structure:**

```
- LEFT JOIN on [Custom SQL Query].[department_code] = [Job Function Lookup].[Code]
  - Athena Custom SQL "Custom SQL Query" -> B2B Factiva Emails- Deliveries and Opens - Aggregate.sql
  - Google Drive Excel "Job Function2" table Sheet1$ (as "Job Function Lookup")
```
- **Athena tables read:** `dimension_external_db.pib_membership_dimension`, `pib.email_open_rates`, `dimension_external_db.pib_alerts`, `dimension_external_db.pib_billing_account_dimension`, `dimension_external_db.pib_company_dimension`, `dimension_external_db.pib_territory_dimension`, `dimension_external_db.pib_user_dimension`, `reference_external_db.country_reference`
- **SQL files:** [B2B Factiva Emails- Deliveries and Opens - Aggregate.sql](B2B%20Factiva%20Emails-%20Deliveries%20and%20Opens%20-%20Aggregate.sql)
