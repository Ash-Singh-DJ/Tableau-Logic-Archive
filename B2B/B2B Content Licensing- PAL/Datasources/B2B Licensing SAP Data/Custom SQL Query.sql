-- Published data source : "B2B Licensing SAP Data"  [B2B / B2B Content Licensing- PAL / Datasources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / google_sheets_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with sap as (
select vendor as vendor_id, ps_vendor as "ps_vendor_#", cocode, notes, "1042_reporting", income_code, services_royalty as "services/royalty", country, business_partners as "2010690", email_address, tax_rate, name as "2015026", old_second_vendor_name as "old/second_vendor_name", vendor_city, vendor_tin, dob, individual, corporation, ftin as "2002810", lob_code, w8, signature_date
from google_sheets_db.sap_export_royalties
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22
)

SELECT DISTINCT sap.*,
	   COALESCE(ip1.contractid, ip2.contractid) AS contract_id,
	   COALESCE(ip1.input_provider_code, ip2.input_provider_code) AS input_provider_code,
	   COALESCE(ip1.inputprovidername, ip2.inputprovidername) AS input_provider_name,
	   COALESCE(ip1.publisherrelationcontact, ip2.publisherrelationcontact) AS publisherrelationcontact
FROM sap
LEFT JOIN sandbox_mk.ip_rights_data_current ip1 ON sap.vendor_id = ip1.vendornumber
LEFT JOIN sandbox_mk.ip_rights_data_current ip2 ON sap."ps_vendor_#" = split_part(ip2.vendornumber, '-', 1)
