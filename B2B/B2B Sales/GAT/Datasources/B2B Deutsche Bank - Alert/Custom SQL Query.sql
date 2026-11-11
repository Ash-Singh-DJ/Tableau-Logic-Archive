-- Published data source : "B2B Deutsche Bank - Alert"  [B2B / B2B Sales / GAT / Datasources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / bigmarker_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with max_date as(
SELECT max(report_date) AS maxdate FROM dimension_external_db.pib_alerts 
)

SELECT SUBSTRING(CAST(report_date AS varchar), 1, 7) as alert_month,
         folder_name,
         email_address,
         account_id,
         SUM(CAST(email_count AS INTEGER)) as email_alerts_sent,
         SUM(CAST(article_count AS INTEGER)) as articles_sent,
         SUM(CASE WHEN lower(display_format) LIKE '%fulltext%' THEN CAST(email_count AS INTEGER) ELSE 0 END) full_text_email_alerts_sent,
         SUM(CASE WHEN lower(display_format) LIKE '%fulltext%' THEN CAST(article_count AS INTEGER) ELSE 0 END) full_text_articles_sent
FROM dimension_external_db.pib_alerts 
where account_id IN('9DEU001700',
'9DEU005300',
'9DEU004800',
'9DEU001500',
'9DEU008900',
'9DEU004000',
'9DEU006000',
'9DEU011300',
'9DEU005600',
'9DEU003200',
'9DEU019300',
'9DEU017100',
'9DEU004600'
)
AND report_date >>= date('2024-01-01')
AND report_date <<= (select Date_trunc('month', maxdate) FROM max_date)
GROUP BY 1, 2, 3, 4
