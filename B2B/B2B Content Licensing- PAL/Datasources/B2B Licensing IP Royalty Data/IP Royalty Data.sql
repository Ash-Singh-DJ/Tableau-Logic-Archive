-- Published data source : "B2B Licensing IP Royalty Data"  [B2B / B2B Content Licensing- PAL / Datasources]
-- Relation    : Custom SQL "IP Royalty Data"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
/* Royalty Queries */
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

rpc_ip_map AS (
	SELECT CASE WHEN billingdist_royaltyprovider_code_value = 'MCLATA' THEN 'MCLAT'
				WHEN billingdist_royaltyprovider_code_value = 'PRSCMR' THEN 'PRSCM'
				WHEN billingdist_royaltyprovider_code_value LIKE 'NLAMAL%' THEN 'NLAMAL'
				WHEN billingdist_royaltyprovider_code_value = 'LWTMG' THEN 'ASNEW'
				WHEN billingdist_royaltyprovider_code_value = 'AGESAB' THEN 'AGESA'
				WHEN billingdist_royaltyprovider_code_value = 'TAMEDTC' THEN 'TAMEDF'
				WHEN billingdist_royaltyprovider_code_value = 'SCOTUN' THEN 'MGNLT'
				WHEN billingdist_royaltyprovider_code_value = 'BERZEIT' THEN 'BERLV'
				WHEN billingdist_royaltyprovider_code_value = 'IGUEXH' THEN 'IGPL'
				WHEN billingdist_royaltyprovider_code_value = 'FOCUSM' THEN 'FOCUS'
				WHEN billingdist_royaltyprovider_code_value = 'DATALB' THEN 'DATAL'
				WHEN billingdist_royaltyprovider_code_value = 'GLNM' THEN 'GLNMED'
				ELSE ippubinfo_ip_code_value END AS input_provider_code, 
		   billingdist_royaltyprovider_code_value
	FROM cntsrccurr 
	WHERE srcinfo_statuscode_code_value = 'ACT'
	GROUP BY 1, 2
	UNION ALL 
	SELECT CASE WHEN billingdist_royaltyprovider_code_value = 'ARMOEB' THEN 'ARMOE'
				WHEN billingdist_royaltyprovider_code_value = 'FINTIL' THEN 'FTELP'
				WHEN billingdist_royaltyprovider_code_value = 'SHNSECB' THEN 'SHNSEC'
				ELSE ippubinfo_ip_code_value END AS input_provider_code, 
		   billingdist_royaltyprovider_code_value
	FROM cntsrccurr 
	WHERE billingdist_royaltyprovider_code_value IN ('GRUSAE','TRBJ','SUEDDB','FTEIW','REEDBB','DAGENB',
									'ETICB','IOMA','WFAR','AGEJB','AXELSH','AXELSF',
									'AXELSM','AXELSG','HAYMIH','ARMOEB','FINTIL', 'SHNSECB')
	GROUP BY 1, 2
),

ip_royalty AS (
	SELECT CASE WHEN input_provider_code LIKE '%BRDBT%' THEN 'BRDBT'
				WHEN input_provider_code LIKE '%REUTFF%' THEN 'REUT'
				WHEN input_provider_code LIKE '%DJFF%' THEN 'DJ'
				WHEN input_provider_code = 'DJSEG' THEN 'DJ'
				WHEN input_provider_code LIKE '%NPC%' AND input_provider_code LIKE '%INV%' THEN 'REUT'
				WHEN input_provider_code = 'FT-ACD' THEN 'FTM'
				WHEN input_provider_code = 'FINN-FF' THEN 'FINN'
				WHEN input_provider_code = 'IGUEXH' THEN 'IGPL'
				WHEN input_provider_code = 'COMPRENN' THEN 'COMPREN'
				WHEN input_provider_code = 'NPC-ESTAD' THEN 'ESTAD'
				WHEN input_provider_code = 'JEN' THEN 'KYODO'
				WHEN input_provider_code = 'SARLSB' THEN 'SARLPUB'
				WHEN input_provider_code LIKE '%NIHON%' THEN 'NIHON'
				WHEN input_provider_code LIKE '%BOARDR%' THEN 'BOARDR'
				WHEN input_provider_code = 'UNIDAB' THEN 'MUNDINT'
				WHEN input_provider_code = 'SCMB' THEN 'SCM'
				WHEN input_provider_code LIKE '%NPC%' AND input_provider_code LIKE '%SUN%' THEN 'SUNGD'
				WHEN input_provider_code = 'AXELCH' THEN 'AXELS'
				ELSE input_provider_code 
				END AS input_provider_code,
			royalty_usd,
			cycle_date
	FROM dimension_external_db.royalty_monthly_payment_analysis roy
	WHERE DATE(cycle_date) >>= DATE('2017-01-01')
),

ip_roy_joined AS (
	SELECT COALESCE(ip.input_provider_code, mapp.input_provider_code) AS input_provider_code,
		   cycle_date,
		   SUM(royalty_usd) AS royalty_usd
	FROM ip_royalty roy
	LEFT JOIN (SELECT DISTINCT input_provider_code FROM ipr) ip ON roy.input_provider_code = ip.input_provider_code 
	LEFT JOIN rpc_ip_map mapp ON roy.input_provider_code = mapp.billingdist_royaltyprovider_code_value
	GROUP BY 1, 2
)

SELECT *
FROM ip_roy_joined
