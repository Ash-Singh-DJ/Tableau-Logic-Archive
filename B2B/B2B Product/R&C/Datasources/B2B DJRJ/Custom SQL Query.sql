-- Published data source : "B2B DJRJ"  [B2B / B2B Product / R&C / Datasources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / abc_matrix), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
WITH DJRJ AS ( 
select cycle_date, date_time,
SUBSTRING(CAST(cycle_date AS varchar), 1, 7) year_month, 
CONCAT(CAST((year(cycle_date)) as varchar), '-', CAST((week(cycle_date)) as varchar)) as year_cal_week,
browser,
post_evar3,
post_prop3 as contributor,
post_prop4 as headline,
post_prop8 as publication,
post_prop18 as search_statements,
evar134 as search_results,
CAST(post_visid_high AS varchar) || '-' || CAST(post_visid_low AS varchar) || '-' || CAST(visit_num AS varchar) || '-' || CAST(visit_start_time_gmt AS varchar) AS visit_id,
--(CAST(post_visid_high as varchar) || '-' || CAST(post_visid_low as varchar) || '-' || CAST(visit_num as varchar)) as visit_id,
CASE 
        WHEN (campaign = 'DJRJ_panda_risk-journal_news_subject_code_alert') THEN 'Email Alert'
        WHEN (campaign = 'DJRJ_djrj_top_news') THEN 'Top News'
        WHEN (campaign in ('DJRJ_djrj_deloitte_trending','DJRJ_djrj_deloitte_sponsor')) THEN 'Articles From Our Sponsor'
        WHEN (campaign = 'DJRJ_djrj_personalized_news') THEN 'Personalized News'
        WHEN (campaign = 'DJRJ_djrj_contributors') THEN 'Contributors'
        
        WHEN (lower(post_evar107) like '%newsletter%' and post_page_event_var2 = 'DJRJ_Home_read_latest') THEN 'Newsletters Preview'
		WHEN (lower(post_evar107) like '%newsletter%' and post_page_event_var2 = 'DJRJ_Home_follow_add') THEN 'Newsletters Subscribed'
        WHEN (lower(post_evar107) like '%newsletter%' and post_page_event_var2 = 'DJRJ_Home_follow_remove') THEN 'Newsletters Unsubscribed'
        
        WHEN (post_evar107 = 'DJRJ_djrj_top_news_view_all' and post_page_event_var2 = 'DJRJ_Home_click') THEN 'View All Top News'
        WHEN (post_evar107 = 'DJRJ_djrj_contributors_view_all' and post_page_event_var2 = 'DJRJ_Home_click') THEN 'View All Contributors'

        WHEN (post_page_event_var2 = 'DJRJ_Home_follow_add' and post_evar184 ='Topics') THEN 'Add Topics'
        WHEN (post_page_event_var2 = 'DJRJ_Home_follow_remove' and post_evar184 ='Topics') THEN 'Remove Topics'
        WHEN (post_page_event_var2 = 'DJRJ_Home_follow_add' and post_evar184 ='Alert') THEN 'Add Alert'
        WHEN (post_page_event_var2 = 'DJRJ_Home_follow_remove' and post_evar184 ='Alert') THEN 'Remove Alert'
        
        WHEN post_page_event_var2 = 'DJRJ_Home_view_data' THEN 'Corruption Perceptions Index'
        WHEN post_page_event_var2 = 'DJRJ_Home_event_register' THEN 'Community - Event Register Clicked'
        WHEN (post_evar25 = 'DJRJ_Upcoming Risk Events') THEN 'Community - Upcoming Risk Events'
        WHEN post_evar25 = 'DJRJ_Past Risk Events' THEN 'Community - Past Risk Events'
        WHEN lower(post_evar25) LIKE '%search%' THEN 'Search Risk News'
        --WHEN (campaign = 'DJRJ_djrj_community' or post_evar25 = 'DJRJ_Event Details') THEN 'Community - Event Details'
  END AS Sub_Modules,
CASE 
    WHEN campaign = 'DJRJ_djrj_search' 
         AND evar89 LIKE '%position%' 
    THEN CAST(regexp_replace(evar89, '[^0-9]', '') AS INTEGER)
    ELSE NULL
  END AS position_number,
--campaign as campaign,
post_prop1 as content_type,
post_evar54 as News_Sections,
post_page_event_var2 as event_name,
--post_pagename,
(case when mobile_id = 0 THEN 'Desktop' ELSE 'Mobile' end) as device,

SUM(CASE WHEN reporting_suite = 'djb2briskjournal' AND (cast(post_page_event as varchar) = '0' 
          AND (CAST(exclude_hit AS INTEGER) <<= 0 AND cast(hit_source as varchar) NOT IN ('5',  '8',  '9'))  
          AND lower(post_pagename) not like '%login%' and post_prop20 not in ('rjd-search-view')
          AND campaign not in ('DJRJ_djrj_back_dashboard')) 
          or post_page_event_var2 IN ('DJRJ_Home_view_data', 'DJRJ_Home_read_latest')     
          or post_evar25 in ('DJRJ_Past Risk Events','DJRJ_Upcoming Risk Events')
          THEN 1 ELSE 0 END) desktop_page_views

 ,SUM (
  CASE WHEN reporting_suite = 'djb2briskjournal' AND post_page_event_var2 IN ('DJRJ_Home_follow_add', 'DJRJ_Home_follow_remove','DJRJ_Home_click')
  THEN 1 ELSE 0 END) AS Actions
  
--,COUNT (distinct (CASE WHEN reporting_suite = 'djb2briskjournal' AND CAST(exclude_hit AS INTEGER) <<= 0 
--        AND cast(hit_source as varchar) NOT IN ('5',  '7',  '8',  '9') AND lower(post_pagename) not like '%login%' 
--       THEN (CAST(post_visid_high as varchar) || '-' || CAST(post_visid_low as varchar) || '-' || CAST(visit_num as varchar))  || '-' || CAST(visit_start_time_gmt AS varchar) END)) desktop_visits
--	   --THEN (CAST(post_visid_high as varchar) || '-' || CAST(post_visid_low as varchar) || '-' || CAST(visit_num as varchar)) END) desktop_visits

