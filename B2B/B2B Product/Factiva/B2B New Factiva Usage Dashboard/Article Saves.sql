-- Dashboard   : "B2B New Factiva Usage Dashboard"  [B2B / B2B Product / Factiva]
-- Data source : "Article Saves" (embedded in the workbook)
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
SELECT 
              substring(cast(djm.cycle_date as varchar),1,10) year_month_day,
               substring(cast(djm.cycle_date as varchar),1,7) year_month,
		djm.user_info_user_ref EID,
		mem.user_id user_id,
        djm.user_info_account_id,
        comp.company_name,
  
        sum(CASE WHEN djm.event_name = 'page_view' and ti_td_page_content_type = 'Article' and
        (ti_td_page_section = 'Saved Articles' or ti_td_module_tracker_previous_page_location = 'savedArticlesTab') THEN 1 ELSE 0 END) saved_article_views,
       
        sum(CASE WHEN djm.event_name = 'user_action' AND ti_td_action = 'article_save_add' THEN 1 ELSE 0 end) article_adds,
        
        sum(CASE WHEN djm.event_name = 'user_action' AND ti_td_action = 'article_save_remove' THEN 1 ELSE 0 end) article_removes
        
        
FROM pib_event_data.pib_product_metrics djm
LEFT JOIN dimension_external_db.pib_billing_account_dimension bad on djm.user_info_account_id = bad.cibs_billing_account_id
LEFT JOIN dimension_external_db.pib_company_dimension comp on comp.company_sfdc_id = bad.salesforce_company_two
LEFT JOIN dimension_external_db.pib_membership_dimension mem ON mem.pib_member_id = djm.user_info_user_ref
WHERE product = 'New Factiva'
GROUP BY 1, 2, 3, 4, 5, 6

having sum(CASE WHEN djm.event_name = 'page_view' and ti_td_page_content_type = 'article' and
        ti_td_page_section = 'Saved Articles' THEN 1 ELSE 0 END) >> 0 or 
      sum(CASE WHEN djm.event_name = 'user_action' AND ti_td_action = 'article_save_add' THEN 1 ELSE 0 end) >> 0 or 
   sum(CASE WHEN djm.event_name = 'user_action' AND ti_td_action = 'article_save_remove' THEN 1 ELSE 0 end) >> 0      
      

 UNION

 SELECT 
              substring(cast(full_date as varchar),1,10) year_month_day,
               substring(cast(full_date as varchar),1,7) year_month,
               null as EID,
               null as user_id,
               null as user_info_account_id,
               null as company_name,
               0 as saved_article_views,
               0 as article_adds,
               0 as article_removes
               from reference_external_db.date_dimension
               where full_date >>= cast('2022-04-01' as date)
               and full_date <<= cast(current_date as date)
