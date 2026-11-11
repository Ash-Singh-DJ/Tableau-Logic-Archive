-- Dashboard   : "Proquest IP Report (Commerce Envelope Version)"  [B2B / B2B Content Licensing- PAL]
-- Data source : "CE IP Report" = published source "CE IP Report"  [B2B / B2B Content Licensing- PAL]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select mem.user_id, mem.plan_id, bad.cibs_billing_account_id, comp.company_name, begin_letter_eid, begin_letter_access_point_code, 
begin_letter_encoded_session_id, cleansed_client_ip, count(distinct concat(coalesce(ce.begin_letter_ssuqceid, ''), '_', ce.letters_accession_number)) as count_events, 
min(begin_letter_request_date_time) min_date, max(begin_letter_request_date_time) max_date2
--select * 
from publisher_reporting_db.commerce_envelope ce
left join dimension_external_db.pib_membership_dimension mem on ce.begin_letter_eid = mem.pib_member_id 
LEFT JOIN dimension_external_db.pib_billing_account_dimension bad on mem.billing_account_id = bad.cibs_billing_account_id
LEFT JOIN dimension_external_db.pib_company_dimension comp on comp.company_sfdc_id = bad.salesforce_company_two
left join dimension_external_db.pib_territory_dimension ter on bad.salesforce_territory = ter.territory_sfdc_id 
where (territory_name = 'Proquest' or bad.cibs_billing_account_id = '9IND010100')

--where  begin_letter_eid = 'E6OO2HVCQHVPFICLUBMGV2NQG4'
and (bad.cibs_billing_account_id not like '9ZZZ%'
or bad.cibs_billing_account_id = '9ZZZ030200') 
and letters_function_code in ('VAR01', 'VAR03', 'VHI01','VIM01', 'VKW01')
--and begin_letter_eid = 'E6OO2HVCQHVPFICLUBMGV2NQG4'
--and plan_id in ('0086','0087')
and letters_response_date_time >>= cast('2024-10-01' as date)
group by 1,2,3,4,5,6,7,8
