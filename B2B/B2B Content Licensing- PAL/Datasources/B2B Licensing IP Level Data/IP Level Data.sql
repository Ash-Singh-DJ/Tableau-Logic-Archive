-- Published data source : "B2B Licensing IP Level Data"  [B2B / B2B Content Licensing- PAL / Datasources]
-- Relation    : Custom SQL "IP Level Data"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
/* IP LEVEL QUERY */
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

multiple_rpcs AS (
	SELECT ippubinfo_ip_code_value, COUNT(DISTINCT billingdist_royaltyprovider_code_value)
	FROM cntsrccurr 
	WHERE srcinfo_statuscode_code_value = 'ACT'
	GROUP BY 1
	HAVING COUNT(DISTINCT billingdist_royaltyprovider_code_value) >> 1
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
),

ip_roy_joined AS (
	SELECT COALESCE(ipr.input_provider_code, mapp.input_provider_code) AS mapped_ip_code,
		   cycle_date,
		   SUM(royalty_usd) AS royalty_usd
	FROM ip_royalty roy
	LEFT JOIN ipr ON roy.input_provider_code = ipr.input_provider_code 
	LEFT JOIN rpc_ip_map mapp ON roy.input_provider_code = mapp.billingdist_royaltyprovider_code_value
	GROUP BY 1, 2
),

ip_roy_calc AS (
	SELECT mapped_ip_code,
		   (SELECT MAX(cycle_date) FROM ip_roy_joined) AS latest_month,
		   SUM(CASE WHEN cycle_date = (SELECT MAX(cycle_date) FROM ip_roy_joined)
		   			THEN royalty_usd ELSE 0 END) AS latest_month_royalty,
		   AVG(CASE WHEN date_diff('month',DATE(cycle_date),DATE((SELECT MAX(cycle_date) FROM ip_roy_joined))) 
		   				IN (1, 2, 3) THEN royalty_usd END) three_month_average
	FROM ip_roy_joined
	GROUP BY 1, 2
),

ip_carry_forward AS (
	SELECT CASE WHEN rpc_id LIKE '%BRDBT%' THEN 'BRDBT'
				WHEN rpc_id LIKE '%REUTFF%' THEN 'REUT'
				WHEN rpc_id LIKE '%DJFF%' THEN 'DJ'
				WHEN rpc_id = 'DJSEG' THEN 'DJ'
				WHEN rpc_id LIKE '%NPC%' AND rpc_id LIKE '%INV%' THEN 'REUT'
				WHEN rpc_id = 'FT-ACD' THEN 'FTM'
				WHEN rpc_id = 'FINN-FF' THEN 'FINN'
				WHEN rpc_id = 'IGUEXH' THEN 'IGPL'
				WHEN rpc_id = 'COMPRENN' THEN 'COMPREN'
				WHEN rpc_id = 'NPC-ESTAD' THEN 'ESTAD'
				WHEN rpc_id = 'JEN' THEN 'KYODO'
				WHEN rpc_id = 'SARLSB' THEN 'SARLPUB'
				WHEN rpc_id LIKE '%NIHON%' THEN 'NIHON'
				WHEN rpc_id LIKE '%BOARDR%' THEN 'BOARDR'
				WHEN rpc_id = 'UNIDAB' THEN 'MUNDINT'
				WHEN rpc_id = 'SCMB' THEN 'SCM'
				WHEN rpc_id LIKE '%NPC%' AND rpc_id LIKE '%SUN%' THEN 'SUNGD'
				WHEN rpc_id = 'AXELCH' THEN 'AXELS'
				ELSE rpc_id 
				END AS input_provider_code,
		   pr_comments AS reason,
		   local_currency_id AS local_currency,
		   ammount_local AS local_amount,
		   ammount_usd AS usd_ammount,
		   royalty_comments
	FROM dimension_external_db.royalty_monthly_carry_forward_report 
	WHERE cycle_date = (SELECT MAX(cycle_date) FROM dimension_external_db.royalty_monthly_carry_forward_report)
),

ip_carry_forward_joined AS (
	SELECT DISTINCT COALESCE(ip.input_provider_code, mapp.input_provider_code) AS cf_input_provider_code,
		   roy.*
	FROM ip_carry_forward roy
	LEFT JOIN (SELECT DISTINCT input_provider_code FROM ipr) ip ON roy.input_provider_code = ip.input_provider_code 
	LEFT JOIN rpc_ip_map mapp ON roy.input_provider_code = mapp.billingdist_royaltyprovider_code_value
),

document_counts AS (
	SELECT source_code, SUM(article_count) documents
	FROM (SELECT source_code, CAST(publication_month AS varchar) start_date, CAST(end_date AS varchar) end_date, article_count, CAST(actual_start_date AS varchar) actual_start_date, CAST(actual_end_date AS varchar) actual_end_date
                FROM dimension_external_db.content_volumes) 
	WHERE DATE(SUBSTRING(start_date,1,10)) >>= DATE_ADD('day', -1, DATE_TRUNC('month', DATE_ADD('month', -12, CURRENT_DATE)))
	      AND DATE(SUBSTRING(start_date,1,10)) <<= DATE_ADD('day', -1, DATE_TRUNC('month', CURRENT_DATE))
	GROUP BY 1
),

