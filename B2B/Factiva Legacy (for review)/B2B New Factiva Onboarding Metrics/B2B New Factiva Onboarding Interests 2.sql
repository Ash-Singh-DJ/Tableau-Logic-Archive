-- Dashboard   : "B2B New Factiva Onboarding Metrics"  [B2B / Factiva Legacy (for review)]
-- Data source : "B2B New Factiva Onboarding Interests 2" = published source "B2B New Factiva Onboarding Metrics - Interests 2"  [B2B / B2B Product / Factiva / Datasources / B2B New Factiva Onboarding Data Sources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
            
              
            
            
            
With

x as

(with c as

(with first1 as  
(select cycle_date, date_time, user_info_user_ref EID, ti_td_action, ti_td_ad_user_interests, 
(length(ti_td_ad_user_interests) - length(replace(ti_td_ad_user_interests, 'Company}')))/8 as comp_count,
(length(ti_td_ad_user_interests) - length(replace(ti_td_ad_user_interests, 'Industry}')))/9 as ind_count,
(length(ti_td_ad_user_interests) - length(replace(ti_td_ad_user_interests, '{')))/1 as interest_count

     FROM pib_event_data.pib_product_metrics
WHERE product = 'New Factiva'
and ti_td_action in ('complete_onboarding', 'follow_interests', 'edit_interests', 'add_interests')
and ti_td_ad_user_interests is not null
--and user_info_user_ref = 'E6OO2HVCQHVPE5MUD7C6B53M5E'  
--and cycle_date >>= cast('2021-11-01' as date)
group by 1,2,3,4,5,6,7,8
order by date_time),

second2 as
(select date_time, cycle_date, EID, ti_td_action, comp_count,
lag(comp_count,1) over(PARTITION BY EID order by date_time) as comp_count_lag,
ind_count,
lag(ind_count,1) over(PARTITION BY EID order by date_time) as ind_count_lag,
interest_count,
lag(interest_count,1) over(PARTITION BY EID order by date_time) as interest_count_lag


from first1)

select date_time, cast(cycle_date as varchar) year_month_day, substring(cast(cycle_date as varchar),1,7) year_month,  EID, ti_td_action,comp_count, ind_count, interest_count, (comp_count - comp_count_lag) comp_diff, (ind_count - ind_count_lag) ind_diff,
(interest_count - interest_count_lag) interest_diff,
      (case when comp_count - comp_count_lag << 0 then 'comp_remove'
             when comp_count - comp_count_lag >> 0 then 'comp_add'
             when comp_count - comp_count_lag = 0 then 'comp_no_change' end) comp_status,
             
       (case when ind_count - ind_count_lag << 0 then 'ind_remove'
             when ind_count - ind_count_lag >> 0 then 'ind_add'
             when ind_count - ind_count_lag = 0 then 'ind_no_change' end) ind_status,
             
          (case when interest_count - interest_count_lag << 0 then 'interest_remove'
             when interest_count - interest_count_lag >> 0 then 'interest_add'
             when interest_count - interest_count_lag = 0 then 'interest_no_change' end) interest_status
                  
             from second2),
             
             
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

select * from c
left join other on c.EID = other.EID2)


select x.year_month_day, x.year_month, x.EID, x.ti_td_action, x.comp_count, x.ind_count, x.interest_count, x.comp_diff, x.ind_diff, x.interest_diff, 
x.comp_status, x.ind_status,  x.interest_status, x.user_id, x.plan_id, x.user_info_account_id, x.company_name, x.company_industry, x.company_country, 
x.date_time from x
--where EID = 'E6OO2HVCQHVPE5MUD7C6B53M5E'

union all 

(SELECT 
        

     null as year_month_day, 
     null as year_month,  
     EID,
     null as ti_td_action,
     null as comp_count,
     null as ind_count,
     null as interest_count,
     null as comp_diff,
     null as ind_diff,
     null as interest_diff,
     null as comp_status,
     null as ind_status,
     null as interest_status,
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
--and EID = 'E6OO2HVCQHVPE5MUD7C6B53M5E'
and (ti_td_page_name is not null or ti_td_action is not null)
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19)                              
