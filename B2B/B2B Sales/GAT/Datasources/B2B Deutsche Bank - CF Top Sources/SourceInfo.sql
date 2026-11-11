-- Published data source : "B2B Deutsche Bank - CF Top Sources"  [B2B / B2B Sales / GAT / Datasources]
-- Relation    : Custom SQL "SourceInfo"
-- Connection  : Athena (AwsDataCatalog / sandbox_mk), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
WITH total_codes AS (
  SELECT sc.SourceCode, SourceName, royalty_provider_code, ipcode, ipname, Language, PST, RightsCode,
         sg.GroupCode as CountryCode, sg.GroupName as CountryName,
         CASE WHEN djs.GroupCode IS NOT NULL THEN 'DJ' ELSE 'Non-DJ' END DJ_Source_Flag,
         CASE WHEN tt.GroupCode IS NOT NULL THEN 'Think Tank' ELSE 'Other' END Think_Tank_Flag,
         ROW_NUMBER() OVER(PARTITION BY sc.SourceCode) AS rk
  FROM sandbox_mk.factiva_content_source_current sc
  LEFT JOIN (SELECT SourceCode, GroupCode, GroupName
             FROM sandbox_mk.factiva_content_source_group_current 
             WHERE GroupTypeCode in ('roo','ROO')
               AND GroupCode IN (SELECT CountryCode FROM sandbox_mk.full_roo_table)) sg ON sc.SourceCode = sg.SourceCode
  LEFT JOIN (SELECT SourceCode, GroupCode
             FROM sandbox_mk.factiva_content_source_group_current 
             WHERE lower(GroupCode) = 'tdjp') djs ON sc.SourceCode = djs.SourceCode
  LEFT JOIN (SELECT SourceCode, GroupCode
             FROM sandbox_mk.factiva_content_source_group_current 
             WHERE lower(GroupCode) = 'ttank') tt ON sc.SourceCode = tt.SourceCode)
             
SELECT *
FROM total_codes
WHERE rk=1
