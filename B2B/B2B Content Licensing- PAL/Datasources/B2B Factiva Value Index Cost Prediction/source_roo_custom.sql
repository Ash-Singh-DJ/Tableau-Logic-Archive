-- Published data source : "B2B Factiva Value Index Cost Prediction"  [B2B / B2B Content Licensing- PAL / Datasources]
-- Relation    : Custom SQL "source_roo_custom"
-- Connection  : Athena (AwsDataCatalog / sandbox_mk), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select distinct sg.sourcecode, sg.groupcode, sg.groupname as CountryName, sr.regionoforigin as CountryCode from sandbox_mk.source_group sg
inner join sandbox_mk.source_roo sr
	on sg.sourcecode = sr.sourcecode and sg.groupcode = sr.regionoforigin 
where (GroupTypeCode = 'ROO' or GroupTypeCode = 'roo')
and regiontype = 'Co'
