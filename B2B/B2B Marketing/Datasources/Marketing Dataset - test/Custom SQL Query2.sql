-- Published data source : "Marketing Dataset - test"  [B2B / B2B Marketing / Datasources]
-- Relation    : Custom SQL "Custom SQL Query2"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
SELECT DISTINCT COALESCE(mid.lead_name, ld2.lead_sfdc_id) AS lead_sfdc_id, 
	   COALESCE(mid.contact_name, ld.converted_contact_id) AS contact_sfdc_id,
	   array_distinct(array_agg(utm_campaign ORDER BY utm_campaign) FILTER (WHERE utm_campaign IS NOT NULL)) utm_campaign_list,
	   array_distinct(array_agg(utm_source ORDER BY utm_source) FILTER (WHERE utm_source IS NOT NULL)) utm_source_list,
	   array_distinct(array_agg(utm_content ORDER BY utm_content) FILTER (WHERE utm_content IS NOT NULL)) utm_content_list,
	   array_distinct(array_agg(utm_term ORDER BY utm_term) FILTER (WHERE utm_term IS NOT NULL)) utm_term_list,
	   array_distinct(array_agg(utm_medium ORDER BY utm_medium) FILTER (WHERE utm_medium IS NOT NULL)) utm_medium_list
FROM dimension_external_db.pib_marketing_interaction_dimension mid
LEFT JOIN (SELECT * FROM dimension_external_db.pib_leads_dimension WHERE status_flag <<>> 'DELETE') ld ON mid.lead_name = ld.lead_sfdc_id
LEFT JOIN (SELECT * FROM dimension_external_db.pib_leads_dimension WHERE status_flag <<>> 'DELETE') ld2 ON mid.contact_name = ld2.converted_contact_id
WHERE mid.status_flag <<>> 'DELETE'
	AND (utm_campaign IS NOT NULL OR utm_source IS NOT NULL 
		OR utm_content IS NOT NULL OR utm_medium IS NOT NULL 
		OR utm_term IS NOT NULL)
GROUP BY 1, 2
