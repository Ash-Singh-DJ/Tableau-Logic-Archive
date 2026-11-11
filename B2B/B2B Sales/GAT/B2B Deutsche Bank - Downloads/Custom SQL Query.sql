-- Published data source : "B2B Deutsche Bank - Downloads"  [B2B / B2B Sales / GAT]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with 

Salesperson_Dim as (select
user_sfdc_id,
user_full_name
from dimension_external_db.pib_user_dimension
where status_flag <<>> 'DELETE'
group by
user_sfdc_id,
user_full_name),

Territory_Dim as( select
territory_sfdc_id,
territory_name,
territory_roll_up,
regional_sales_director,
territory_owner
from dimension_external_db.pib_territory_dimension
where territory_status = 'Active'
and status_flag <<>> 'DELETE'
group by 
territory_sfdc_id,
territory_name,
territory_roll_up,
regional_sales_director,
territory_owner),


Territory_Dim2 as( select
territory_sfdc_id,
territory_name,
territory_roll_up,
regional_sales_director, 
territory_owner
from dimension_external_db.pib_territory_dimension
where territory_status = 'Active'
and status_flag <<>> 'DELETE'
group by 
territory_sfdc_id,
territory_name,
territory_roll_up,
regional_sales_director,
territory_owner)


select substring(cast(djm.cycle_date as varchar),1,7) year_month, user_info_user_ref as EID, mem.user_id, mem.first_name, mem.last_name, mem.email,
 user_info_account_id, comp.company_name, 
		bill.account_sales_territory,		
	replace(bill.salesforce_territory_owner, '  ', ' ') as account_owner,
	
		Salesperson_Dim.user_full_name as salesperson ,
		 Territory_Dim.territory_name,
         Territory_Dim.territory_roll_up,      
         Territory_Dim2.territory_name as account_territory_name,
         Territory_Dim2.territory_roll_up as account_territory_roll_up,
         us1.user_full_name as rsd,
               
ti_td_action, ti_td_ad_format_type, ti_td_ad_content_format,
count(ti_td_ad_content_format) instances,
sum(case when coalesce(ti_td_ad_article_count ,1)  <<= 100 then coalesce(ti_td_ad_article_count ,1) else 0 end) article_count
from pib_event_data.pib_product_metrics djm
INNER JOIN dimension_external_db.pib_membership_dimension mem ON djm.user_info_user_ref = mem.pib_member_id
left join dimension_external_db.pib_billing_account_dimension bill on mem.billing_account_id = bill.cibs_billing_account_id
left join dimension_external_db.pib_company_dimension comp on bill.salesforce_company_two = comp.company_sfdc_id 
left join Territory_Dim on Comp.company_territory = Territory_Dim.territory_sfdc_id
left join Territory_Dim2 on bill.account_sales_territory = Territory_Dim2.territory_name
left join Salesperson_Dim on Territory_Dim.territory_owner = Salesperson_Dim.user_sfdc_id
left join dimension_external_db.pib_user_dimension us1 on Territory_Dim.regional_sales_director = us1.user_sfdc_id

where product = 'Factiva'
and (ti_td_action like '%download%' or ti_td_action like '%print%')
and cycle_date >>= cast('2023-01-01' as date)
and ti_td_ad_content_format <<>> 'SearchSummaryOnly'
and djm.user_info_account_id in ('9DEU001700','9DEU005300','9DEU004800','9DEU001500','9DEU008900',
'9DEU004000','9DEU006000','9DEU011300','9DEU005600','9DEU003200','9DEU019300','9DEU017100','9DEU004600')
and ((plan_id <<>> '0086' AND plan_id <<>> '0087') AND account_sales_territory <<>> 'Proquest')
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19
