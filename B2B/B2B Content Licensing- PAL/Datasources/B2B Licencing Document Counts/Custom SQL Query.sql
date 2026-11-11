-- Published data source : "B2B Licencing Document Counts"  [B2B / B2B Content Licensing- PAL / Datasources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / sandbox_mk), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
WITH cntsrccurr as 
(
select srcinfo_code_value, docdata_sourcetype_value, srcinfo_sourcename, srcinfo_langn, srcinfo_statuscode_code_value, ippubinfo_publisher_code_value as ippubinfo_ip_code_value, ippubinfo_ip_name, billingdist_royaltyprovider_code_value, billingdist_billgroup_code_value, billingdist_billgroup_name, srcinfo_articletypen as article_coverage, srcinfo_coverage_value, srcinfo_firstissuedate_value, srcinfo_onlinedate_value, coalesce(cast(srcinfo_maxlag_value as int),0), coalesce(cast(srcinfo_minlag_value as int),0), srcinfo_nomlagn, ippubinfo_srcrightstype_code_value, billingdist_embargohours_value, billingdist_embargodays_value, billingdist_expirationhours_value, billingdist_expirationdays_value, ippubinfo_srcprimarytype_description, srcinfo_srcpriority_value, ippubinfo_allowtranslation_value, srcinfo_description
from dimension_external_db.cdb_source_docs_current 
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26
order by 1
),

ipr as (
select cast(contract_id as integer) as contractid, status, input_provider_name as inputprovidername, country_of_origin as countryoforigin, territory, input_provider_code, publisher_relation_contact as publisherrelationcontact, vendor_number as vendornumber, vendor_name as vendorname, cast(contract_eff_date as varchar) as contracteffdate, cast(contract_term as varchar) as contractterm, cast(term_end_date as varchar) as termenddate, case when auto_renewal = True then 'True' else 'False' end as autorenewal, cast(renewal_term as varchar) as renewalterm, case when termination_delete_content = True then 'True' else 'False' end as terminationdeletecontent, cast(termination_delete_content_time_frame as varchar) as terminationdeletecontenttimeframe, cast(royalty_rate_for_ip as varchar) as royaltyrateforip, case when fixed_fee = True then 'True' else 'False' end as fixedfee, cast(fixed_fee_amount as varchar) as fixedfeeamount, fixed_fee_frequency as fixedfeefrequency, case when guaranteed_min = True then 'True' else 'False' end as guaranteedmin, cast(g_min_amount as varchar) as gminamount, g_min_frequency as gminfrequency, case when new_ad_notify = True then 'True' else 'False' end as newadnotify, case when new_ad_consent = True then 'True' else 'False' end as newadconsent, case when blocking = True then 'True' else 'False' end as blocking, case when extranet_distribution = True then 'True' else 'False' end as extranetdistribution, cast(factiva_storage as varchar) as factivastorage, case when third_party_storage = True then 'True' else 'False' end as thirdpartystorage, case when customer_headline_storage = True then 'True' else 'False' end as customerheadlinestorage, cast(customer_article_storage as varchar) as customerarticlestorage,	case when new_product_notify = True then 'True' else 'False' end as newproductnotify, case when new_product_consent = True then 'True' else 'False' end as newproductconsent, case when translation_rights = True then 'True' else 'False' end as translationrights, case when embargo = True then 'True' else 'False' end as embargo, case when expiry = True then 'True' else 'False' end as expiry, payment_notes as paymentnotes, commercial_stat_notes as commercialstatnotes
from dimension_external_db.ip_rights_data_current 
),

multiple_rpcs AS (
	SELECT ippubinfo_ip_code_value, COUNT(DISTINCT billingdist_royaltyprovider_code_value)
	FROM cntsrccurr
	WHERE srcinfo_statuscode_code_value = 'ACT'
	GROUP BY 1
	HAVING COUNT(DISTINCT billingdist_royaltyprovider_code_value) >> 1
),

