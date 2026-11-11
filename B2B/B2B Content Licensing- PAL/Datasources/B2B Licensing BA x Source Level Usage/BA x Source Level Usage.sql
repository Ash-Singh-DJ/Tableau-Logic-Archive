-- Published data source : "B2B Licensing BA x Source Level Usage"  [B2B / B2B Content Licensing- PAL / Datasources]
-- Relation    : Custom SQL "BA x Source Level Usage"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
/* Billing Account USAGE DATA */
WITH cntsrccurr as 
(
select srcinfo_code_value, docdata_sourcetype_value, srcinfo_sourcename, srcinfo_langn, srcinfo_statuscode_code_value, ippubinfo_publisher_code_value as ippubinfo_ip_code_value, ippubinfo_ip_name, billingdist_royaltyprovider_code_value, billingdist_billgroup_code_value, billingdist_billgroup_name, srcinfo_articletypen as article_coverage, srcinfo_coverage_value, srcinfo_firstissuedate_value, srcinfo_onlinedate_value, coalesce(cast(srcinfo_maxlag_value as int),0), coalesce(cast(srcinfo_minlag_value as int),0), srcinfo_nomlagn, ippubinfo_srcrightstype_code_value, billingdist_embargohours_value, billingdist_embargodays_value, billingdist_expirationhours_value, billingdist_expirationdays_value, ippubinfo_srcprimarytype_description, srcinfo_srcpriority_value, ippubinfo_allowtranslation_value, srcinfo_description
from dimension_external_db.cdb_source_docs_current 
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26
order by 1
),

omnit AS (
	SELECT SUBSTRING(CAST(date_time AS varchar),1, 7) year_month, post_evar3, Source_Code, geo_country,
         SUM(CASE WHEN (post_evar4 = 'Fact_ART_ArticleView' or post_prop3 = 'ARTICLE' or lower(post_pagename) like '%article%') AND
                       CAST(post_page_event AS varchar) = '0' AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5', '8', '9'))
                  THEN 1 ELSE 0 END) article_views
  	FROM (
	    SELECT date_time, hit_source, post_page_event, exclude_hit, geo_country,
	    	   post_evar3, post_evar4, post_prop3, post_pagename, post_prop4, post_prop20,
	           CASE WHEN STRPOS(post_prop8,'_') = 0 THEN UPPER(post_prop8)
	                ELSE UPPER(SUBSTRING(post_prop8,1,STRPOS(post_prop8,'_')-1)) END Source_Code
	    FROM fact_external_db.omniture_event_fact
	    WHERE reporting_suite = 'djfactiva'
	      AND cycle_date >>= DATE_ADD('day', -1, DATE_TRUNC('month', DATE_ADD('month', -24, CURRENT_DATE)))
	      AND cycle_date <<= DATE_ADD('day', -1, DATE_TRUNC('month', CURRENT_DATE))
	      )
	 WHERE DATE_TRUNC('day',date_time) >> DATE_ADD('day', -1, DATE_TRUNC('month', DATE_ADD('month', -24, CURRENT_DATE)))
    	AND DATE_TRUNC('day',date_time) << DATE_TRUNC('month', CURRENT_DATE)
	 GROUP BY 1, 2, 3, 4
	 HAVING SUM(CASE WHEN (post_evar4 = 'Fact_ART_ArticleView' or post_prop3 = 'ARTICLE' or lower(post_pagename) like '%article%') AND
	                      CAST(post_page_event AS varchar) = '0' AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5', '8', '9'))
	                 THEN 1 ELSE 0 END) >> 0
),

company_mapping AS (
	SELECT mem.pib_member_id, mem.user_id, mem.first_name, mem.last_name, mem.email, 
	       mem.billing_account_id, mem.plan_id, mem.country_code, pm.product_line,
	       pm.master_product, comp.company_name, comp.company_country, comp.company_industry,
	       td.territory_name, bad.account_sales_territory
	FROM dimension_external_db.pib_membership_dimension mem
	LEFT JOIN dimension_external_db.pib_billing_account_dimension bad ON mem.billing_account_id = bad.cibs_billing_account_id 
	LEFT JOIN dimension_external_db.pib_company_dimension comp ON bad.salesforce_company_two = comp.company_sfdc_id
	LEFT JOIN reference_external_db.pib_product_dimension pm ON mem.plan_id = pm.access_code
	LEFT JOIN dimension_external_db.pib_territory_dimension td ON comp.company_territory = td.territory_sfdc_id
),

multiple_rpcs AS (
	SELECT ippubinfo_ip_code_value, COUNT(DISTINCT billingdist_royaltyprovider_code_value)
	FROM cntsrccurr 
	WHERE srcinfo_statuscode_code_value = 'ACT'
	GROUP BY 1
	HAVING COUNT(DISTINCT billingdist_royaltyprovider_code_value) >> 1
),

