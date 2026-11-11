# CLAUDE.md — Tableau-Logic-Archive

A **read-mostly archive** of the Athena (Presto) SQL behind B2B Tableau dashboards and
published data sources, captured from Tableau Cloud after AWS Athena was sunset. See
`README.md` for scope, layout and how to read the notes.

## Ground rules

1. **Never edit an archived `.sql` file's body.** Each one is a verbatim copy of what
   Tableau stored, kept as evidence. Don't reformat, translate, "fix" or lint it, and
   don't apply SQL style conventions here. If a translation is needed, write it
   somewhere else (for example the Tableau-Reconstructor repo's outputs) and leave the
   original alone.
2. **Athena is gone.** Nothing here can be run against it. Treat the SQL as a
   specification of the old logic. To compare old and new results, use the `.hyper`
   extract bundled in an Athena-era workbook (Tableau-Reconstructor's `logic_test`).
3. **No binaries or credentials.** Never commit `.twb/.twbx/.tds/.tdsx/.hyper` files
   or `.env` (they are gitignored). Never put local machine paths in committed files.
4. **Duplication is by design.** A published source's SQL is copied into every
   dashboard folder that uses it. When a dashboard is migrated or retired, its folder
   stays: this is a historical record, not a live mirror.

## Finding things

- `INDEX.md` lists every dashboard and published source with its folder.
- `ATHENA_TABLES.md` maps each Athena table (`schema.table`) to the dashboards and
  sources that read it. Use it to answer "what breaks / what must be migrated if
  table X goes away".
- Folder paths mirror the Tableau project tree (`B2B/<project>/.../<item>/`). Grep the
  `.sql` files for a column or table name to find every dashboard that uses it.
- Each `BUILD_NOTES.md` has a **Shape** line (standalone Custom SQL, join,
  relationship model, union, mixed connections) and a **Structure** tree. Those show
  how the Athena piece is wired into the data source, which matters when rebuilding
  it on Snowflake (for example an Athena query joined to a Google Drive Excel sheet).

## Answering questions about a dashboard's logic

1. Open its folder's `BUILD_NOTES.md` to see which data sources are Athena,
   embedded or published, and which worksheets use them.
2. Read the referenced `.sql` files. The header names the Athena default schema,
   needed to resolve unqualified table names.
3. Tableau parameters appear as `<[Parameters].[Parameter N]>` tokens. The header
   gives each one's caption and saved value.
4. Calculated fields and worksheet-level logic are **not** in this archive. They live
   in the workbook on Tableau Cloud.

## Adding to the archive

Keep the same layout: `<project path>/<item name>/BUILD_NOTES.md` plus one `.sql` per
Athena Custom SQL relation, each with the provenance header. Update `INDEX.md` and
`ATHENA_TABLES.md` to match. Note the capture date in the item's header.
