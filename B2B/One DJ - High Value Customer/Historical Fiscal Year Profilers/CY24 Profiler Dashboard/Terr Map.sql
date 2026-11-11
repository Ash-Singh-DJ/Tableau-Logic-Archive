-- Dashboard   : "CY24 Profiler Dashboard"  [B2B / One DJ - High Value Customer / Historical Fiscal Year Profilers]
-- Data source : "Terr Map" (embedded in the workbook)
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / sandbox_mk), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
WITH primary_submap AS ( -- anti-duplication submapping
 	SELECT 
 		DISTINCT duns_number, 
 		primary_name  
 	FROM dnb_firmographic_db.company_information_current
 	GROUP BY 1,2 
 	UNION ALL -- Catch-all logic for unmapped accounts
 	SELECT 
		'999999999' AS duns_number, 
		'Unmapped Accounts' AS primary_name 
), 

linkage_submap AS ( 
	SELECT 
		lnk.duns_number,
		lnk.parent_duns, 
		lnk.head_quarter_duns, 
		COALESCE(lnk.global_ultimate_duns, lnk.duns_number) AS global_ultimate_duns,
		coalesce(lnk.global_ult_name, ps.primary_name) as global_ult_name, 
		lnk.is_standalone,
		ps.primary_name
	FROM (
		SELECT 
			DISTINCT duns_number, 
			parent_duns, 
			head_quarter_duns, 
			COALESCE(global_ultimate_duns, duns_number) AS global_ultimate_duns, 
            global_ultimate_primary_name as global_ult_name,
			is_standalone 
		FROM dnb_firmographic_db.corporate_linkage_current 
		GROUP BY 1 ,2,3,4,5,6
	 	UNION ALL 
	 	SELECT 
			'999999999' AS duns_number, 
			NULL AS parent_duns, 
			NULL AS head_quarter_duns, 
			'999999999' AS global_ultimate_duns, 
                        null global_ult_name,
			TRUE AS is_standalone 
	) lnk 
	JOIN primary_submap ps 
		ON lnk.duns_number = ps.duns_number 
), 

hvc_override as (
	SELECT 
		DISTINCT link.global_ult_name, 
		COALESCE(guo.parent_override, link.global_ult_name) AS parent_override 
	FROM linkage_submap link
	LEFT JOIN google_sheets_db.dnb_hvcs_global_ultimate_override guo
		ON link.global_ult_name = guo.global_ultimate_name 
) 

SELECT 
    DISTINCT prof.territory_name, 
    prof.duns_number, 
    COALESCE(link.global_ultimate_duns, prof.duns_number) AS global_ultimate_duns, 
    parent_override 
FROM sandbox_hvc.duns_profiler_tranche13 prof 
FULL JOIN primary_submap comp 
    ON comp.duns_number = prof.duns_number 
LEFT JOIN linkage_submap link 
    ON comp.duns_number = link.duns_number 
LEFT JOIN hvc_override hvc 
    ON hvc.global_ult_name = link.global_ult_name
