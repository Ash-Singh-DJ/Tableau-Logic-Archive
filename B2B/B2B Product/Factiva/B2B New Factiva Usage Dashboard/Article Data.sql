-- Dashboard   : "B2B New Factiva Usage Dashboard"  [B2B / B2B Product / Factiva]
-- Data source : "Article Data" (embedded in the workbook)
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select year_month_day, year_month, EID, user_id, plan_id, user_info_account_id, company_name, company_industry, company_country,    
  ti_td_page_section, ti_td_page_subsection, ti_td_page_sub_subsection, ti_td_content_source_language, ti_td_page_content_source, ti_td_article_id,
  ti_td_article_headline, ti_td_module_tracker, action_lag, ti_td_page_referring_url, ti_td_page_content_type, count(event_name) as sum_page_views


from 
(select date_time,
substring(cast(djm.cycle_date as varchar),1,10) year_month_day,
               substring(cast(djm.cycle_date as varchar),1,7) year_month,
		djm.user_info_user_ref EID,
		mem.user_id user_id,
		mem.plan_id plan_id,
        djm.user_info_account_id,
        comp.company_name,
        comp.company_industry,
        comp.company_country,
        ti_td_page_section,
          ti_td_page_subsection,
        ti_td_page_sub_subsection,
        ti_td_content_source_language,
         ti_td_page_content_source,
       ti_td_article_id,
        ti_td_article_headline,
       ti_td_module_tracker,
       ti_td_action,
       event_name,
       lag(ti_td_action, 1) over (partition by visit_id order by date_time) as action_lag,
         ti_td_page_referring_url,
         ti_td_page_content_type
       
        
FROM pib_event_data.pib_product_metrics djm
LEFT JOIN dimension_external_db.pib_billing_account_dimension bad on djm.user_info_account_id = bad.cibs_billing_account_id
LEFT JOIN dimension_external_db.pib_company_dimension comp on comp.company_sfdc_id = bad.salesforce_company_two
LEFT JOIN dimension_external_db.pib_membership_dimension mem ON mem.pib_member_id = djm.user_info_user_ref
WHERE product = 'New Factiva'
--and user_info_user_ref = 'E6OO2HVCQHVPFICLUBMGV2NQG4'
and (ti_td_article_id is not null or ti_td_action = 'bookmarks' or ti_td_module_tracker like '%email_digest%' or ti_td_module_tracker like '%email_interest%'
or ti_td_module_tracker like '%saturdayReviewRecommendedSources%' or ti_td_module_tracker like '%saturdayReviewSavedSources%' or ti_td_module_tracker like '%saturdayReviewTrending%'
or ti_td_action in ('summary_citations', 'summary_analysis_citations', 'summary_sources', 'summary_analysis_sources', 'chat_citations'))

and djm.event_name in ('page_view', 'user_action') 
and cycle_date >>= cast('2025-11-01' as date))
where ti_td_article_id is not null 
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20
