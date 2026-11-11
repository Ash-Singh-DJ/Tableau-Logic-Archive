-- Dashboard   : "B2B R&C Value Index Dashboard 08172022"  [B2B / B2B Content Licensing- PAL]
-- Data source : "R&C Value Index (dimension_external_db)" = published source "B2B R&C Value Index (dimension_external_db)"  [B2B / B2B Content Licensing- PAL / Datasources]
-- Relation    : Custom SQL "R&C Value Index"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
SELECT sc.sourcename, sc.ipcode, sc.ipname, sc.royalty_provider_code,
       sc.status, sc.pst, sc.language, sc.sourcecoverage, sc.articlecoverage,
       CAST(sc.onlinedate as date) AS online_date,
	   vi.*
FROM sandbox_mk.rnc_value_index vi
LEFT JOIN sandbox_mk.factiva_content_source_current sc ON vi.source_code = sc.sourcecode 
WHERE cycle_date = (SELECT MAX(cycle_date) FROM sandbox_mk.rnc_value_index)
ORDER BY rnc_value_index DESC