source_ip_mapping AS (
	SELECT srcinfo_code_value,
		   CASE WHEN ippubinfo_ip_code_value LIKE '%NYT%' THEN billingdist_royaltyprovider_code_value 
				WHEN ippubinfo_ip_code_value IN ('NBITE','JOINS','TRINDY') THEN billingdist_royaltyprovider_code_value
				WHEN billingdist_royaltyprovider_code_value LIKE 'NLAMAL%' THEN 'NLAMAL'
				WHEN ippubinfo_ip_code_value = 'NEWSI' AND billingdist_billgroup_name LIKE '%Reach Plc%' THEN 'MGNLT'
				WHEN ippubinfo_ip_code_value = 'NEWSI' THEN billingdist_royaltyprovider_code_value
				WHEN ippubinfo_ip_code_value = 'REEDUS' AND billingdist_royaltyprovider_code_value <<>> 'REEDBA' THEN billingdist_royaltyprovider_code_value 
				WHEN billingdist_royaltyprovider_code_value IN ('GEDINN','FINN','VWDV','GEDIG','FOCUSO','STTRB',
											   'AEFENW','ABMFNI','') THEN billingdist_royaltyprovider_code_value
				WHEN ippubinfo_ip_code_value IN ('DJ','DJSEG','DJN','DJENT')	
					AND billingdist_royaltyprovider_code_value NOT LIKE 'DJ%'	THEN billingdist_royaltyprovider_code_value
				WHEN ippubinfo_ip_code_value IN ('DJ','DJSEG','DJN','DJENT') THEN 'DJ'
				WHEN ippubinfo_ip_code_value = 'BRDB' THEN 'BRDBT'
				WHEN ippubinfo_ip_code_value LIKE '%REUT%' THEN 'REUT'
				WHEN ippubinfo_ip_code_value = 'SPIEG' AND billingdist_royaltyprovider_code_value <<>> 'BERZEIT' THEN billingdist_royaltyprovider_code_value 
				WHEN billingdist_royaltyprovider_code_value = 'MCLATA' THEN 'MCLAT'
				WHEN billingdist_royaltyprovider_code_value = 'PRSCMR' THEN 'PRSCM'
				WHEN billingdist_royaltyprovider_code_value = 'AGESAB' THEN 'AGESA'
				WHEN billingdist_royaltyprovider_code_value = 'BERZEIT' THEN 'BERLV'
				WHEN billingdist_royaltyprovider_code_value = 'IGUEXH' THEN 'IGPL'
				WHEN billingdist_royaltyprovider_code_value = 'FOCUSM' THEN 'FOCUS'
				WHEN billingdist_royaltyprovider_code_value = 'DATALB' THEN 'DATAL'
				WHEN billingdist_royaltyprovider_code_value = 'GLNM' THEN 'GLNMED'
				WHEN billingdist_royaltyprovider_code_value = 'ARMOEB' THEN 'ARMOE'
				WHEN billingdist_royaltyprovider_code_value = 'FINTIL' THEN 'FTELP'
				WHEN billingdist_royaltyprovider_code_value = 'SHNSECB' THEN 'SHNSEC'
				WHEN cntsrccurr.ippubinfo_ip_code_value IN (SELECT ippubinfo_ip_code_value FROM multiple_rpcs)
		   			AND ipr.status LIKE '%Active%'
		   			AND ip_rpc.status LIKE '%Active%' THEN cntsrccurr.billingdist_royaltyprovider_code_value
	   			WHEN ipr.status LIKE '%Terminated%' 
	   				AND ip_rpc.status LIKE '%Active%' THEN cntsrccurr.billingdist_royaltyprovider_code_value
	   			WHEN (ipr.input_provider_code IS NULL OR ipr.input_provider_code = '')
	   				AND ip_rpc.input_provider_code IS NOT NULL THEN cntsrccurr.billingdist_royaltyprovider_code_value
				ELSE ippubinfo_ip_code_value END AS ip_code_adj
	FROM cntsrccurr
	LEFT JOIN ipr ON cntsrccurr.ippubinfo_ip_code_value = ipr.input_provider_code 
	LEFT JOIN ipr ip_rpc ON cntsrccurr.billingdist_royaltyprovider_code_value = ip_rpc.input_provider_code 
	GROUP BY 1, 2
),

docs as (SELECT source_code, CAST(publication_month AS varchar) start_date, CAST(end_date AS varchar) end_date, article_count, CAST(actual_start_date AS varchar) actual_start_date, CAST(actual_end_date AS varchar) actual_end_date
FROM dimension_external_db.content_volumes
)


SELECT source_code, 
	   ip_code_adj,
	   SUBSTRING(start_date,1,10) AS start_date,
	   SUM(article_count) AS documents
FROM docs
LEFT JOIN source_ip_mapping sc_ip ON docs.source_code = sc_ip.srcinfo_code_value
WHERE DATE(SUBSTRING(start_date,1,10)) >>= DATE_ADD('day', -1, DATE_TRUNC('month', DATE_ADD('month', -24, CURRENT_DATE)))
	      AND DATE(SUBSTRING(start_date,1,10)) <<= DATE_ADD('day', -1, DATE_TRUNC('month', CURRENT_DATE))
GROUP BY 1, 2, 3
