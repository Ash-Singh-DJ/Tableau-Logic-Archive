-- Published data source : "B2B Academic Toggle Usage - Aca Default"  [B2B / B2B Product / Factiva / Datasources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with lena as (
select year_month, date_time, EID, ip_agent,  bill_account, company_name, product from 
(select substring(cast(date_time as varchar),1,7) as year_month, date_time, user_info_user_ref as EID,  CONCAT(ti_bd_user_agent, ti_bd_client_ip_address) as ip_agent, bad.cibs_billing_account_id as bill_account, ti_td_page_url, comp.company_name, ti_td_action, product, user_info_session_id, 

ROW_NUMBER() OVER (PARTITION BY user_info_session_id, CONCAT(ti_bd_user_agent, ti_bd_client_ip_address) ORDER BY date_time) as Page_View_Num


from pib_event_data.pib_product_metrics djm
LEFT JOIN dimension_external_db.pib_billing_account_dimension bad on djm.user_info_account_id = bad.cibs_billing_account_id
LEFT JOIN dimension_external_db.pib_company_dimension comp on comp.company_sfdc_id = bad.salesforce_company_two
LEFT JOIN dimension_external_db.pib_membership_dimension mem ON mem.pib_member_id = djm.user_info_user_ref
where product in ('Factiva', 'New Factiva')
--and cibs_billing_account_id = '9NAT002200'

and plan_id in ('0086','0087')
and date_time >>= cast('2024-07-01' as date)
order by EID, date_time)
where Page_View_Num = 1)



select year_month, date_time, EID, ip_agent, bill_account, company_name, product from lena
where date_time = (select max(date_time) from lena lenb where (lena.ip_agent = lenb.ip_agent) and (lena.year_month = lenb.year_month) )