,COUNT(CASE WHEN reporting_suite = 'djb2briskjournal' AND (lower(post_pagename) LIKE '%article%')
	AND cast(post_page_event as varchar) = '0' AND (CAST(exclude_hit AS integer) <<= 0 AND cast(hit_source as varchar) NOT IN ('5', '8','9')) 
        THEN post_prop20 ELSE NULL END) article_views
        
,COUNT(CASE WHEN reporting_suite = 'djb2briskjournal' AND (lower(post_evar25) LIKE '%search%') and post_prop20 not in ('rjd-search-view')
	AND cast(post_page_event as varchar) = '0' AND (CAST(exclude_hit AS integer) <<= 0 AND cast(hit_source as varchar) NOT IN ('5', '8','9')) 
        THEN post_prop20 ELSE NULL END) Search_views       
        
FROM fact_external_db.omniture_event_fact_hourly
WHERE reporting_suite in ('djb2briskjournal')
and cycle_date >>= date('2025-03-31')
and post_evar3 not in ('E6OO2HVCQHVPE36GA45VEIW3PA','D3WZYJYBD4BQAC2TAVG2OMAAAA')
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18
order by date_time),

------ Data from DJGlobal ------

WSJ_ini as (select cycle_date, date_time,
SUBSTRING(CAST(cycle_date AS varchar), 1, 7) year_month, 
CONCAT(CAST((year(cycle_date)) as varchar), '-', CAST((week(cycle_date)) as varchar)) as year_cal_week,
browser,
post_evar3,
post_prop3 as contributor,
post_prop4 as headline,
post_prop8 as publication,
post_prop18 as search_statements,
evar134 as search_results,
CAST(post_visid_high AS varchar) || '-' || CAST(post_visid_low AS varchar) || '-' || CAST(visit_num AS varchar) || '-' || CAST(visit_start_time_gmt AS varchar) AS visit_id,
--campaign,
--post_evar25,
CASE 
        WHEN (post_evar95 = '?mod=djrj_community|') THEN 'Community - Event Register Clicked'
        WHEN (post_evar95 = '?mod=djrj_more_content_from_deloitte|') THEN 'More Content from Deloitte'
END AS Sub_Modules,
null as position_number,
post_prop1 as content_type,
post_evar54 as News_Sections,
post_evar116 as event_name,
--post_pagename,
(case when mobile_id = 0 THEN 'Desktop' ELSE 'Mobile' end) as device,

SUM(CASE WHEN reporting_suite = 'djglobal' AND cast(post_page_event as varchar) = '0' 
          AND (CAST(exclude_hit AS INTEGER) <<= 0 AND cast(hit_source as varchar) NOT IN ('5',  '8',  '9'))  
          AND lower(post_pagename) not like '%login%' THEN 1
        ELSE 0 END) desktop_page_views
        
, 0 as Actions
--,COUNT (distinct CASE WHEN reporting_suite = 'djglobal' AND CAST(exclude_hit AS INTEGER) <<= 0 
--        AND cast(hit_source as varchar) NOT IN ('5',  '7',  '8',  '9') AND lower(post_pagename) not like '%login%' 
--       THEN (CAST(post_visid_high as varchar) || '-' || CAST(post_visid_low as varchar) || '-' || CAST(visit_num as varchar))  || '-' || CAST(visit_start_time_gmt AS varchar) END) desktop_visits
       
,COUNT(CASE WHEN reporting_suite = 'djglobal' and (lower(post_prop1) like '%article%' or lower(post_prop1) like '%blog%') 
        THEN post_prop1 ELSE NULL END) article_views
        
, 0 as Search_views
FROM fact_external_db.omniture_event_fact_hourly 
WHERE cycle_date >>= date('2025-03-31')
and reporting_suite ='djglobal'
and post_evar95 in ('?mod=djrj_community|','?mod=djrj_more_content_from_deloitte|')
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18
order by date_time
),

