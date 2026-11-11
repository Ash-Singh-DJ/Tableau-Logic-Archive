-- Published data source : "B2B New Factiva Onboarding Metrics - Source Pages"  [B2B / B2B Product / Factiva / Datasources / B2B New Factiva Onboarding Data Sources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with base as 
(select year_month_day, year_month, EID, user_id, billing_account_id, company_name, company_industry, 
    ti_td_page_name,
    event_id,
    event_name,
    ti_td_page_url, 
        ti_td_action,
        ti_td_page_subsection,
        ti_td_page_content_source,
        ti_td_page_content_type, 
        ti_td_page_content_type_detail,
           ti_td_search_record_type,
         ti_td_page_section,
        ti_td_page_sub_subsection,
          ti_td_module_tracker,
          lead(ti_td_action,1) over (partition by visit_id order by date_time, event_name) as search_tag
      
          from
        
(select date_time,
               substring(cast(djm.cycle_date as varchar),1,10) year_month_day,
               substring(cast(djm.cycle_date as varchar),1,7) year_month,
		djm.user_info_user_ref EID,
		mem.user_id user_id,
		visit_id,
		event_id,
        event_name,
        djm.user_info_account_id as billing_account_id,
        ti_td_page_content_platform_presentation,
        ti_td_page_url, 
        comp.company_name,
        comp.company_industry,
        comp.company_country,
        ti_td_page_name,
        ti_td_action,
        ti_td_page_subsection,
        ti_td_page_content_source,
        ti_td_page_content_type, 
        ti_td_page_content_type_detail,
        ti_td_page_position,
          ti_td_search_record_type,
         ti_td_page_section,
        ti_td_page_sub_subsection,
          ti_td_module_tracker,
          ti_td_ad_sort_by,
          ti_td_search_results_count
        
FROM pib_event_data.pib_product_metrics djm
LEFT JOIN dimension_external_db.pib_billing_account_dimension bad on djm.user_info_account_id = bad.cibs_billing_account_id
LEFT JOIN dimension_external_db.pib_company_dimension comp on comp.company_sfdc_id = bad.salesforce_company_two
LEFT JOIN dimension_external_db.pib_membership_dimension mem ON mem.pib_member_id = djm.user_info_user_ref
WHERE product = 'New Factiva'
and cycle_date >>= cast('2024-01-15' as date)
--and user_info_user_ref = 'E6OO2HVCQHVPFICLUBMGV2NQG4'
and ((lower(ti_td_page_section) = 'source' or ti_td_search_record_type = 'source') or ti_td_module_tracker like '%saturdayReview%' or ti_td_action like '%saturday_review_%'
or (ti_td_page_url like '%mod=SaturdayReview%' and event_name = 'page_view')) 
and event_name is not null
--and visit_id = 'NEWFACTIVA_20240110_E6OO2HVCQHVPFICLUBMGV2NQG4_000007'
order by date_time))

select 
year_month_day, year_month, EID, user_id, billing_account_id, company_name, company_industry, 
    ti_td_page_name,
    ti_td_page_url,
        ti_td_action,
        ti_td_page_subsection,
        ti_td_page_content_source,
        ti_td_page_content_type, 
        ti_td_page_content_type_detail,
           ti_td_search_record_type,
         ti_td_page_section,
        ti_td_page_sub_subsection,
          ti_td_module_tracker,
        search_tag,
             sum(case when event_name = 'page_view' THEN 1 ELSE 0 END) page_views,
          sum(case when event_name = 'user_action' THEN 1 ELSE 0 END) user_actions
          from base
          
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9 ,10, 11,12,13,14,15,16,17,18,19
