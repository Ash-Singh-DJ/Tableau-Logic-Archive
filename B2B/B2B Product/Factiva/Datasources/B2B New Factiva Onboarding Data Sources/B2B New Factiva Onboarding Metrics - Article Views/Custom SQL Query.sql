-- Published data source : "B2B New Factiva Onboarding Metrics - Article Views"  [B2B / B2B Product / Factiva / Datasources / B2B New Factiva Onboarding Data Sources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
SELECT 
              
               substring(cast(djm.cycle_date as varchar),1,7) year_month,
		djm.user_info_user_ref EID,
		mem.user_id user_id,
		mem.plan_id plan_id,
                SUBSTR(djm.ti_bd_user_agent, STRPOS(djm.ti_bd_user_agent, '(')+1, (STRPOS(djm.ti_bd_user_agent, ';')-1) - STRPOS(djm.ti_bd_user_agent, '(')) operating_system,
        djm.user_info_account_id,
        ti_td_page_content_platform_presentation,
        comp.company_name,
        comp.company_industry,
        comp.company_country,
        
        (CASE WHEN djm.event_name = 'page_view' AND ti_td_page_section  = 'Company' AND ti_td_page_content_type = 'Article' then 'company_avs'
          WHEN djm.event_name = 'page_view' AND ti_td_module_tracker_previous_page_location = 'Recommended Articles' AND ti_td_page_content_type = 'Article' then 'recommended_avs'
          WHEN djm.event_name = 'page_view' AND ti_td_page_subsection  = 'Trending News' AND ti_td_page_content_type = 'Article' THEN 'trending_avs'
          WHEN djm.event_name = 'page_view' AND ti_td_page_subsection  = 'Personalized News' AND ti_td_page_content_type = 'Article' then 'personalized_avs'
          WHEN djm.event_name = 'page_view' AND ti_td_page_sub_subsection  = 'Corporate Signals' AND ti_td_page_content_type = 'Article' then 'corp_sig_avs'
          WHEN djm.event_name = 'page_view' and ti_td_page_subsection  = 'Search Results' and ti_td_module_tracker_previous_page_location is null AND ti_td_page_content_type = 'Article' THEN 'free_text_avs'
         else null end) as av_type,
        
         sum(CASE WHEN djm.event_name = 'page_view' AND ti_td_page_content_type = 'Article' THEN 1 ELSE 0 END) article_views
        
FROM pib_event_data.pib_product_metrics djm
LEFT JOIN dimension_external_db.pib_billing_account_dimension bad on djm.user_info_account_id = bad.cibs_billing_account_id
LEFT JOIN dimension_external_db.pib_company_dimension comp on comp.company_sfdc_id = bad.salesforce_company_two
LEFT JOIN dimension_external_db.pib_membership_dimension mem ON mem.pib_member_id = djm.user_info_user_ref
WHERE product = 'New Factiva'
and ti_td_page_content_type = 'Article'
and djm.event_name = 'page_view'
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9 ,10, 11
