-- Dashboard   : "B2B Factiva Unique Users Monthly Report"  [B2B / Factiva Legacy (for review)]
-- Data source : "MCT UVs" (embedded in the workbook)
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select SUBSTRING(CAST(cycle_date AS varchar), 1, 7) year_month, 
COUNT(DISTINCT CASE WHEN CAST(exclude_hit AS INTEGER) <<= 0 
AND CAST(hit_source AS varchar) NOT IN ('5',  '7',  '8',  '9') THEN CAST(post_visid_high as varchar) || '-' || CAST(post_visid_low as varchar) end) as Unique_vsitors
from fact_external_db.omniture_event_fact
where reporting_suite = 'djfactiva'
and post_evar11 = 'MyCompanyToday'
AND (post_evar4 = 'Fact_ART_ArticleView' or post_prop3 = 'ARTICLE' or lower(post_pagename) like '%article%')
and cycle_date >>= cast('2020-01-01' as date)
group by 1