VXID as (
  SELECT encrypted_uuid_v1 as VXID, uuid
  FROM subscription_external_db.identity_lookup
  WHERE encrypted_uuid_v1 IS NOT NULL
  UNION
  SELECT encrypted_uuid_v2 as VXID, uuid
  FROM subscription_external_db.identity_lookup
  WHERE encrypted_uuid_v2 IS NOT NULL),
  
pib_mem AS (
  SELECT pib_member_id, uu_id
  FROM dimension_external_db.pib_membership_dimension
  --where user_status = 'A'
   GROUP BY 1,2),

mem_id as(
SELECT 
       pib_mem.pib_member_id,
       VXID.uuid,
       VXID.VXID
FROM  pib_mem
LEFT JOIN VXID ON pib_mem.uu_id = VXID.uuid 
where VXID.VXID is not null
GROUP BY 1, 2, 3
),

WSJ AS(
select W.cycle_date, W.date_time, W.year_month, W.year_cal_week, W.browser,
mem_id.pib_member_id, W.contributor, W.headline, W.publication,
W.search_statements, W.search_results, W.visit_id,
W.Sub_Modules, W.position_number, W.content_type, W.News_Sections, W.event_name, W.device, 
sum(W.desktop_page_views) as desktop_page_views,
sum(W.Actions) as Actions,
--sum(W.desktop_visits) as desktop_visits,
sum(W.article_views) as article_views,
sum(W.Search_views) as Search_views
from WSJ_ini as W
LEFT JOIN mem_id ON W.post_evar3 = mem_id.VXID 
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18
order by W.date_time
),

Omnit_Ini as (
select * from DJRJ
union all
select * from WSJ
order by date_time, post_evar3
),

