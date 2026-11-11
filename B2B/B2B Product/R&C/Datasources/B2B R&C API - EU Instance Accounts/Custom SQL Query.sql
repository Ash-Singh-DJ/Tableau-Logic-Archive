-- Published data source : "B2B R&C API - EU Instance Accounts"  [B2B / B2B Product / R&C / Datasources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
SELECT billing_account, cibs_billing_account_id, billing_account_number, salesforce_name, company_name, created_date, last_modified_by_id, last_modified_date, risk_compliance_api, owner_id, record_type_id, request_type, status, territory, contract_type, risk_compliance_feeds, risk_api_via_dna, server_location, server_location1, region, compliance_technical_contact_email, compliance_business_contact_email, account_manager, account_manager_email
FROM dimension_external_db.pib_product_configuration_request_dimension pcr LEFT JOIN 
		(SELECT salesforce_billing_account_id, cibs_billing_account_id, salesforce_status
		FROM dimension_external_db.pib_billing_account_dimension GROUP BY 1,2,3) bad ON pcr.billing_account = bad.salesforce_billing_account_id
WHERE record_type_id = '01270000000MQQyAAO'
AND status = 'Completed'
AND salesforce_status = 'Active'
AND risk_compliance_feeds = 'NONE'
AND server_location = 'European Union'
AND (lower(billing_account_number) NOT LIKE '%9zzz%' OR billing_account_number IS NULL)
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24
ORDER BY 2
