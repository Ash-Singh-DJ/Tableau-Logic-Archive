-- Dashboard   : "B2B Company-level Usage between Classic and New Factiva"  [B2B / Factiva Legacy (for review)]
-- Data source : "B2B Company-level Usage Preference" = published source "B2B Company-level Usage between Classic and New Factiva - Usage Preference"  [B2B / B2B Product / Factiva / Datasources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / abc_matrix), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select substring(cast(cycle_date as varchar),1,7) as year_month, mem.plan_id, mem.user_status,
user_info_user_ref as EID, bad.cibs_billing_account_id as bill_account, comp.company_name,
bad.sales_person, ter.territory_roll_up, us1.user_full_name as rsd,
count(distinct case when product = 'Factiva' and (event_name = 'page_view' or event_name = 'user_action') then visit_id end) as  f_visits,
count(distinct case when product = 'New Factiva' and (event_name = 'page_view' or event_name = 'user_action') then visit_id end) as nf_visits


from pib_event_data.pib_product_metrics djm
LEFT JOIN dimension_external_db.pib_billing_account_dimension bad on djm.user_info_account_id = bad.cibs_billing_account_id
LEFT JOIN dimension_external_db.pib_company_dimension comp on comp.company_sfdc_id = bad.salesforce_company_two
LEFT JOIN dimension_external_db.pib_membership_dimension mem ON mem.pib_member_id = djm.user_info_user_ref
left join dimension_external_db.pib_territory_dimension ter on bad.account_sales_territory = ter.territory_name
left join dimension_external_db.pib_user_dimension us1 on ter.regional_sales_director = us1.user_sfdc_id
where product in ('Factiva', 'New Factiva')
and cycle_date >>= cast('2023-01-01' as date)

group by 1,2,3,4,5,6,7,8,9
having 
count(distinct case when product = 'Factiva' and (event_name = 'page_view' or event_name = 'user_action') then visit_id end) >> 0 
or count(distinct case when product = 'New Factiva' and (event_name = 'page_view' or event_name = 'user_action') then visit_id end) >> 0
