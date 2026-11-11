-- Published data source : "Src Breakdown"  [B2B / B2B Product / Factiva]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / sandbox_mk), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select year_month, upper(source_code) as source_code, source_name, language, cibs_billing_account_id , company_name, count(*) as art_count from (

select
substring(cast(cycle_date as varchar),1,7) as year_month,
  pt.id,
  bill.cibs_billing_account_id ,
  comp.company_name, 
  json_extract_scalar(item, '$.meta.source.code') AS source_code,
  json_extract_scalar(item, '$.meta.source.name') AS source_name,
  json_extract_scalar(item, '$.meta.language.code') AS language,
  json_extract_scalar(item, '$.attributes.publication_date') AS pub_date
FROM
  pib_event_data.pib_platform_trace pt
  left join dimension_external_db.pib_billing_account_dimension bill on pt.client_account_id = bill.cibs_billing_account_id 
LEFT JOIN dimension_external_db.pib_company_dimension comp on bill.salesforce_company_two = comp.company_sfdc_id
  ,
    UNNEST(CAST(json_extract(response_message_body, '$.data') AS array(json))) AS t(item)
where transaction_resource_urn like '%genairetrieve%'
and transaction_status_code = 200
and request_message_body like '%metrics_data%'
	
	and cycle_date >>= DATE '2025-05-01')
	
	group by 1,2,3,4,5,6
