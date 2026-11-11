-- Dashboard   : "B2B Factiva Usage by Content Source and Account"  [B2B / B2B Product / Factiva / Factiva Usage by Source]
-- Data source : "omnit_user_source_usage+ (dimension_external)" = published source "B2B  Factiva Usage by Content Source and Account - Data Source"  [B2B / B2B Product / Factiva / Datasources]
-- Relation    : Custom SQL "User Seg"
-- Connection  : Athena (AwsDataCatalog / sandbox_mk), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
SELECT *
FROM sandbox_mk.factiva_user_seg_12mo
WHERE cycle_date = (SELECT MAX(cycle_date) 
                    FROM sandbox_mk.factiva_user_seg_12mo)
