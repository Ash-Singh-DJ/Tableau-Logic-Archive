# Tableau-Logic-Archive

An archive of the **Athena (Presto) SQL logic** behind the B2B Tableau dashboards and
published data sources on Tableau Cloud. AWS Athena has been sunset, so this SQL can no
longer run. It is kept here as the record of what each Athena-era data source did, both
to support migrations to Snowflake and to answer "how was this number built?" later on.

Snapshot taken **2026-11-11**:

| | |
|---|---|
| Dashboards with an Athena component | 118 |
| Published data sources with an Athena component | 203 |
| SQL files | 607 |
| Distinct Athena tables referenced | 166 |

## Scope

- Site `dj-cdl-prod`, the top-level **`B2B`** project and everything under it.
- **Excluded:** `B2B / B2B Testing` and its sub-projects. When an in-scope dashboard
  uses a published source that lives in B2B Testing, that source's SQL is still copied
  into the dashboard's folder. The source just doesn't get a folder of its own.
- An item is included when **any** part of it connects to Athena. That covers a
  standalone Custom SQL query or table, one leg of a join or relationship model
  alongside Excel, Google Drive, BigQuery or Snowflake, or a published source that is
  itself Athena-based.
- Only content the archiving account could see was scanned. Workbooks and sources in
  projects without view permission are not included.

## Layout

Folders mirror the Tableau project tree. Each Athena dashboard and each Athena published
data source gets a folder named after it:

```
B2B/
  B2B Product/
    Factiva/
      <Dashboard name>/
        BUILD_NOTES.md                    how each Athena data source is built and used
        <data source>.sql                 one file per Athena Custom SQL relation
        <data source> - <relation>.sql    (when a data source has several)
      Datasources/
        <Published data source name>/
          BUILD_NOTES.md
          <relation>.sql
```

- **Dashboard folders hold the SQL for every Athena source the dashboard uses**,
  whether embedded in the workbook or published separately. A published source's SQL
  therefore shows up both in its own folder and in each dashboard that uses it. That
  duplication is intentional, so every dashboard folder is self-contained.
- If a dashboard and a published source share a name in the same project, the
  source's folder gets a ` (data source)` suffix.
- Characters Windows forbids in file names (`<>:"/\|?*`) become `-`. Long names are
  shortened in the middle (`B2B Factiva Business Metrics...tive Users - Total Registered`)
  so paths stay under Windows' 260-character limit. The full name is always in the
  folder's `BUILD_NOTES.md`.

### Repo-level files

| File | What it is |
|---|---|
| [`INDEX.md`](INDEX.md) | Every archived dashboard and published source, with location, owner and links |
| [`ATHENA_TABLES.md`](ATHENA_TABLES.md) | Reverse index: each Athena table, and every dashboard or source that reads it |

## Reading a BUILD_NOTES.md

Each note has a header (location, owner, dates, Tableau URL), then one section per
Athena data source:

- **Shape** is how the data source is assembled:
  - `Standalone Custom SQL` / `Standalone table`: one Athena query or table, nothing else.
  - `Join of N tables`: a classic Tableau join tree (physical layer).
  - `Relationship model: N logical tables`: Tableau's relationship ("noodle") model.
    The relationships and their keys are listed under **Relationships**.
  - `Union`: a Tableau union of tables.
  - A suffix such as `-- Athena + Google Drive Excel` means the source mixes connections.
- **Structure** is the full join/union tree, with every leaf's connection and the SQL
  file that holds its query.
- **Used by worksheets** lists the sheets that bind the data source. A source used by
  no sheet is still listed but marked unused.
- **Extract**: whether Tableau served an extract refreshed from Athena, or queried live.
- **Athena tables read**: `FROM`/`JOIN` targets pulled from the SQL, qualified with the
  connection's default schema when the SQL leaves them unqualified.

## SQL files

- **Verbatim**: exactly as stored in the Tableau XML. Not translated, reformatted or
  corrected. The one change is that Windows line endings are converted to LF.
  They are Presto SQL against the AWS Glue catalog (`AwsDataCatalog`).
- A comment header gives provenance: dashboard / data source, relation name,
  Athena catalog and default schema, archive date. Tableau parameter tokens
  (`<[Parameters].[...]>`) stay in place, and the header names each one and its saved
  value where the workbook defines it.
- Only Athena SQL is archived. Non-Athena Custom SQL in a mixed data source is
  named in the notes but not copied. Tableau calculated fields are not archived: they
  live in the workbooks on Tableau Cloud.

## How this was built

The workbooks and published sources were downloaded read-only (no extracts) from
Tableau Cloud through the Tableau Cloud connector in the **Tableau-Reconstructor**
repo, and their XML was parsed offline. Tableau's Metadata API returns no lineage at a
Creator's permission level, so the XML is the source of truth. It is a point-in-time
snapshot: dashboards changed or migrated on Tableau Cloud afterwards are not reflected.

To migrate one of these dashboards to Snowflake, use Tableau-Reconstructor's
`tableau-source-swap` workflow. This archive is the reference for what the Athena logic
was, not a migration tool.
