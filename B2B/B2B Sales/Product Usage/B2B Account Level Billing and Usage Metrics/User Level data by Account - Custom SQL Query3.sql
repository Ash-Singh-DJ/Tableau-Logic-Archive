-- Dashboard   : "B2B Account Level Billing and Usage Metrics"  [B2B / B2B Sales / Product Usage]
-- Data source : "User Level data by Account" = published source "User Level data by Account"  [B2B / B2B Sales / Data Sources]
-- Relation    : Custom SQL "Custom SQL Query3"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with 

Bill_Acct_Dim as 
(select 
cibs_billing_account_id, salesforce_max_sessions, account_sales_territory, salesforce_territory_owner, salesforce_company_two 
from dimension_external_db.pib_billing_account_dimension
group by 
1,2,3,4,5),


tab as 
(select
mem.user_id, mem.email, mem.user_status, mem.billing_account_id, camp.company_name 

from dimension_external_db.pib_membership_dimension mem
 
LEFT JOIN dimension_external_db.pib_billing_account_dimension bad ON mem.billing_account_id = bad.cibs_billing_account_id  
LEFT JOIN dimension_external_db.pib_company_dimension camp ON bad.salesforce_company_two = camp.company_sfdc_id
WHERE user_status = 'A'

group by 1,2,3,4,5)


SELECT 
	
	folder_id,
	folder_name,
	alert.user_id,
    alert.delivery_type,
	account_id,
	Bill_Acct_Dim.account_sales_territory,
	mem.email AS delivery_user_email,
	email_address,
    SUM(CAST(email_count AS INTEGER)) as email_alerts_sent,
    SUM(CAST(nullif(article_count, '') AS INTEGER))  as articles_sent,  
	SUM(CASE WHEN lower(display_format) LIKE '%fulltext%' THEN CAST(email_count AS INTEGER) ELSE 0 END) full_text_email_alerts_sent,
	SUM(CASE WHEN lower(display_format) LIKE '%fulltext%' THEN CAST(nullif(article_count, '') AS INTEGER)  ELSE 0 END) full_text_articles_sent
from dimension_external_db.pib_alerts alert
LEFT JOIN dimension_external_db.pib_membership_dimension mem ON alert.account_id = mem.billing_account_id  AND alert.user_id = mem.user_id 
LEFT JOIN Bill_Acct_Dim ON Bill_Acct_Dim.cibs_billing_account_id = mem.billing_account_id 
LEFT JOIN dimension_external_db.pib_company_dimension  Comp ON Bill_Acct_Dim.salesforce_company_two = Comp.company_sfdc_id 
LEFT JOIN dimension_external_db.pib_territory_dimension ter ON Comp.company_territory = ter.territory_sfdc_id 
left join tab on lower(alert.email_address) = lower(tab.email)
where cycle_date >>= DATE_ADD('day', -90, CURRENT_DATE)
and LOWER(mem.email) <<>> LOWER(email_address)
and ((lower(substring(mem.email, (position('@' in mem.email)+1))) <<>> lower(substring(email_address, (position('@' in email_address)+1)))
	and ter.territory_name like'%GAT%')
	or (ter.territory_name not like'%GAT%'))  
and tab.user_id is null
group by 1, 2, 3 ,4, 5, 6, 7, 8
