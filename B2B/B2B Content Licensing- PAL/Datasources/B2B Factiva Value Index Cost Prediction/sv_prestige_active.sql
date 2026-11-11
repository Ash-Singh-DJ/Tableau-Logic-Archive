-- Published data source : "B2B Factiva Value Index Cost Prediction"  [B2B / B2B Content Licensing- PAL / Datasources]
-- Relation    : Custom SQL "sv_prestige_active"
-- Connection  : Athena (AwsDataCatalog / sandbox_mk), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select distinct svp.*, cs.srcinfo_statuscode_code_value, cs.srcinfo_statuscode_description 
from sandbox_mk.sv_prestige svp
left join dimension_external_db.cdb_source_docs_current cs
    on svp.source_code = cs.srcinfo_code_value
where cs.srcinfo_statuscode_code_value = 'ACT'
