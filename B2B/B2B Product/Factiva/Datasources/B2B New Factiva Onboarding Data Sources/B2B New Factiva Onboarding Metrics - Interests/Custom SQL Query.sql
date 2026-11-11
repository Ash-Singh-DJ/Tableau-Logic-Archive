-- Published data source : "B2B New Factiva Onboarding Metrics - Interests"  [B2B / B2B Product / Factiva / Datasources / B2B New Factiva Onboarding Data Sources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with comps as


(WITH dataset AS ( 
    SELECT * FROM   
        (  select user_info_user_ref, date_time, substring(cast(cycle_date as varchar),1,10) year_month_day, ti_td_action, event_id, split(ti_td_ad_user_interests,', {')
     FROM pib_event_data.pib_product_metrics
WHERE product = 'New Factiva'
and cycle_date >>= cast('2021-11-01' as date)
and ti_td_ad_user_interests is not null 
 ) AS t (EID, date_time, year_month_day, ti_td_action, event_id, metrics_array))

select date_time, year_month_day, EID, ti_td_action, event_id, metric, substring(metric, strpos(metric, ',')+2, (strpos(metric, '}')) - (strpos(metric, ',')+2) ) onboarding_company
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

select * from comps
left join other on comps.EID = other.EID2
