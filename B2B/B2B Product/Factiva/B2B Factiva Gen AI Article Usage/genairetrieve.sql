-- Dashboard   : "B2B Factiva Gen AI Article Usage"  [B2B / B2B Product / Factiva]
-- Data source : "genairetrieve" = published source "genairetrieve"  [B2B / B2B Product / Factiva]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select * from (

SELECT cycle_date, id, event_datetime, client_user_id,  client_account_id, comp.company_name,
transaction_id, 
response_headers_date as transaction_datetime_utc,
transaction_resource_urn,
json_extract_scalar(response_message_body,'$.meta.metrics_data.user_id') as user_id,
json_extract_scalar(response_message_body,'$.meta.metrics_data.work_id') AS work_id,
json_extract_scalar(response_message_body,'$.meta.metrics_data.application_id') AS application_id,
cast(json_extract_scalar(response_message_body,'$.meta.total_count') as INT) AS total_count
FROM pib_event_data.pib_platform_trace pt
left join dimension_external_db.pib_billing_account_dimension bill on pt.client_account_id = bill.cibs_billing_account_id 
LEFT JOIN dimension_external_db.pib_company_dimension comp on bill.salesforce_company_two = comp.company_sfdc_id
where transaction_resource_urn like '%genairetrieve%'
and transaction_status_code = 200
and request_message_body like '%metrics_data%'
--and request_message_body like '%Smart Summary%'

and cycle_date >>= date('2025-11-01') )
where user_id is not null and work_id is not null