ipr as (
select cast(contract_id as integer) as contractid, status, input_provider_name as inputprovidername, country_of_origin as countryoforigin, territory, input_provider_code, publisher_relation_contact as publisherrelationcontact, vendor_number as vendornumber, vendor_name as vendorname, cast(contract_eff_date as varchar) as contracteffdate, cast(contract_term as varchar) as contractterm, cast(term_end_date as varchar) as termenddate, case when auto_renewal = True then 'True' else 'False' end as autorenewal, cast(renewal_term as varchar) as renewalterm, case when termination_delete_content = True then 'True' else 'False' end as terminationdeletecontent, cast(termination_delete_content_time_frame as varchar) as terminationdeletecontenttimeframe, cast(royalty_rate_for_ip as varchar) as royaltyrateforip, case when fixed_fee = True then 'True' else 'False' end as fixedfee, cast(fixed_fee_amount as varchar) as fixedfeeamount, fixed_fee_frequency as fixedfeefrequency, case when guaranteed_min = True then 'True' else 'False' end as guaranteedmin, cast(g_min_amount as varchar) as gminamount, g_min_frequency as gminfrequency, case when new_ad_notify = True then 'True' else 'False' end as newadnotify, case when new_ad_consent = True then 'True' else 'False' end as newadconsent, case when blocking = True then 'True' else 'False' end as blocking, case when extranet_distribution = True then 'True' else 'False' end as extranetdistribution, cast(factiva_storage as varchar) as factivastorage, case when third_party_storage = True then 'True' else 'False' end as thirdpartystorage, case when customer_headline_storage = True then 'True' else 'False' end as customerheadlinestorage, cast(customer_article_storage as varchar) as customerarticlestorage,	case when new_product_notify = True then 'True' else 'False' end as newproductnotify, case when new_product_consent = True then 'True' else 'False' end as newproductconsent, case when translation_rights = True then 'True' else 'False' end as translationrights, case when embargo = True then 'True' else 'False' end as embargo, case when expiry = True then 'True' else 'False' end as expiry, payment_notes as paymentnotes, commercial_stat_notes as commercialstatnotes
from dimension_external_db.ip_rights_data_current 
),

ip_right_data AS (
	SELECT ipr.*
	FROM ipr
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
)

SELECT cntsrccurr.srcinfo_code_value AS source_code,
	   cntsrccurr.ippubinfo_ip_code_value AS input_provider_code,
	   cntsrccurr.ippubinfo_ip_name AS ip_name,
	   cntsrccurr.billingdist_royaltyprovider_code_value,
	   CASE WHEN ippubinfo_ip_code_value LIKE '%NYT%' THEN billingdist_royaltyprovider_code_value 
			WHEN ippubinfo_ip_code_value IN ('NBITE','JOINS','TRINDY') THEN billingdist_royaltyprovider_code_value
			WHEN billingdist_royaltyprovider_code_value LIKE 'NLAMAL%' THEN 'NLAMAL'
			WHEN ippubinfo_ip_code_value = 'NEWSI' AND billingdist_billgroup_name LIKE '%Reach Plc%' THEN 'MGNLT'
			WHEN ippubinfo_ip_code_value = 'NEWSI' THEN billingdist_royaltyprovider_code_value
			WHEN ippubinfo_ip_code_value = 'REEDUS' AND billingdist_royaltyprovider_code_value <<>> 'REEDBA' THEN billingdist_royaltyprovider_code_value 
			WHEN billingdist_royaltyprovider_code_value IN ('GEDINN','FINN','VWDV','GEDIG','FOCUSO','STTRB',
										   'AEFENW','ABMFNI','') THEN billingdist_royaltyprovider_code_value
			WHEN ippubinfo_ip_code_value IN ('DJ','DJSEG','DJN','DJENT')	
				AND billingdist_royaltyprovider_code_value NOT LIKE 'DJ%' THEN billingdist_royaltyprovider_code_value
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
	   			AND ip.status LIKE '%Active%'
	   			AND ip_rpc.status LIKE '%Active%' THEN cntsrccurr.billingdist_royaltyprovider_code_value
   			WHEN ip.status LIKE '%Terminated%' 
   				AND ip_rpc.status LIKE '%Active%' THEN cntsrccurr.billingdist_royaltyprovider_code_value
   			WHEN (ip.input_provider_code IS NULL OR ip.input_provider_code = '')
   				AND ip_rpc.input_provider_code IS NOT NULL THEN cntsrccurr.billingdist_royaltyprovider_code_value
			ELSE ippubinfo_ip_code_value END AS input_provider_code_adj,
       year_month,
       company_mapping.billing_account_id,
       company_mapping.company_name,
       company_mapping.company_country,
       company_mapping.company_industry,
       company_mapping.account_sales_territory,
       cnt_mem.country_name AS user_country_mem,
       cnt_mem.region AS user_region_mem,
       cnt_ip.country_name AS user_country_ip,
       cnt_ip.region AS user_region_ip,
       SUM(omnit.article_views) article_views
FROM omnit
LEFT JOIN company_mapping ON omnit.post_evar3 = company_mapping.pib_member_id
LEFT JOIN reference_external_db.country_reference cnt_mem ON company_mapping.country_code = cnt_mem.edw_code 
LEFT JOIN reference_external_db.country_reference cnt_ip ON omnit.geo_country = cnt_ip.geo_country 
JOIN cntsrccurr ON omnit.Source_Code = cntsrccurr.srcinfo_code_value 
LEFT JOIN ip_right_data ip ON cntsrccurr.ippubinfo_ip_code_value = ip.input_provider_code 
LEFT JOIN ip_right_data ip_rpc ON cntsrccurr.billingdist_royaltyprovider_code_value = ip_rpc.input_provider_code 
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15
