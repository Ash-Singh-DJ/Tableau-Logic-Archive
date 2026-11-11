-- Dashboard   : "B2B New Factiva Usage Dashboard"  [B2B / B2B Product / Factiva]
-- Data source : "Digest Subs" (embedded in the workbook)
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with wk as
(select substring(cast(full_date as varchar),1,10) year_month_day, substring(cast(week_start_date as varchar),1,10) week_start from reference_external_db.date_dimension
where substring(cast(full_date as varchar),1,10) >>= cast('2021-01-01' as varchar)
order by full_date)




SELECT
               substring(cast(djm.cycle_date as varchar),1,10) year_month_day,
               substring(cast(djm.cycle_date as varchar),1,7) year_month,
                wk.week_start,
		djm.user_info_user_ref EID,
		mem.user_id user_id,
		mem.plan_id plan_id,
        djm.user_info_account_id,
        comp.company_name,
        ti_td_action,
        ti_td_page_section,
        ti_td_page_url,
        (case when ti_td_action = 'complete_onboarding' then 'Onboarding'
        when (ti_td_action = 'personalized_news_email_enable' and ti_td_page_url not like '%onboarding%' and ti_td_page_section = 'Settings') then 'Settings'
        when (ti_td_action = 'personalized_news_email_enable' and ti_td_page_section  = 'Home Page') then 'Icon' 
        when (ti_td_action = 'personalized_news_email_enable' and ti_td_page_section  = 'Onboarding') then 'Onboarding' 
        when (ti_td_action = 'personalized_news_email_disable' and ti_td_page_section  = 'Home Page') then 'Icon Disable'
         when (ti_td_action = 'personalized_news_email_disable' and ti_td_page_url not like '%onboarding%' and ti_td_page_section = 'Settings') then 'Settings Disable' else 'Other'
        end) as type,
        SUM(CASE WHEN djm.event_name = 'user_action' AND ((ti_td_action = 'personalized_news_email_enable' and ti_td_page_url not like '%onboarding%')  or 
           (ti_td_action = 'complete_onboarding' and ti_td_ad_digest_email_enabled = true)) THEN 1 
         when (ti_td_action = 'personalized_news_email_disable' and ti_td_page_url not like '%onboarding%') then -1 ELSE 0 END) digest_email_enable_total
      

        
FROM pib_event_data.pib_product_metrics djm
LEFT JOIN dimension_external_db.pib_billing_account_dimension bad on djm.user_info_account_id = bad.cibs_billing_account_id
LEFT JOIN dimension_external_db.pib_company_dimension comp on comp.company_sfdc_id = bad.salesforce_company_two
LEFT JOIN dimension_external_db.pib_membership_dimension mem ON mem.pib_member_id = djm.user_info_user_ref
LEFT JOIN wk on substring(cast(djm.cycle_date as varchar),1,10) = wk.year_month_day

WHERE product = 'New Factiva'
and cycle_date >>= cast('2023-01-01' as date)
--and user_info_user_ref = 'E6OO2HVCQHVPFNM4SWFPU4AY7U'
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12
having  SUM(CASE WHEN djm.event_name = 'user_action' AND ((ti_td_action = 'personalized_news_email_enable' and ti_td_page_url not like '%onboarding%')  or 
         (ti_td_action = 'personalized_news_email_disable' and ti_td_page_url not like '%onboarding%')  or (ti_td_action = 'complete_onboarding' and ti_td_ad_digest_email_enabled = true)) THEN 1 ELSE 0 END) >> 0