Omnit_Order AS (
    SELECT *,
        -- Added visit_id to PARTITION BY to prevent looking across sessions
        LEAD(content_type) OVER (
            PARTITION BY post_evar3, visit_id 
            ORDER BY date_time
        ) AS next_event
    FROM Omnit_Ini
),


News_After_Search as (
SELECT *,
    CASE 
        WHEN LOWER(content_type) LIKE '%search%' 
         AND LOWER(next_event) LIKE '%article%' THEN 1
        ELSE 0
    END AS news_after_search
FROM Omnit_Order
ORDER BY post_evar3, date_time
),

Omnit as (
select * from News_After_Search
),

St1 AS (
	SELECT post_evar3, MIN(date_time) user_start_date
	FROM Omnit 
	GROUP BY 1),

cco AS (
    SELECT 
        email AS cco_email, 
        CASE 
            WHEN LOWER(contact_type_class) IN ('cco council comp member','cco council asia comp member') THEN 'CCO Council - Comped' 
            WHEN LOWER(contact_type_class) IN ('cco council asia member','cco council member') THEN 'CCO Council - Paid' 
        END AS Product 
    FROM csuite_external_db.cvent_contact 
    WHERE LOWER(contact_type_class) IN ('cco council comp member', 'cco council asia comp member', 'cco council asia member', 'cco council member') 
      AND Active = true 
      AND company NOT IN ('Dow Jones','News Corp') 
    GROUP BY 1,2 
), 
mem_dim AS ( 
    SELECT 
        m.pib_member_id, 
        m.user_id, 
        m.billing_account_id, 
        m.plan_id, 
        m.email, 
        m.first_name, 
        m.last_name, 
        m.user_status, 
        COALESCE(c.Product, 'Non-CCO Council') AS CCO_Class 
    FROM dimension_external_db.pib_membership_dimension m 
    LEFT JOIN cco AS c ON m.email = c.cco_email 
    GROUP BY 1,2,3,4,5,6,7,8,9
), 
   
comp as (
SELECT ba.cibs_billing_account_id, 
        --ba.salesforce_billing_account_id,
        ba.country,
        ba.industry,
        ba.account_sales_region,
        comp.company_name, 
        corp.corporate_name,
        terr.territory_roll_up,
        usr.user_full_name as rsd,
        usr2.user_full_name AS salesperson
FROM dimension_external_db.pib_billing_account_dimension ba 
--ON ba.salesforce_billing_account_id = cib.cibs_billing_account 
LEFT JOIN dimension_external_db.pib_company_dimension comp on ba.salesforce_company_two = comp.company_sfdc_id
LEFT JOIN dimension_external_db.pib_corporate_dimension corp ON comp.parent_sfdc_id = corp.corporate_sfdc_id 
LEFT JOIN dimension_external_db.pib_territory_dimension terr ON comp.company_territory = terr.territory_sfdc_id 
LEFT JOIN dimension_external_db.pib_user_dimension usr ON usr.user_sfdc_id = terr.regional_sales_director 
LEFT JOIN dimension_external_db.pib_user_dimension usr2 ON usr2.user_sfdc_id = terr.territory_owner      
group by 1,2,3,4,5,6,7,8,9
),

main_dim as (select mem_dim.*, comp.*
from mem_dim
left join comp on mem_dim.billing_account_id = comp.cibs_billing_account_id)


select Omnit.*, St1.user_start_date, main_dim.*
FROM Omnit
LEFT JOIN St1 ON St1.post_evar3 = Omnit.post_evar3
LEFT JOIN main_dim ON main_dim.pib_member_id = Omnit.post_evar3
where Omnit.post_evar3 not in ('E6OO2HVCQHVPE36GA45VEIW3PA','D3WZYJYBD4BQAC2TAVG2OMAAAA')
and Omnit.cycle_date >>= date('2025-03-31')
order by Omnit.date_time
