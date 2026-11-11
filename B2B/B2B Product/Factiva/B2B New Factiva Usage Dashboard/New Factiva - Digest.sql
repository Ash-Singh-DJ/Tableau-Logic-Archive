-- Dashboard   : "B2B New Factiva Usage Dashboard"  [B2B / B2B Product / Factiva]
-- Data source : "New Factiva" (embedded in the workbook)
-- Relation    : Custom SQL "Digest"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with dig as (
SELECT        
             date_time,
             user_info_user_ref EID,
             event_name,
             ti_td_action as d_action,
             (case when ti_td_action = 'complete_onboarding' and ti_td_ad_digest_email_enabled = true then 'Enabled at Onboarding' 
             when (ti_td_action = 'personalized_news_email_enable' and ti_td_page_section  = 'Home Page') then 'Enabled from Icon'
             when (ti_td_action = 'personalized_news_email_disable' and ti_td_page_section  = 'Home Page') then 'Disabled from Icon'
             when ((ti_td_action = 'personalized_news_email_enable' and ti_td_page_url not like '%onboarding%' and ti_td_page_section = 'Settings') 
             or ti_td_action = 'personalized_news_change_email_frequency') then 'Enabled at Settings'
             
             when (ti_td_action = 'personalized_news_email_disable' and ti_td_page_url not like '%onboarding%' and ti_td_page_section = 'Settings') then 'Disabled at Settings'
             when ti_td_action is null then 'Not Engaged' end) as dig_status, 
             ti_td_ad_email_frequency as d_freq
           
FROM pib_event_data.pib_product_metrics djm
WHERE product = 'New Factiva'
and (ti_td_action like 'personalized_news_email%' or ti_td_action like '%news_change_email_frequency' or ti_td_action = 'complete_onboarding' )
and event_name = 'user_action'
and user_info_account_id <<>> '9ZZZ139100'
--and user_info_user_ref = 'E6OO2HVCQHVPFICLUBMGV2NQG4'
GROUP BY 1,2,3,4,5,6
order by date_time)

select dig.EID, mem.user_id, d_action as digest_action, d_freq as digest_freq, dig_status from dig
left join dimension_external_db.pib_membership_dimension mem on mem.pib_member_id = dig.EID
where date_time = (select max(date_time) from dig dig2 where dig.EID = dig2.EID)
