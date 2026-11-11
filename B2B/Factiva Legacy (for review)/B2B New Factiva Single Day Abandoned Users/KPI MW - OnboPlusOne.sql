-- Dashboard   : "B2B New Factiva Single Day Abandoned Users"  [B2B / Factiva Legacy (for review)]
-- Data source : "KPI MW" (embedded in the workbook)
-- Relation    : Custom SQL "OnboPlusOne"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with onbo as

(select mem.pib_member_id as EID, substring(cast(cycle_date as varchar),1,7) as onbo_year_month

from pib_event_data.pib_product_metrics djm
inner join dimension_external_db.pib_membership_dimension mem on djm.user_info_user_ref = mem.pib_member_id
where product = 'New Factiva'
and ti_td_action = 'complete_onboarding' 

AND cycle_date >>= cast('2023-01-01' as date)

)

select substring(cast(cycle_date as varchar),1,7) as year_month,  mem.pib_member_id, mem.user_id, onbo.onbo_year_month, mem.billing_account_id, comp.company_name, comp.company_industry, 

count(distinct case when product = 'New Factiva' and (event_name = 'page_view' or event_name = 'user_action') then cycle_date end) nf_active_days,

count(distinct case when product = 'New Factiva' and (event_name = 'page_view' or event_name = 'user_action') and (ti_td_page_content_type_detail = 'search results' or ti_td_article_id is not null)  then cycle_date end) nf_engaged_active_days


from pib_event_data.pib_product_metrics djm
inner join dimension_external_db.pib_membership_dimension mem on djm.user_info_user_ref = mem.pib_member_id
left join onbo on mem.pib_member_id = onbo.EID
left join dimension_external_db.pib_billing_account_dimension bill on mem.billing_account_id = bill.cibs_billing_account_id 
left join dimension_external_db.pib_company_dimension comp on bill.salesforce_company_two = comp.company_sfdc_id
where product = 'New Factiva'
AND cycle_date >>= cast('2023-01-01' as date)
--and mem.user_id = 'X002636961'
group by 1,2,3,4,5,6,7
having count(distinct case when product = 'New Factiva' and (event_name = 'page_view' or event_name = 'user_action') then cycle_date end) >> 0
