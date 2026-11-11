-- Published data source : "B2B New Factiva Onboarding Metrics - Searches"  [B2B / B2B Product / Factiva / Datasources / B2B New Factiva Onboarding Data Sources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
SELECT substring(cast(djm.cycle_date as varchar),1,7) year_month,
		djm.user_info_user_ref EID,
		mem.user_id user_id,
		mem.plan_id plan_id,
                SUBSTR(djm.ti_bd_user_agent, STRPOS(djm.ti_bd_user_agent, '(')+1, (STRPOS(djm.ti_bd_user_agent, ';')-1) - STRPOS(djm.ti_bd_user_agent, '(')) operating_system,
        djm.user_info_account_id,
        comp.company_name,
    
        ti_td_ad_order_by,
        ti_td_page_subsection,
        ti_td_page_sub_subsection,
      
    
        ti_td_search_keywords_name,
        ti_td_search_record_type,
        
        count(distinct djm.user_info_user_ref) distinct_users,
  
        
        sum(CASE WHEN djm.event_name = 'page_view' THEN 1 ELSE 0 END) page_view

        
FROM pib_event_data.pib_product_metrics djm
LEFT JOIN dimension_external_db.pib_billing_account_dimension bad on djm.user_info_account_id = bad.cibs_billing_account_id
LEFT JOIN dimension_external_db.pib_company_dimension comp on comp.company_sfdc_id = bad.salesforce_company_two
LEFT JOIN dimension_external_db.pib_membership_dimension mem ON mem.pib_member_id = djm.user_info_user_ref
WHERE product = 'New Factiva'
and djm.event_name = 'page_view'
and ti_td_search_keywords_name is not null
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12
