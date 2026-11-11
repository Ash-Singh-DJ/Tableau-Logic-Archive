-- Dashboard   : "B2B New Factiva Usage Dashboard"  [B2B / B2B Product / Factiva]
-- Data source : "Time Spent" (embedded in the workbook)
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select SUBSTRING(cast(date_time as varchar),1,10) year_month_day, user_info_user_ref, user_id, billing_account_id, company_name, visit_id_day, page_section, sum(seconds_between_events) as total_seconds
from (


WITH sample as (
	SELECT event_id,
	event_name,
		product,
		user_info_user_ref, user_id,
		billing_account_id,
		comp.company_name,
		CONCAT(visit_id,SUBSTRING(cast(date_time as varchar),1,10)) visit_id_day,
		--djm.ti_td_sessionid as session,
		ti_td_page_section as page_section,
		date_time
	FROM pib_event_data.pib_product_metrics djm
	left join dimension_external_db.pib_membership_dimension mem on djm.user_info_user_ref = mem.pib_member_id 
	LEFT JOIN dimension_external_db.pib_billing_account_dimension bad on djm.user_info_account_id = bad.cibs_billing_account_id
LEFT JOIN dimension_external_db.pib_company_dimension comp on comp.company_sfdc_id = bad.salesforce_company_two
	WHERE user_info_user_ref IS NOT null
	and product = 'New Factiva'
	and event_name in ('page_view', 'user_action')
	and mem.billing_account_id <<>> '9ZZZ139100'
		AND cycle_date >>= date('2021-11-01')
)
	SELECT event_id,
	event_name,
		user_info_user_ref,
		user_id,
		billing_account_id,
		company_name,
		visit_id_day,
		--session,
		product,
		date_time,
		page_section,
		date_diff(
			'second',
			LAG(date_time, 1) OVER (
				PARTITION BY product,
				user_info_user_ref,
				visit_id_day 
				ORDER BY date_time ASC
			),
			date_time
		) as seconds_between_events
	FROM sample
	)
	group by 1,2,3,4,5,6,7
