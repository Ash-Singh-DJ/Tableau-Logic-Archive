-- Dashboard   : "B2B New Factiva Usage Dashboard"  [B2B / B2B Product / Factiva]
-- Data source : "New Factiva" (embedded in the workbook)
-- Relation    : Custom SQL "Main Metrics"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with wk as
(select substring(cast(full_date as varchar),1,10) year_month_day, substring(cast(week_start_date as varchar),1,10) week_start, day_of_week from reference_external_db.date_dimension
where substring(cast(full_date as varchar),1,10) >>= cast('2021-01-01' as varchar)
order by full_date),

jf as 
(select pib_member_id, department_code, job_function_code_last_updated_at 
from dimension_external_db.pib_membership_dimension 
where job_function_code_last_updated_at is not null
and department_code <<>> 'OT')




SELECT
               substring(cast(djm.cycle_date as varchar),1,10) year_month_day,
               substring(cast(djm.cycle_date as varchar),1,7) year_month,
                wk.week_start,
                wk.day_of_week,
		djm.user_info_user_ref EID,
		mem.user_id user_id,
		mem.plan_id plan_id,
		jf.department_code,
                SUBSTR(djm.ti_bd_user_agent, STRPOS(djm.ti_bd_user_agent, '(')+1, (STRPOS(djm.ti_bd_user_agent, ';')-1) - STRPOS(djm.ti_bd_user_agent, '(')) operating_system,
        djm.user_info_account_id,
        ti_td_page_content_platform_presentation,
        comp.company_name,
        ter.territory_name,
        comp.company_industry,
        comp.company_country,
        count(distinct case when product = 'New Factiva' then  djm.user_info_user_ref end) distinct_users,
        
        sum(case when djm.event_name = 'page_view' and product = 'New Factiva' THEN 1 ELSE 0 END) page_views,
        sum(case when djm.event_name = 'user_action' and product = 'New Factiva' THEN 1 ELSE 0 END) user_actions,
        sum(CASE WHEN event_name = 'user_action' and ti_td_ad_map_countries is not null THEN 1 ELSE 0 end) country_map_interactions,
        count(DISTINCT case when product = 'New Factiva' then djm.visit_id end) visits,
        count(DISTINCT case when product = 'New Factiva' then user_info_session_id end) sessions,
        count(distinct case when djm.event_name = 'page_view' and (ti_td_page_subsection = 'Search Results' or ti_td_module_tracker_previous_page_location = 'searchBar')  then user_info_session_id else null end) search_sessions,
        max(ti_td_number_of_tabs_total) max_tabs_open,
        COUNT(distinct case when product = 'New Factiva' then djm.cycle_date end) active_days,
        sum(case when djm.event_name = 'user_action' and ti_td_action = 'banner_toggle_new_factiva' and product = 'Factiva'  then 1 else 0 end) nf_banner_clicks,
        sum(case when djm.event_name = 'user_action' and ti_td_action = 'dismiss_switch_new_factiva_banner' and product = 'Factiva'  then 1 else 0 end) nf_banner_dismiss,
        
        SUM(case when product = 'New Factiva' and djm.event_name = 'user_action' and ti_td_action = 'follow_interests' THEN 1 ELSE 0 END) follow_interests_clicks,
        sum(CASE WHEN product = 'New Factiva' and djm.event_name = 'page_view' AND ti_td_page_content_type = 'Article' THEN 1 ELSE 0 END) article_views,
         sum(CASE WHEN djm.event_name = 'page_view' AND ti_td_module_tracker LIKE '%relatedArticles%' AND ti_td_page_content_type = 'Article' THEN 1 ELSE 0 END) article_views_via_rec_articles,
        sum(CASE WHEN djm.event_name = 'page_view' AND ti_td_module_tracker NOT LIKE '%relatedArticles%' AND ti_td_action = 'bookmarks' THEN 1 ELSE 0 END) article_vews_via_alerts,
        sum(CASE WHEN djm.event_name = 'page_view' AND ti_td_page_subsection  = 'Trending News' AND ti_td_page_content_type = 'Article' THEN 1 ELSE 0 END) article_views_via_trending_news,
        sum(CASE WHEN djm.event_name = 'page_view' AND ti_td_page_subsection  = 'Personalized News' AND ti_td_page_content_type = 'Article' THEN 1 ELSE 0 END) article_views_via_personalized_news,
        sum(CASE WHEN djm.event_name = 'page_view' AND ti_td_page_sub_subsection  = 'Corporate Signals' AND ti_td_page_content_type = 'Article' THEN 1 ELSE 0 END) article_views_via_corporate_signals,
        sum(CASE WHEN djm.event_name = 'page_view' AND lower(ti_td_page_section)  = 'company' AND ti_td_page_content_type = 'Article' THEN 1 ELSE 0 END) article_views_company,
        sum(CASE WHEN djm.event_name = 'page_view' AND lower(ti_td_page_section)  = 'industry' AND ti_td_page_content_type = 'Article' THEN 1 ELSE 0 END) article_views_industry,
        sum(CASE WHEN djm.event_name = 'page_view' and ti_td_page_subsection  = 'Search Results' and ti_td_module_tracker_previous_page_location is null AND ti_td_page_content_type = 'Article' THEN 1 ELSE 0 END) articles_search,
        sum(CASE WHEN djm.event_name = 'page_view' AND ti_td_search_record_type = 'free text' AND ti_td_page_content_type_detail  = 'search results' and ti_td_module_tracker like '%previous_page_location%' THEN 1 ELSE 0 end) keyword_search_results_page,
        sum(CASE WHEN djm.event_name = 'page_view' AND ti_td_search_record_type = 'industry' AND ti_td_page_content_type_detail  = 'search results' and ti_td_module_tracker like '%previous_page_location%' THEN 1 ELSE 0 end) industry_searches,
        sum(CASE WHEN djm.event_name = 'page_view' AND ti_td_search_record_type = 'company' AND ti_td_page_content_type_detail  = 'search results' and ti_td_module_tracker like '%previous_page_location%' THEN 1 ELSE 0 end) company_searches,
        sum(CASE WHEN djm.event_name = 'page_view' AND ti_td_search_record_type is not null AND ti_td_page_content_type_detail  = 'search results' and ti_td_module_tracker like '%previous_page_location%' THEN 1 ELSE 0 end) total_searches,
        sum(CASE WHEN djm.event_name = 'page_view' AND ti_td_search_record_type = 'newssubject' AND ti_td_page_content_type_detail  = 'search results' THEN 1 ELSE 0 end) newssubject_search_results_page,
        sum(CASE WHEN djm.event_name = 'page_view' AND ti_td_search_record_type = 'person' AND ti_td_page_content_type_detail  = 'search results' THEN 1 ELSE 0 end) person_search_results_page,
        sum(CASE WHEN djm.event_name = 'page_view' AND ti_td_search_record_type = 'source' AND ti_td_page_content_type_detail  = 'search results' THEN 1 ELSE 0 end) source_search_results_page,
        COUNT(distinct CASE WHEN djm.event_name = 'user_action' AND ti_td_action = 'complete_setup_languages' THEN djm.user_info_user_ref end) onboard_lang_setup_user_count,
        COUNT(distinct CASE WHEN djm.event_name = 'user_action' AND ti_td_action = 'complete_setup_interests' THEN djm.user_info_user_ref end) onboard_int_setup_user_count,
        COUNT(distinct CASE WHEN djm.event_name = 'user_action' AND ti_td_action = 'complete_onboarding' THEN djm.user_info_user_ref end) onboard_complete_user_count,
        COUNT(distinct CASE WHEN ti_td_page_section like '%Onboarding%' THEN djm.user_info_user_ref end) onboard_start_user_count,
        sum(CASE WHEN djm.event_name = 'page_view' AND ti_td_module_tracker_previous_page_location = 'searchBar' THEN 1 ELSE 0 end) company_search_results_page,
        sum(CASE WHEN djm.event_name = 'page_view' AND ti_td_module_tracker_previous_page_location = 'relatedCompanies' THEN 1 ELSE 0 end) related_pills_clicks, 
        sum(case when djm.event_name is null THEN 1 ELSE 0 END) null_events,
        sum(case when djm.event_name = 'user_action' and ti_td_action = 'toggle_classic_factiva' then 1 else 0 end) toggle_clicks_to_classsic,
        sum(case when djm.event_name = 'user_action' and ti_td_action like '%toggle_new_factiva' then 1 else 0 end) toggle_clicks_to_new,
        sum(case when djm.event_name = 'user_action' and ti_td_action = 'personalized_news_email_enable' and ti_td_page_section  = 'Home Page' then 1 else 0 end) dig_enable_icon_clicks, 

        sum(case when djm.event_name = 'user_action' and ti_td_action = 'filter_search' and
        ti_td_ad_search_filters_search_number_of_filters >>= 1  then 1 else 0 end) apply_filter,
        sum(CASE WHEN djm.event_name = 'page_view' AND ti_td_page_section  = 'Settings' THEN 1 ELSE 0 END) Settings_total_page,
        sum(CASE WHEN djm.event_name = 'page_view' AND ti_td_page_section  = 'Settings' AND ti_td_page_subsection = 'Interest Settings' THEN 1 ELSE 0 END) Settings_Interests_page,
        sum(CASE WHEN djm.event_name = 'page_view' AND ti_td_page_section  = 'Settings' AND ti_td_page_subsection = 'Content Language' THEN 1 ELSE 0 END) Settings_Content_Lang_page,
        sum(CASE WHEN djm.event_name = 'page_view' AND ti_td_page_section  = 'Settings' AND ti_td_page_subsection = 'Interface Language' THEN 1 ELSE 0 END) Settings_Interface_Lang_page,
        SUM(CASE WHEN djm.event_name = 'user_action' AND ti_td_page_section  = 'Settings' AND ti_td_action = 'personalized_news_email_enable' THEN 1 ELSE 0 END) digest_email_enable,
        SUM(CASE WHEN djm.event_name = 'user_action' AND ti_td_page_section  = 'Settings' AND ti_td_action = 'personalized_news_email_disable' THEN 1 ELSE 0 END) digest_email_disable,
        SUM(CASE WHEN djm.event_name = 'user_action' AND ti_td_page_section  = 'Settings' AND ti_td_action = 'interest_email_enable' THEN 1 ELSE 0 END) interest_email_enable,
        SUM(CASE WHEN djm.event_name = 'user_action' AND ti_td_page_section  = 'Settings' AND ti_td_action = 'interest_email_disable' THEN 1 ELSE 0 END) interest_email_disable,
        SUM(CASE WHEN djm.event_name = 'user_action' AND ti_td_page_section  = 'Settings' AND ti_td_action = 'interest_change_email_frequency' and ti_td_ad_email_frequency = 'Weekly' THEN 1 ELSE 0 END) interest_change_to_weekly,
        SUM(CASE WHEN djm.event_name = 'user_action' AND ti_td_page_section  = 'Settings' AND ti_td_action = 'personalized_news_change_email_frequency' and ti_td_ad_email_frequency = 'Weekly' THEN 1 ELSE 0 END) digest_change_to_weekly,
         SUM(CASE WHEN djm.event_name = 'user_action' AND ti_td_page_section  = 'Settings' AND ti_td_action = 'interest_change_email_frequency' and ti_td_ad_email_frequency = 'Daily' THEN 1 ELSE 0 END) interest_change_to_daily,
        SUM(CASE WHEN djm.event_name = 'user_action' AND ti_td_page_section  = 'Settings' AND ti_td_action = 'personalized_news_change_email_frequency' and ti_td_ad_email_frequency = 'Daily' THEN 1 ELSE 0 END) digest_change_to_daily

        
FROM pib_event_data.pib_product_metrics djm
INNER JOIN dimension_external_db.pib_membership_dimension mem ON mem.pib_member_id = djm.user_info_user_ref
LEFT JOIN dimension_external_db.pib_billing_account_dimension bad on djm.user_info_account_id = bad.cibs_billing_account_id
LEFT JOIN dimension_external_db.pib_company_dimension comp on comp.company_sfdc_id = bad.salesforce_company_two
left join dimension_external_db.pib_territory_dimension ter on comp.company_territory = ter.territory_sfdc_id
left join jf on mem.pib_member_id = jf.pib_member_id
LEFT JOIN wk on substring(cast(djm.cycle_date as varchar),1,10) = wk.year_month_day

WHERE product = 'New Factiva' or (product = 'Factiva' and (ti_td_action like '%toggle_new_factiva' or ti_td_action like '%banner%'))
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9 ,10, 11,12,13,14,15
