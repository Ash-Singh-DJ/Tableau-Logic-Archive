-- Dashboard   : "B2B New Factiva Onboarding Metrics"  [B2B / Factiva Legacy (for review)]
-- Data source : "B2B New Factiva Onboarding New Factiva" = published source "B2B New Factiva Onboarding Metrics - New Factiva"  [B2B / B2B Product / Factiva / Datasources / B2B New Factiva Onboarding Data Sources]
-- Relation    : Custom SQL "Main Metrics"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with
jf as 
(select pib_member_id, department_code, job_function_code_last_updated_at 
from dimension_external_db.pib_membership_dimension 
where job_function_code_last_updated_at is not null
and department_code <<>> 'OT')




SELECT
               substring(cast(djm.cycle_date as varchar),1,10) year_month_day,
               substring(cast(djm.cycle_date as varchar),1,7) year_month,
          
		djm.user_info_user_ref EID,
		mem.user_id user_id,
		mem.plan_id plan_id,
		jf.department_code,
        djm.user_info_account_id,
        ti_td_page_content_platform_presentation,
        ti_bd_resolution_height,
        ti_bd_resolution_width,
        comp.company_name,
        ter.territory_name,
        comp.company_industry,
    
        COUNT(distinct CASE WHEN djm.event_name = 'user_action' AND ti_td_action = 'complete_setup_languages' THEN djm.user_info_user_ref end) onboard_lang_setup_user_count,
        COUNT(distinct CASE WHEN djm.event_name = 'user_action' AND ti_td_action = 'complete_setup_interests' THEN djm.user_info_user_ref end) onboard_int_setup_user_count,
        COUNT(distinct CASE WHEN djm.event_name = 'user_action' AND ti_td_action = 'complete_onboarding' THEN djm.user_info_user_ref end) onboard_complete_user_count,
        COUNT(distinct CASE WHEN ti_td_page_section like '%Onboarding%' THEN djm.user_info_user_ref end) onboard_start_user_count


        
FROM pib_event_data.pib_product_metrics djm
INNER JOIN dimension_external_db.pib_membership_dimension mem ON mem.pib_member_id = djm.user_info_user_ref
LEFT JOIN dimension_external_db.pib_billing_account_dimension bad on djm.user_info_account_id = bad.cibs_billing_account_id
LEFT JOIN dimension_external_db.pib_company_dimension comp on comp.company_sfdc_id = bad.salesforce_company_two
left join dimension_external_db.pib_territory_dimension ter on comp.company_territory = ter.territory_sfdc_id
left join jf on mem.pib_member_id = jf.pib_member_id

WHERE product = 'New Factiva' 
and cycle_date >>= cast('2024-02-01' as date)
and ti_td_page_section like '%Onboarding%' 

group by 1,2,3,4,5,6,7,8,9,10,11,12,13
