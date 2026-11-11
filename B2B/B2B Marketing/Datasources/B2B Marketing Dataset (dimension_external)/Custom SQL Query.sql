-- Published data source : "B2B Marketing Dataset (dimension_external)"  [B2B / B2B Marketing / Datasources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
WITH campaign_fact as (
  SELECT camp.sfdc_campaign_id, camp_mem.campaign_member_id, cont.contact_sfdc_id, lead.lead_sfdc_id
  FROM dimension_external_db.pib_campaign_dimension camp
  LEFT JOIN dimension_external_db.pib_campaign_member_dimension camp_mem on camp.sfdc_campaign_id = camp_mem.campaign_id
  LEFT JOIN dimension_external_db.pib_contact_dimension cont on camp_mem.contact_id = cont.contact_sfdc_id
  LEFT JOIN dimension_external_db.pib_leads_dimension lead on camp_mem.lead_id = lead.lead_sfdc_id
)
/*,
  
parent_ids AS (
	SELECT parent_id 
	FROM dimension_external_db.pib_campaign_dimension 
    WHERE parent_id IS NOT NULL 
    GROUP BY parent_id
)*/
/*,

camp_dim AS (
	SELECT * 
	FROM dimension_external_db.pib_campaign_dimension 
	WHERE status_flag <<>> 'DELETE' 
		AND sfdc_campaign_id NOT IN (SELECT parent_id FROM parent_ids) 
)*/
,

camp_hier as (
SELECT hier.*, camp1.name AS campaign_name,
				camp1.type AS campaign_type,
				camp2.name AS ultimate_campaign_parent_name,
				camp2.type AS ultimate_campaign_parent_type,
				camp3.name AS direct_parent_campaign_name,
				camp3.type AS direct_parent_campaign_type,
				camp4.name AS direct_child_campaign_name,
				camp4.type AS direct_child_campaign_type
FROM sandbox_spb.pib_campaign_hierarchy hier
LEFT JOIN dimension_external_db.pib_campaign_dimension camp1 ON camp1.sfdc_campaign_id = hier.sfdc_campaign_id
LEFT JOIN dimension_external_db.pib_campaign_dimension camp2 ON camp2.sfdc_campaign_id = hier.ultimate_campaign_parent_id
LEFT JOIN dimension_external_db.pib_campaign_dimension camp3 ON camp3.sfdc_campaign_id = hier.direct_parent_sfdc_campaign_id
LEFT JOIN dimension_external_db.pib_campaign_dimension camp4 ON camp4.sfdc_campaign_id = hier.direct_child_sfdc_campaign_id)

SELECT DISTINCT 
	   campaign_fact.contact_sfdc_id,
	   campaign_fact.lead_sfdc_id,
	   --COALESCE(camp_dim_parent.type, camp_dim_parent_direct.type) campaign_type_parent,
       --camp_dim.type campaign_type_child,
       --DATE_TRUNC('day',COALESCE(camp_dim_parent.created_datetime, camp_dim_parent_direct.created_datetime)) campaign_created_date_parent,
       --DATE_TRUNC('day',camp_dim.created_datetime) campaign_created_date_child,
       --COALESCE(camp_dim_parent.name, camp_dim_parent_direct.name) campaign_name_parent,
       --camp_dim.name campaign_name_child,
       --COALESCE(camp_dim_parent.sfdc_campaign_id, camp_dim_parent_direct.sfdc_campaign_id) sfdc_campaign_id_parent,
       --camp_dim.sfdc_campaign_id sfdc_campaign_id_child,
       --DATE_TRUNC('day',COALESCE(camp_dim_parent.start_date, camp_dim_parent_direct.start_date)) campaign_start_date_parent,
       --DATE_TRUNC('day',camp_dim.start_date) campaign_start_date_child,
       --COALESCE(camp_dim_parent.status, camp_dim_parent_direct.status) campaign_status_parent,
       --camp_dim.status campaign_status_child,
       cp.*
FROM campaign_fact
--LEFT JOIN camp_dim ON campaign_fact.sfdc_campaign_id = camp_dim.sfdc_campaign_id
--LEFT JOIN (SELECT * FROM dimension_external_db.pib_campaign_dimension WHERE status_flag <<>> 'DELETE') camp_dim_parent ON camp_dim.parent_id = camp_dim_parent.sfdc_campaign_id
--LEFT JOIN (SELECT * FROM dimension_external_db.pib_campaign_dimension WHERE status_flag <<>> 'DELETE' AND sfdc_campaign_id IN
--            (SELECT parent_id FROM parent_ids)) camp_dim_parent_direct ON campaign_fact.sfdc_campaign_id = camp_dim_parent_direct.sfdc_campaign_id
left join camp_hier cp on campaign_fact.sfdc_campaign_id = cp.sfdc_campaign_id
            
--select * from sandbox_spb.pib_campaign_hierarchy
