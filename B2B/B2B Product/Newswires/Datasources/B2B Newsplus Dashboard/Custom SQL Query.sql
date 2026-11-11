-- Published data source : "B2B Newsplus Dashboard"  [B2B / B2B Product / Newswires / Datasources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
SELECT pmd.user_id as USER_ID,
	   pmd.first_name as FIRST_NAME,
	   pmd.last_name as LAST_NAME,
	   pmd.email as EMAIL,
	   pmd.billing_account_id as ACCOUNT_ID,
	   cycle_date,
	   date_time,
	   comp.company_sfdc_id,
	   comp.company_name,
	   ti_td_article_id,
	   ti_td_article_headline,
	   REGEXP_EXTRACT(ti_td_page_url, 'https?://[^/]+\.com') AS URL_Base,
	   count(distinct cycle_date) ACTIVE_DAYS,
	   count(distinct user_info_session_id) SESSIONS,
	   sum(case when event_name = 'user_action' THEN 1 ELSE 0 END) USER_ACTIONS,
	   sum(case when event_name = 'page_view' THEN 1 ELSE 0 END) PAGE_VIEWS, 
	   
	   sum(CASE WHEN event_name = 'page_view' AND ti_td_page_content_type = 'Article' THEN 1 ELSE 0 END) ARTICLE_VIEWS,
	   sum(CASE WHEN event_name = 'page_view' AND ti_td_page_content_type = 'Article' and ti_td_module_tracker like '%search%' THEN 1 ELSE 0 END) Search_ARTICLE_VIEWS,
	 --  sum(CASE WHEN event_name = 'page_view' AND ti_td_page_content_type = 'Article' and ti_td_module_tracker != 'advancedsearch' THEN 1 ELSE 0 END) Non_Search_ARTICLE_VIEWS,
	   sum(CASE WHEN event_name = 'page_view' and ti_td_page_content_type = 'CustomerResource' THEN 1 ELSE 0 END) RESOURCE_VIEWS,
	   sum(CASE WHEN event_name = 'page_view' and ti_td_page_content_type = 'Home' THEN 1 ELSE 0 END) HOME_VIEWS,
	   sum(CASE WHEN event_name = 'page_view' and ti_td_page_content_type = 'ResearchTools' THEN 1 ELSE 0 END) RESEARCH_VIEWS,
	 --  sum(CASE WHEN event_name = 'page_view' and ti_td_page_content_type = 'Summaries' THEN 1 ELSE 0 END) SUMMARY_VIEWS,
	   
	   sum(CASE WHEN event_name = 'page_view'  THEN 1 ELSE 0 END) NEWS_VIEWS,
	   sum(CASE WHEN event_name = 'page_view' and ti_td_page_section like '%Search%' THEN 1 ELSE 0 END) SEARCH_VIEWS,
	   sum(CASE WHEN event_name = 'page_view' and ti_td_page_section like '%Calendar%'  THEN 1 ELSE 0 END) CALENDAR_VIEWS,
	   
	   sum(CASE WHEN event_name = 'page_view' and ti_td_page_subsection like '%Alerts%' THEN 1 ELSE 0 END) ALERTS_VIEWS,
	   sum(CASE WHEN event_name = 'page_view' and ti_td_page_subsection like '%Settings%' THEN 1 ELSE 0 END) SETTINGS_VIEWS,
	   sum(CASE WHEN event_name = 'page_view' and ti_td_page_subsection like '%Subscriptions%' THEN 1 ELSE 0 END) SUBSCRIPTION_VIEWS,
	   
	  --Newstopic 
	   sum(CASE WHEN event_name = 'page_view' and ti_td_page_content_type like 'Summaries' THEN 1 ELSE 0 END) SUMMARY_VIEWS,
	   
	   sum(CASE WHEN event_name = 'page_view' and ti_td_page_content_type like 'Summaries' 
	             and ti_td_page_section = 'Industries' THEN 1 ELSE 0 END) Industries,
	   sum(CASE WHEN event_name = 'page_view' and ti_td_page_content_type like 'Summaries' 
	             and ti_td_page_section = 'Regions' THEN 1 ELSE 0 END) Regions,
	   sum(CASE WHEN event_name = 'page_view' and ti_td_page_content_type like 'Summaries' 
	             and ti_td_page_section = 'Topic Views' THEN 1 ELSE 0 END) Topic_Views,
	             
	   sum(CASE WHEN event_name = 'page_view' and ti_td_page_content_type like 'Summaries' 
	             and ti_td_page_section = 'Industries' and  ti_td_page_subsection = 'Retail' THEN 1 ELSE 0 END) Retail,
	   sum(CASE WHEN event_name = 'page_view' and ti_td_page_content_type like 'Summaries' 
	             and ti_td_page_section = 'Industries' and  ti_td_page_subsection = 'Consumer Products' THEN 1 ELSE 0 END) Consumer_Products,	
	   sum(CASE WHEN event_name = 'page_view' and ti_td_page_content_type like 'Summaries' 
	             and ti_td_page_section = 'Industries' and  ti_td_page_subsection = 'Technology' THEN 1 ELSE 0 END) Technology,
	   sum(CASE WHEN event_name = 'page_view' and ti_td_page_content_type like 'Summaries' 
	             and ti_td_page_section = 'Industries' and  ti_td_page_subsection = 'Real Estate' THEN 1 ELSE 0 END) Real_Estate,
	   sum(CASE WHEN event_name = 'page_view' and ti_td_page_content_type like 'Summaries' 
	             and ti_td_page_section = 'Industries' and  ti_td_page_subsection = 'Health Care' THEN 1 ELSE 0 END) Health_Care,
	   sum(CASE WHEN event_name = 'page_view' and ti_td_page_content_type like 'Summaries' 
	             and ti_td_page_section = 'Industries' and  ti_td_page_subsection = 'Automobiles' THEN 1 ELSE 0 END) Automobiles,
	   sum(CASE WHEN event_name = 'page_view' and ti_td_page_content_type like 'Summaries' 
	             and ti_td_page_section = 'Industries' and  ti_td_page_subsection = 'Industrials and Aerospace' THEN 1 ELSE 0 END) Industrials_and_Aerospace,
	   sum(CASE WHEN event_name = 'page_view' and ti_td_page_content_type like 'Summaries' 
	             and ti_td_page_section = 'Industries' and  ti_td_page_subsection = 'Transportation' THEN 1 ELSE 0 END) Transportation,
	   sum(CASE WHEN event_name = 'page_view' and ti_td_page_content_type like 'Summaries' 
	             and ti_td_page_section = 'Industries' and  ti_td_page_subsection = 'Telecom and Media' THEN 1 ELSE 0 END) Telecom_and_Media,
	   sum(CASE WHEN event_name = 'page_view' and ti_td_page_content_type like 'Summaries' 
	             and ti_td_page_section = 'Industries' and  ti_td_page_subsection = 'Energy and Utilities' THEN 1 ELSE 0 END) Energy_and_Utilities,
	   sum(CASE WHEN event_name = 'page_view' and ti_td_page_content_type like 'Summaries' 
	             and ti_td_page_section = 'Industries' and  ti_td_page_subsection = 'Financial Services' THEN 1 ELSE 0 END) Financial_Services,  
	   sum(CASE WHEN event_name = 'page_view' and ti_td_page_content_type like 'Summaries' 
	             and ti_td_page_section = 'Industries' and  ti_td_page_subsection = 'Natural Resources' THEN 1 ELSE 0 END) Natural_Resources,          
	     
	   sum(CASE WHEN event_name = 'page_view' and ti_td_page_content_type like 'Summaries' 
	             and ti_td_page_section = 'Regions' and  ti_td_page_subsection = 'EMEA' THEN 1 ELSE 0 END) EMEA,
	   sum(CASE WHEN event_name = 'page_view' and ti_td_page_content_type like 'Summaries' 
	             and ti_td_page_section = 'Regions' and  ti_td_page_subsection = 'Latin America' THEN 1 ELSE 0 END) Latin_America,
	   sum(CASE WHEN event_name = 'page_view' and ti_td_page_content_type like 'Summaries' 
	             and ti_td_page_section = 'Regions' and  ti_td_page_subsection = 'Asia Pacific' THEN 1 ELSE 0 END) Asia_Pacific,  
	   sum(CASE WHEN event_name = 'page_view' and ti_td_page_content_type like 'Summaries' 
	             and ti_td_page_section = 'Regions' and  ti_td_page_subsection = 'North America' THEN 1 ELSE 0 END) North_America,
	   
	   sum(CASE WHEN event_name = 'page_view' and ti_td_page_content_type like 'Summaries' 
	             and ti_td_page_section = 'Topic Views' and  ti_td_page_subsection = 'Fx/Fixed Income' THEN 1 ELSE 0 END) Fx_Fixed_Income,
	   sum(CASE WHEN event_name = 'page_view' and ti_td_page_content_type like 'Summaries' 
	             and ti_td_page_section = 'Topic Views' and  ti_td_page_subsection = 'Energy' THEN 1 ELSE 0 END) Energy,  
	   sum(CASE WHEN event_name = 'page_view' and ti_td_page_content_type like 'Summaries' 
	             and ti_td_page_section = 'Topic Views' and  ti_td_page_subsection = 'Commodities' THEN 1 ELSE 0 END) Commodities     
	                       
	             
	             
FROM pib_event_data.pib_product_metrics ppm
LEFT JOIN dimension_external_db.pib_membership_dimension pmd ON pmd.pib_member_id = ppm.user_info_user_ref
LEFT JOIN dimension_external_db.pib_billing_account_dimension bad ON pmd.billing_account_id = bad.cibs_billing_account_id 
LEFT JOIN dimension_external_db.pib_company_dimension comp ON bad.salesforce_company_two = comp.company_sfdc_id
WHERE ppm.product = 'NewsPlus'
AND cycle_date >>= date('2022-02-01')
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12
ORDER BY page_views desc
