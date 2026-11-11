-- Published data source : "B2B Marketing Events Dataset - Reworked"  [B2B / B2B Marketing / Datasources]
-- Relation    : Custom SQL "Custom SQL Query1"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
SELECT camp_mem.type,
       camp_mem.status,
       camp_mem.name,
       camp_mem.lead_source,
       camp_mem.has_responded_flag,
       camp_mem.has_opted_out_of_fax_flag,
       camp_mem.has_opted_out_of_email_flag,
       camp_mem.email,
       camp_mem.do_not_call_flag,
       camp_mem.created_date,
       camp_mem.country,
       camp_mem.company_or_account,
       camp_mem.campaign_member_id,
       camp_mem.campaign_id,
       DATE_TRUNC('day',pld.lead_created_date) lead_created_date,
       pld.product_of_interest,
       pld.web_form_name,
       pld.region,
       COALESCE(ctd.marketing_tactic_original, pld.marketing_tactic_original) marketing_tactic_original,
       COALESCE(ctd.marketing_tactic_most_recent, pld.marketing_tactic_most_recent) marketing_tactic_most_recent,
       pld.lead_status,
       COALESCE(ctd.lead_score, pld.lead_score) lead_score,
       camp_mem.lead_or_contact_owner_id owner_id,
       user_dim.user_full_name owner_name,
       COALESCE(ctd.contact_country, pld.lead_country) contact_lead_country,
       pld.lead_converted_flag,
       pld.lead_company,
       pld.content_type,
       COALESCE(ctd.buying_center, pld.buying_center) buying_center,
       camp_dim_parent.type campaign_type_parent,
       camp_dim.type campaign_type,
       DATE_TRUNC('day',camp_dim_parent.created_datetime) campaign_created_date_parent,
       DATE_TRUNC('day',camp_dim.created_datetime) campaign_created_date,
       camp_dim_parent.name campaign_name_parent,
       camp_dim.name campaign_name,
       camp_dim_parent.sfdc_campaign_id sfdc_campaign_id_parent,
       camp_dim.sfdc_campaign_id sfdc_campaign_id,
       DATE_TRUNC('day',camp_dim_parent.start_date) campaign_start_date_parent,
       DATE_TRUNC('day',camp_dim.start_date) campaign_start_date,
       camp_dim_parent.status campaign_status_parent,
       camp_dim.status campaign_status
FROM (SELECT * FROM dimension_external_db.pib_campaign_member_dimension WHERE status_flag <<>> 'DELETE') camp_mem
LEFT JOIN (SELECT * FROM dimension_external_db.pib_leads_dimension WHERE status_flag <<>> 'DELETE') pld ON camp_mem.lead_id = pld.lead_sfdc_id
LEFT JOIN (SELECT * FROM dimension_external_db.pib_contact_dimension WHERE status_flag <<>> 'DELETE') ctd ON camp_mem.contact_id = ctd.contact_sfdc_id
LEFT JOIN (SELECT * FROM dimension_external_db.pib_campaign_dimension WHERE status_flag <<>> 'DELETE') camp_dim ON camp_mem.campaign_id = camp_dim.sfdc_campaign_id
LEFT JOIN (SELECT * FROM dimension_external_db.pib_campaign_dimension WHERE status_flag <<>> 'DELETE') camp_dim_parent ON camp_dim.parent_id = camp_dim_parent.sfdc_campaign_id
LEFT JOIN (SELECT * FROM dimension_external_db.pib_user_dimension WHERE status_flag <<>> 'DELETE') user_dim ON camp_mem.lead_or_contact_owner_id = user_dim.user_sfdc_id
