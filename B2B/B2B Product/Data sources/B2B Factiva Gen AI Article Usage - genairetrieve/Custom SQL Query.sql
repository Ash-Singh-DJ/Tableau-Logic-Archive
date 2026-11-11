-- Published data source : "B2B Factiva Gen AI Article Usage - genairetrieve"  [B2B / B2B Product / Data sources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
SELECT cycle_date, id, event_datetime, client_user_id,  client_account_id, comp.company_name, transaction_status_code, response_message_body, request_message_body,
(case when request_message_body like '%metrics_data%' then true end) as metrics_data_true, 
substring(request_message_body, strpos(request_message_body, 'user_id":')+10,
(strpos(request_message_body, 'work_id') - strpos(request_message_body, 'user_id":'))
) as user_id,

substring(request_message_body, strpos(request_message_body, 'work_id":')+10,
(strpos(request_message_body, 'GenAIRetrieval') - strpos(request_message_body, 'work_id":'))
) as work_id,
(case when response_message_body like '%total_count%' then 
substring(response_message_body, strpos(response_message_body, 'meta":{"total_count":')+20,5) else 'na' end) as total_count
FROM pib_event_data.pib_platform_trace pt
left join dimension_external_db.pib_billing_account_dimension bill on pt.client_account_id = bill.cibs_billing_account_id 
LEFT JOIN dimension_external_db.pib_company_dimension comp on bill.salesforce_company_two = comp.company_sfdc_id
where transaction_resource_urn like '%genairetrieve%'
and transaction_status_code = 200

--and client_account_id = '9ZZZ139100'
--and request_message_body like '%metrics_data%'
--and request_message_body like '%dc86adff331d4dcabf1344bd7f0ab2e6%'
--and client_user_id = 'X002787377'
and cycle_date >>= date('2025-01-01')
