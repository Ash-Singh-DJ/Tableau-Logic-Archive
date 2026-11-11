-- Published data source : "B2B Deutsche Bank - Alert Delivery"  [B2B / B2B Sales / GAT]
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
territory_owner
from dimension_external_db.pib_territory_dimension
where territory_status = 'Active'
and status_flag <<>> 'DELETE'
group by 
territory_sfdc_id,
territory_name,
territory_roll_up,
territory_owner),


Territory_Dim2 as( select
territory_sfdc_id,
territory_name,
territory_roll_up,
territory_owner
from dimension_external_db.pib_territory_dimension
where territory_status = 'Active'
and status_flag <<>> 'DELETE'
group by 
territory_sfdc_id,
territory_name,
territory_roll_up,
territory_owner),



Comp as (select
company_name,
company_sfdc_id,
company_territory
from 
dimension_external_db.pib_company_dimension
),


Bill_Acct_Dim as (select 
cibs_billing_account_id, salesforce_max_sessions, account_sales_territory, salesforce_territory_owner, salesforce_company_two 
from dimension_external_db.pib_billing_account_dimension
where cibs_billing_account_id in ('9DEU001700','9DEU005300','9DEU004800','9DEU001500','9DEU008900',
'9DEU004000','9DEU006000','9DEU011300','9DEU005600','9DEU003200','9DEU019300','9DEU017100','9DEU004600')
group by 
1,2,3,4,5),


tab as 
(select
mem.user_id, mem.email, mem.user_status, mem.billing_account_id, camp.company_name 

from dimension_external_db.pib_membership_dimension mem
 
LEFT JOIN dimension_external_db.pib_billing_account_dimension bad ON mem.billing_account_id = bad.cibs_billing_account_id  
LEFT JOIN dimension_external_db.pib_company_dimension camp ON bad.salesforce_company_two = camp.company_sfdc_id
WHERE user_status = 'A'
and billing_account_id in ('9DEU001700','9DEU005300','9DEU004800','9DEU001500','9DEU008900',
'9DEU004000','9DEU006000','9DEU011300','9DEU005600','9DEU003200','9DEU019300','9DEU017100','9DEU004600')
group by 1,2,3,4,5)


SELECT 
	SUBSTRING(CAST(cycle_date AS varchar), 1, 7) year_month, 
	folder_id,
	folder_name,
	alert.user_id,
    alert.delivery_type,
	account_id,
	Bill_Acct_Dim.account_sales_territory,
	replace(Bill_Acct_Dim.salesforce_territory_owner, '  ', ' ') as account_owner,
	Comp.company_name,
	plan_id,
	mem.email AS delivery_user_email,
	email_address,
	Salesperson_Dim.user_full_name as salesperson ,
	Territory_Dim.territory_name,
    Territory_Dim.territory_roll_up,
    Territory_Dim2.territory_name as account_territory_name,
    Territory_Dim2.territory_roll_up as account_territory_roll_up,
    SUM(CAST(email_count AS INTEGER)) as email_alerts_sent,
    SUM(CAST(nullif(article_count, '') AS INTEGER))  as articles_sent,  
	SUM(CASE WHEN lower(display_format) LIKE '%fulltext%' THEN CAST(email_count AS INTEGER) ELSE 0 END) full_text_email_alerts_sent,
	SUM(CASE WHEN lower(display_format) LIKE '%fulltext%' THEN CAST(nullif(article_count, '') AS INTEGER)  ELSE 0 END) full_text_articles_sent
from dimension_external_db.pib_alerts alert
LEFT JOIN dimension_external_db.pib_membership_dimension mem ON alert.account_id = mem.billing_account_id  AND alert.user_id = mem.user_id 
LEFT JOIN Bill_Acct_Dim ON Bill_Acct_Dim.cibs_billing_account_id = mem.billing_account_id 
LEFT JOIN Comp ON Bill_Acct_Dim.salesforce_company_two = Comp.company_sfdc_id 
LEFT JOIN Territory_Dim ON Comp.company_territory = Territory_Dim.territory_sfdc_id 
LEFT JOIN Salesperson_Dim ON Territory_Dim.territory_owner = Salesperson_Dim.user_sfdc_id 
LEFT JOIN Territory_Dim2 ON Bill_Acct_Dim.account_sales_territory = Territory_Dim2.territory_name   
left join tab on lower(alert.email_address) = lower(tab.email)
where cycle_date >>= DATE('2023-07-01')
and LOWER(mem.email) <<>> LOWER(email_address)
and ((lower(substring(mem.email, (position('@' in mem.email)+1))) <<>> lower(substring(email_address, (position('@' in email_address)+1)))
	and Territory_Dim.territory_name like'%GAT%')
	or (Territory_Dim.territory_name not like'%GAT%'))  
and tab.user_id is null
group by 1, 2, 3 ,4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17
