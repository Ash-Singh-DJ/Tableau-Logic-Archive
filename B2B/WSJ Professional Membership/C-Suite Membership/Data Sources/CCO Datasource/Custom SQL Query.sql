-- Published data source : "CCO Datasource"  [B2B / WSJ Professional Membership / C-Suite Membership / Data Sources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / sandbox_pecom), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
WITH
  camp_mem_db AS (
   SELECT
     camp_mem.type
   , camp_mem.status
   , camp_mem.name
   , camp_mem.lead_source
   , camp_mem.has_responded_flag
   , camp_mem.has_opted_out_of_fax_flag
   , camp_mem.has_opted_out_of_email_flag
   , camp_mem.email
   , camp_mem.contact_id
   , camp_mem.lead_id
   , camp_mem.do_not_call_flag
   , camp_mem.created_date
   , camp_mem.country
   , camp_mem.company_or_account
   , camp_mem.campaign_member_id
   , camp_mem.campaign_id
   , coalesce(ctd.account_id, lds.converted_account_id) account_id
   , comp.company_name
    , coalesce(ctd.job_title, lds.lead_title) job_title
   , coalesce(ctd.marketing_tactic_original, lds.marketing_tactic_original) marketing_tactic_original
   , coalesce(ctd.marketing_tactic_most_recent, lds.marketing_tactic_most_recent) marketing_tactic_most_recent
   , coalesce(ctd.lead_score, lds.lead_score) lead_score
   , camp_mem.lead_or_contact_owner_id owner_id
   , user_dim.user_full_name owner_name
   , coalesce(ctd.contact_country,lead_country_name) contact_country
   , coalesce(ctd.buying_center, lds.buying_center) buying_center
   , coalesce(ctd.product_of_interest, lds.product_of_interest) product_of_interest
   , camp_dim.name campaign_name
   , camp_dim.sfdc_campaign_id sfdc_campaign_id
   , DATE_TRUNC('day', camp_dim.start_date) campaign_start_date
   , camp_dim.status campaign_status
   FROM
     
      (SELECT *
      FROM
        dimension_external_db.pib_campaign_member_dimension
      WHERE (status_flag <<>> 'DELETE')
   )  camp_mem
   LEFT JOIN (
      SELECT *
      FROM
        dimension_external_db.pib_contact_dimension
      WHERE (status_flag <<>> 'DELETE')
   )  ctd ON (camp_mem.contact_id = ctd.contact_sfdc_id)
   LEFT JOIN (
      SELECT *
      FROM
        dimension_external_db.pib_leads_dimension 
      WHERE (status_flag <<>> 'DELETE')
   )  lds ON (camp_mem.lead_id = lds.lead_sfdc_id)
   LEFT JOIN (
      SELECT *
      FROM
        dimension_external_db.pib_campaign_dimension
      WHERE (status_flag <<>> 'DELETE')
   )  camp_dim ON (camp_mem.campaign_id = camp_dim.sfdc_campaign_id)
   LEFT JOIN (
      SELECT *
      FROM
        dimension_external_db.pib_campaign_dimension
      WHERE (status_flag <<>> 'DELETE')
   )  camp_dim_parent ON (camp_dim.parent_id = camp_dim_parent.sfdc_campaign_id)
   LEFT JOIN (
      SELECT *
      FROM
        dimension_external_db.pib_user_dimension
      WHERE (status_flag <<>> 'DELETE')
   )  user_dim ON (camp_mem.lead_or_contact_owner_id = user_dim.user_sfdc_id)
   LEFT JOIN dimension_external_db.pib_company_dimension comp ON (comp.company_sfdc_id = ctd.account_id)
) 
SELECT camp_mem_db.*, mk.job_function
FROM
  camp_mem_db
left join dimension_external_db.pib_membership_dimension mem on camp_mem_db.email = mem.email
left join  sandbox_mk."1p_job_function_department_code_mapping" mk on mem.department_code = mk.department_code
WHERE (campaign_start_date >>= date('2023-07-01'))
and ((campaign_id='7015Y000004G28YQAS'and product_of_interest like '%CCO Council%') or campaign_name like '%CCO%') and lower(camp_mem_db.job_title)<<>>'test'