cvi as (
	select case 
	   when month(period) in (1, 2, 3) then concat(cast(year(period) as varchar), ' ', 'Q4-Q1')
	   when month(period) in (4, 5, 6) then concat(cast(year(period) as varchar), ' ', 'Q1-Q2')
	   when month(period) in (7, 8, 9) then concat(cast(year(period) as varchar), ' ', 'Q2-Q3')
	   when month(period) in (10, 11, 12) then concat(cast(year(period) as varchar), ' ', 'Q3-Q4')
	   end 
	   as cy_quarter, *
            from sandbox_mk.factiva_content_value_index_ui
),

fvi_prod as (
	SELECT * FROM cvi 
	WHERE cy_quarter = (SELECT MAX(cy_quarter) FROM cvi) and cycle_date = (select max(cycle_date) from cvi)  
),

num_sources AS (
	SELECT CASE WHEN ippubinfo_ip_code_value LIKE '%NYT%' THEN billingdist_royaltyprovider_code_value 
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
				ELSE ippubinfo_ip_code_value END AS input_provider_code,
		   COUNT(DISTINCT CASE WHEN cntsrccurr.srcinfo_statuscode_code_value = 'ACT' THEN srcinfo_code_value END) AS count_active_sources,
		   COUNT(DISTINCT srcinfo_code_value) AS count_all_sources,
		   COUNT(DISTINCT CASE WHEN rnc_vi.industry_list IS NOT NULL
		   						AND cntsrccurr.srcinfo_statuscode_code_value = 'ACT' THEN srcinfo_code_value END) AS count_active_industry_sources,
		   MAX(rnc_vi.rnc_value_index) AS max_rvi_value_index,
		   MAX(fvi.value_index) AS max_fvi_value_index,
		   SUM(docs.documents) AS last_12mo_doc_count
	FROM cntsrccurr
	LEFT JOIN ipr ON cntsrccurr.ippubinfo_ip_code_value = ipr.input_provider_code 
	LEFT JOIN ipr ip_rpc ON cntsrccurr.billingdist_royaltyprovider_code_value = ip_rpc.input_provider_code 
	LEFT JOIN (SELECT * FROM sandbox_mk.rnc_value_index
			   WHERE cycle_date = (SELECT MAX(cycle_date) FROM sandbox_mk.rnc_value_index)) 
			   AS rnc_vi ON cntsrccurr.srcinfo_code_value = rnc_vi.source_code 
    LEFT JOIN fvi_prod fvi 
			  ON cntsrccurr.srcinfo_code_value = fvi.source_code 
	LEFT JOIN document_counts docs ON cntsrccurr.srcinfo_code_value = docs.source_code
	GROUP BY 1
)

SELECT DISTINCT ipr.*,
	   cf.reason AS cf_reason,
	   cf.local_currency AS cf_local_currency,
	   cf.local_amount AS cf_local_amount,
	   cf.usd_ammount AS cf_usd_amount,
	   cf.royalty_comments AS cf_royalty_comments,
	   roy.latest_month AS royalty_month, 
	   COALESCE(roy.latest_month_royalty,0) AS royalty_usd,
	   COALESCE(roy.three_month_average,0) AS prev_3mo_royalty_avg,
	   COALESCE(roy.latest_month_royalty,0) - COALESCE(roy.three_month_average,0) AS diff_vs_3mo_avg,
	   (COALESCE(roy.latest_month_royalty,0) - COALESCE(roy.three_month_average,0)) 
	   		/ NULLIF(COALESCE(roy.three_month_average,0),0) AS pct_diff_vs_3mo_avg,
	   COALESCE(sc.count_active_sources,0) AS count_active_sources,
	   COALESCE(sc.count_all_sources,0) AS count_all_sources,
	   sc.max_rvi_value_index,
	   sc.max_fvi_value_index,
	   COALESCE(sc.last_12mo_doc_count,0) last_12mo_doc_count
FROM ipr
LEFT JOIN ip_roy_calc roy ON ipr.input_provider_code = roy.mapped_ip_code
LEFT JOIN num_sources sc ON ipr.input_provider_code = sc.input_provider_code
LEFT JOIN ip_carry_forward_joined cf ON ipr.input_provider_code = cf.cf_input_provider_code
WHERE (ipr.status LIKE '%Active%' 
	OR ipr.status LIKE '%Terminated%')
	AND ipr.input_provider_code IS NOT NULL
	AND ipr.input_provider_code <<>> ''
	AND NOT (
		(ipr.contractid = 2478 AND ipr.input_provider_code = 'PARKI')
		OR (ipr.contractid = 488 AND ipr.input_provider_code = 'GAZEM')
		OR (ipr.contractid = 23 AND ipr.input_provider_code = 'FAZG')
		OR (ipr.contractid = 1172 AND ipr.input_provider_code = 'EXPRES')
		OR (ipr.contractid = 410 AND ipr.input_provider_code = 'ENTRE')
		OR (ipr.contractid = 1298 AND ipr.input_provider_code = 'EDTPL')
		OR (ipr.contractid = 2431 AND ipr.input_provider_code = 'AUSSE')
		)
