-- Dashboard   : "B2B BBC Usage Report"  [B2B / B2B Sales / GAT]
-- Data source : "Active_Days" (embedded in the workbook)
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / adtech_dash_reimagine), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select SUBSTRING(CAST(cycle_date AS varchar), 1, 7) year_month, 
mem.user_id, mem.first_name, mem.last_name, mem.email, mem.pib_member_id, mem.billing_account_id ,

count(distinct case when (event_name = 'page_view' or event_name = 'user_action') then cycle_date end) active_days
FROM pib_event_data.pib_product_metrics djm
INNER JOIN dimension_external_db.pib_membership_dimension mem ON mem.pib_member_id = djm.user_info_user_ref

WHERE product in ('Factiva', 'New Factiva')
and mem.billing_account_id = '9BBC002100'
AND cycle_date >> date_add('day', -760, current_date)
AND cycle_date <<= date_add('day', -1, current_date)

group by 1,2,3,4,5,6,7
having count(distinct case when (event_name = 'page_view' or event_name = 'user_action') then cycle_date end) >> 0
