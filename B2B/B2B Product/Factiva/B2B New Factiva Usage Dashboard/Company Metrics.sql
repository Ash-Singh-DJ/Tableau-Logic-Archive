-- Dashboard   : "B2B New Factiva Usage Dashboard"  [B2B / B2B Product / Factiva]
-- Data source : "Company Metrics" (embedded in the workbook)
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
        ti_td_page_content_platform_presentation,
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
         event_name,
        sum(case when djm.event_name = 'page_view' THEN 1 ELSE 0 END) page_views,
        sum(case when djm.event_name = 'user_action' THEN 1 ELSE 0 END) user_actions

        
FROM pib_event_data.pib_product_metrics djm
LEFT JOIN dimension_external_db.pib_billing_account_dimension bad on djm.user_info_account_id = bad.cibs_billing_account_id
LEFT JOIN dimension_external_db.pib_company_dimension comp on comp.company_sfdc_id = bad.salesforce_company_two
LEFT JOIN dimension_external_db.pib_membership_dimension mem ON mem.pib_member_id = djm.user_info_user_ref
WHERE product = 'New Factiva'
and cycle_date >>= cast('2022-11-01' as date)
and (ti_td_page_section = 'Company' or ti_td_search_record_type = 'company')
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9 ,10, 11,12,13,14,15,16,17,18,19,20,21,22
