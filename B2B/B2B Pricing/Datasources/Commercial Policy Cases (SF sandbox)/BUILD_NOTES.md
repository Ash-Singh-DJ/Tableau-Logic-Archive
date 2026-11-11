# Commercial Policy Cases (SF sandbox)

_Published data source with an Athena component._

| | |
|---|---|
| Type | Published data source (.tdsx) |
| Location | B2B / B2B Pricing / Datasources |
| Owner | Jonas Coelho |
| Created | 2026-09-14 |
| Last updated | 2026-10-04 |
| Tableau URL | https://us-east-1.online.tableau.com/#/site/dj-cdl-prod/datasources/178904102 |
| Archived | 2026-11-11 |

## How Athena is used

- **Shape:** Standalone table
- **Extract:** yes (extract refreshed from the live connection)
- **Connections:** Snowflake
- **Structure:**

```
- Snowflake table SANDBOX.B2B.COMMERCIAL_POLICY (as "COMMERCIAL_POLICY")
```
- **SQL files:** _none -- Athena is read as plain table(s), no Custom SQL_

## Connected workbooks

- [Commercial Policy Cases (SF)](../../Commercial%20Policy%20Cases%20%28SF%29) [B2B / B2B Pricing]
