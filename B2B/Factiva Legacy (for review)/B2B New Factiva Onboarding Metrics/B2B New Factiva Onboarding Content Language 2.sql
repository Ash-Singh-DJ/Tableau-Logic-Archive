-- Dashboard   : "B2B New Factiva Onboarding Metrics"  [B2B / Factiva Legacy (for review)]
-- Data source : "B2B New Factiva Onboarding Content Language 2" = published source "B2B New Factiva Onboarding Metrics - Content Language 2"  [B2B / B2B Product / Factiva / Datasources / B2B New Factiva Onboarding Data Sources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with comps as


(WITH dataset AS ( 
    SELECT * FROM   
        (  select user_info_user_ref, date_time, event_id, split(ti_td_ad_content_language,', {')
     FROM pib_event_data.pib_product_metrics
WHERE product = 'New Factiva'
and cycle_date >>= cast('2021-11-01' as date)
and ti_td_action = 'save_content_language'
 ) AS t (EID, date_time, event_id, metrics_array))

select date_time, EID, event_id, metric          
FROM dataset 
cross join unnest(metrics_array) as t(metric)
),

other as 
(SELECT 
              
		djm.user_info_user_ref EID2,
		mem.user_id user_id,
		mem.plan_id plan_id,
        djm.user_info_account_id,
      
        comp.company_name,
        comp.company_industry,
        comp.company_country
        
FROM pib_event_data.pib_product_metrics djm
LEFT JOIN dimension_external_db.pib_billing_account_dimension bad on djm.user_info_account_id = bad.cibs_billing_account_id
LEFT JOIN dimension_external_db.pib_company_dimension comp on comp.company_sfdc_id = bad.salesforce_company_two
LEFT JOIN dimension_external_db.pib_membership_dimension mem ON mem.pib_member_id = djm.user_info_user_ref
WHERE product = 'New Factiva'

GROUP BY 1, 2, 3, 4, 5, 6, 7)

select comps.EID,comps.metric,other.user_id,other.plan_id,other.user_info_account_id,other.company_name,other.company_industry,other.company_country, comps.date_time from comps
left join other on comps.EID = other.EID2

union all 

(SELECT 
        
        
		djm.user_info_user_ref EID,
		null as metric,
	    mem.user_id user_id,
		mem.plan_id plan_id,
        djm.user_info_account_id,
		 comp.company_name,
        comp.company_industry,
        comp.company_country,
        MIN(djm.date_time) as date_time
        
FROM pib_event_data.pib_product_metrics djm
LEFT JOIN dimension_external_db.pib_billing_account_dimension bad on djm.user_info_account_id = bad.cibs_billing_account_id
LEFT JOIN dimension_external_db.pib_company_dimension comp on comp.company_sfdc_id = bad.salesforce_company_two
LEFT JOIN dimension_external_db.pib_membership_dimension mem ON mem.pib_member_id = djm.user_info_user_ref
WHERE product = 'New Factiva'
and djm.user_info_account_id <<>> '9ZZZ139100'
and (ti_td_page_name is not null or ti_td_action is not null)
group by 1,2,3,4,5,6,7,8)
