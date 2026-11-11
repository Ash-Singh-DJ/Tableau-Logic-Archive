-- Dashboard   : "B2B BCG API Key Usage"  [B2B / B2B Sales / GAT]
-- Data source : "API Usage" (embedded in the workbook)
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
WITH platform_trace AS (
	SELECT 'Platform' AS api_type,
	       client_account_id,
	       client_user_id,transaction_resource_urn,
		   CASE WHEN transaction_resource_urn IN ('urn:preferenceapi:personalpreferences',
		   			'urn:preferenceapi:personalpreferences1') THEN 'PIB Personal Preferences'
		   		WHEN transaction_resource_urn IN ('urn:preferenceapi:grouppreferences') THEN 'PIB Group Preferences'
		   		WHEN transaction_resource_urn IN ('urn:pamapi:customsearchfields','urn:pamapi:articledisplayfields',
		   			'urn:pamapi:contentsearchhistory','urn:pamapi:expertsearches','urn:pamapi:expertsearchcategories',
		   			'urn:pamapi:contentsourcelist','urn:pamapi:organizationlist','urn:pamapi:savedsearches',
		   			'urn:pamapi:industrylist') 
		   			THEN 'Factiva Search Assets'
		   		WHEN transaction_resource_urn = 'urn:pamapi:instrumentlist' THEN 'Factiva Quote List'
		   		WHEN transaction_resource_urn IN ('urn:pamapi:searchsourcegroups') THEN 'PIB Preferences'
		   		WHEN transaction_resource_urn LIKE '%productsettings%' OR transaction_resource_urn LIKE '%settingsapi%'
		   			OR transaction_resource_urn LIKE '%product-settings%' THEN 'PIB Product Settings'
		   		WHEN transaction_resource_urn LIKE '%platformproxy%' THEN 'NA (Platform Proxy)'
		   		WHEN transaction_resource_urn LIKE '%urn:membershipusers%' THEN 'PIB User Management APIs'
		   		WHEN transaction_resource_urn LIKE '%urn:marketdataservicesapi:quotes%' THEN 'Platform Market Data Service'
		   		WHEN transaction_resource_urn LIKE '%urn:productsettingsapi%' THEN 'PIB Product Settings'
		   		WHEN transaction_resource_urn LIKE '%urn:riskentities:screening%' THEN 'R&C Risk Search'
		   		WHEN transaction_resource_urn LIKE '%urn:membershipauth%' 
		   			OR transaction_resource_urn LIKE '%urn:membership:api%' THEN 'PIB Authorization'
		   		WHEN transaction_resource_urn IN ('urn:sym2fesapi:taxonomy','urn:sym2fessoap:symbology',
		   			'urn:factiva-organizations:search','urn:factiva-people:search',
		   			'urn:reports:api') THEN 'Factiva Taxonomy'
		   		WHEN lower(transaction_resource_urn) IN ('search2_soap') THEN 'Factiva Homepage Perform Content Search'
		   		WHEN lower(transaction_resource_urn) IN ('rtsearch_soap') THEN 'Newsplus Get Linked Document'
		   		WHEN lower(transaction_resource_urn) IN ('freesearch_soap') THEN 'R&C FC Perform Content Search'
		   		WHEN lower(transaction_resource_urn) IN ('arch_get_pro','arch_get_article_2','arch_get_url_2',
		   			'arch_get_article_with_limit_2') THEN 'Factiva Content API Partner Integration'
		   		WHEN transaction_resource_urn = 'urn:archiveservice:api' THEN 'FDK Archive Service API'
		   		WHEN transaction_resource_urn = 'urn:newspagesservice:api' THEN 'Factiva Homepage Modules - Newspages'
		   		WHEN transaction_resource_urn = 'urn:allesseh' THEN 'Newswires Top Stories API'
		   		WHEN transaction_resource_urn = 'urn:fcpapi:screening' THEN 'Factiva C&E Screening'
		   		WHEN transaction_resource_urn = 'urn:dnbtreeapi:organizations' THEN 'Factiva C&E'
		   		WHEN transaction_resource_urn = 'urn:companyprofile2.0fessoap:screening' THEN 'Factiva C&E Profiles'
		   		WHEN transaction_resource_urn = 'urn:candeprofileapis' THEN 'Factiva C&E Profiles'
		   		WHEN transaction_resource_urn = 'urn:nwcalendar' THEN 'Newswires Dow Jones Calendar Live'
		   		WHEN lower(transaction_resource_urn) LIKE 'pam/%' AND lower(transaction_resource_urn) LIKE '%newsplus%'
		   			THEN 'Newsplus UI Usage and Navigation'
		   		WHEN lower(transaction_resource_urn) = 'urn:screeningcriteriaservice:api' THEN 'Factiva C&E Search Assets'
		   		WHEN lower(transaction_resource_urn) = 'urn:radarservice:api' THEN 'Factiva C&E Search Assets'
		   		WHEN transaction_resource_urn = 'urn:sym2fdkfessoap:symbology' THEN 'Factiva Taxonomy'
		   		WHEN transaction_resource_urn = 'urn:customerservice:api' THEN 'Internal PIB Customer Service Tool APIs'
		   		WHEN transaction_resource_urn IN ('urn:analyticsapi:assets:content-analytics-charts','urn:pamapi:charts')
		   			THEN 'Factiva Analytics (Content Charts)'
		   		WHEN transaction_resource_urn LIKE '%urn:membershipaccounts%' THEN 'Undefined (PIB Account Management APIs)'
		   		WHEN lower(transaction_resource_urn) = 'urn:recommenderservice:recommenderapi' THEN 'Undefined (Recommender API)'
		   		WHEN lower(transaction_resource_urn) LIKE 'msrvs_reg_%' THEN 'Undefined (Registration Service / User API)'
		   		WHEN lower(transaction_resource_urn) IN ('urn:tags:api','urn:tags-alerts:api') THEN 'Factiva Manage Alerts - Tags API'
		   		WHEN lower(transaction_resource_urn) LIKE 'mds_get_%' THEN 'Undefined (Market Data Service API)'
		   		WHEN transaction_resource_urn LIKE 'urn:membershipgroups%' THEN 'Internal PIB Group Management API'
		   		WHEN transaction_resource_urn = 'urn:signals:api' THEN 'Factiva Signals'
		   		WHEN transaction_resource_urn = 'urn:news-screening' THEN 'R&C Screening & Monitoring News API'
		   		WHEN transaction_resource_urn LIKE 'urn:membershipclientcodes%' THEN 'Undefined (Internal PIB Client Code Management)'
		   		WHEN transaction_resource_urn = 'urn:newssearch:api' THEN 'New Factiva News Search'
		   		WHEN transaction_resource_urn LIKE 'urn:factiva:assets:screening%' THEN 'Undefined (Factiva Assets Screening)'
		   		WHEN transaction_resource_urn = 'urn:realtimesearch:api' THEN 'Newswires Real-time API Search'
		   		WHEN transaction_resource_urn = 'urn:relevancy' THEN 'Newswires Portfolio News'
		   		WHEN transaction_resource_urn = 'urn:newslettersservice:api' THEN 'Factiva Newsletter Assets'
		   		WHEN transaction_resource_urn = 'urn:redi:healthcheck' THEN 'Undefined (Redi Healthcheck)'
		   		WHEN transaction_resource_urn = 'urn:nwsnlmesh' THEN 'Newswires Newsletters'
		   		WHEN transaction_resource_urn = 'urn:linkedarticleapi:api' THEN 'Newswires Real-time Content API (Linked Article Reference)'
		   		WHEN transaction_resource_urn = 'urn:nwsnl' THEN 'Newswires Newsletters'
		   		WHEN transaction_resource_urn LIKE 'urn:randc-batch-screening%' THEN 'R&C Screening & Monitoring (Batch Screening)'
		   		WHEN transaction_resource_urn = 'urn:workspacesservice:api' THEN 'Factiva Workspace Assets'
		   		WHEN transaction_resource_urn = 'urn:newsstand-content:api' THEN 'Factiva Homepage Modules - Newsstand'
		   		-- UBO API
		   		WHEN lower(transaction_resource_urn) IN ('urn:riskentities:ubo','urn:randc-ubo') THEN 'R&C UBO API'
		   		ELSE 'Other Undefined PTM API' END AS api_name,
		   		null as tls_version,
		   		
		   SUBSTRING(CAST(cycle_date AS varchar),1,7) AS year_month,
           -- UPDATED: Correct Counting Method
		   COUNT(DISTINCT request_headers_x_dj_transaction_id) transactions
	FROM pib_event_data.pib_platform_trace 
	WHERE cycle_date >>= DATE('2021-11-01')
		AND transaction_resource_urn IS NOT NULL 
		AND transaction_status_code = 200
		--and client_account_id in('9BOS005200')
		and client_account_id in('9BOS000500','9BOS004300','9BOS004700','9BOS005200')
		--AND cycle_date >>= DATE_ADD('day', -1, DATE_TRUNC('month', DATE_ADD('month', -12, CURRENT_DATE)))
        -- UPDATED: Apigee Filter and Generic Proxy Filter
        AND event_source <<>> 'in_web_apigee'
        AND lower(transaction_resource_target) NOT LIKE '%/genericproxy%'
	GROUP BY 1, 2, 3, 4, 5, 6,7
),

platform_trace_private AS (
	SELECT 'Platform' AS api_type,
	       client_account_id,
	       client_user_id,transaction_resource_urn,
		   CASE WHEN transaction_resource_urn = 'urn:riskentities:screening' 
		   			AND transaction_resource_target LIKE '%/taxonomy%' THEN 'R&C Risk Search Taxonomy'
				WHEN (transaction_resource_urn = 'urn:riskentities:screening' or transaction_resource_urn = 'urn:randc-search') 
		   			AND transaction_resource_target LIKE '%/search%' THEN 'R&C Ad Hoc Search API 2.0'
                -- UPDATED: LIKE Fix for Batch Screening
		   		WHEN transaction_resource_urn LIKE 'urn:randc-batch-screening%' 
		   			THEN 'R&C Screening & Monitoring (Batch Screening)'
		   		WHEN transaction_resource_urn = 'urn:riskentities:ubo' THEN 'R&C UBO'
		   		WHEN transaction_resource_urn = 'urn:randcprofileretrievalapis' THEN 'R&C Profile Retrieval API'
		   		WHEN transaction_resource_urn = 'urn:tradecomplianceapis' THEN 'R&C Trade Compliance'
		   		WHEN transaction_resource_urn = 'urn:riskentities:audit' THEN 'R&C Audit Trails'
		   		WHEN lower(transaction_resource_urn) IN ('urn:riskentities:ubo','urn:randc-ubo') THEN 'R&C UBO API'
		   ELSE 'Other Undefined PTM API' END AS api_name, 
		    null as tls_version,
		   SUBSTRING(CAST(cycle_date AS varchar),1,7) AS year_month,
           -- UPDATED: Correct Counting Method
		   COUNT(DISTINCT request_headers_x_dj_transaction_id) transactions
	FROM pib_event_data.pib_platform_trace_private_user 
	WHERE cycle_date >>= DATE('2021-11-01')
		AND transaction_resource_urn IS NOT NULL 
		AND transaction_status_code = 200
		--and client_account_id in('9BOS005200')
		and client_account_id in('9BOS000500','9BOS004300','9BOS004700','9BOS005200')
		--AND cycle_date >>= DATE_ADD('day', -1, DATE_TRUNC('month', DATE_ADD('month', -12, CURRENT_DATE)))
        -- UPDATED: Generic Proxy Filter
        AND lower(transaction_resource_target) NOT LIKE '%/genericproxy%'
	GROUP BY 1, 2, 3, 4, 5, 6,7
),

factiva_legacy_api AS (
	SELECT 'Factiva Legacy API' AS api_type,
		   data__client__account_id AS client_account_id,
		   data__client__user_id AS client_user_id, data__transaction__resource_target as transaction_resource_urn,
		   CASE WHEN lower(data__transaction__resource_target) LIKE '%marketdata%'
					AND lower(data__transaction__resource_target) LIKE '%2.0%' THEN 'Factiva REST 2 Market Data Service'
				WHEN lower(data__transaction__resource_target) LIKE '%marketdata%'
					AND lower(data__transaction__resource_target) LIKE '%1.0%' THEN 'Factiva REST 1 Market Data Service'	
				WHEN lower(data__transaction__resource_target) LIKE '%membership.asmx%' THEN 'FDK Membership Service'
				WHEN lower(data__transaction__resource_target) LIKE '%retrieval.asmx%' THEN 'FDK Retrieval Service'
				WHEN lower(data__transaction__resource_target) LIKE '%collection%'
					AND lower(data__transaction__resource_target) LIKE '%2.0%' THEN 'Factiva REST 2 Collection Service'
				WHEN lower(data__transaction__resource_target) LIKE '%collection%'
					AND lower(data__transaction__resource_target) LIKE '%1.0%' THEN 'Factiva REST 1 Collection Service'	
				WHEN lower(data__transaction__resource_target) LIKE '%search.asmx%' THEN 'FDK Search Service'
				WHEN lower(data__transaction__resource_target) LIKE '%companyprofile.asmx%' THEN  'FDK Companies, Industries & Executives Service'
				WHEN lower(data__transaction__resource_target) LIKE '%registration.asmx%' THEN 'FDK Registration Service'
				WHEN lower(data__transaction__resource_target) LIKE '%session%'
					AND lower(data__transaction__resource_target) LIKE '%2.0%' THEN 'Factiva REST 2 Session Service'
				WHEN lower(data__transaction__resource_target) LIKE '%session%'
					AND lower(data__transaction__resource_target) LIKE '%1.0%' THEN 'Factiva REST 1 Session Service'
				WHEN lower(data__transaction__resource_target) LIKE '%content%'
					AND lower(data__transaction__resource_target) LIKE '%2.0%' THEN 'Factiva REST 2 Content Service'
				WHEN lower(data__transaction__resource_target) LIKE '%content%'
					AND lower(data__transaction__resource_target) LIKE '%1.0%' THEN 'Factiva REST 1 Content Service'
				WHEN lower(data__transaction__resource_target) LIKE '%newsstand%'
					AND lower(data__transaction__resource_target) LIKE '%2.0%' THEN 'Factiva REST 2 Newsstand Service'
				WHEN lower(data__transaction__resource_target) LIKE '%newsstand%'
					AND lower(data__transaction__resource_target) LIKE '%1.0%' THEN 'Factiva REST 1 Newsstand Service'
				WHEN lower(data__transaction__resource_target) LIKE '%realtimeheadlines%'
					AND lower(data__transaction__resource_target) LIKE '%2.0%' THEN 'Factiva REST 2 Real Time Headlines Service'
				WHEN lower(data__transaction__resource_target) LIKE '%realtimeheadlines%'
					AND lower(data__transaction__resource_target) LIKE '%1.0%' THEN 'Factiva REST 1 Real Time Headlines Service'
				WHEN lower(data__transaction__resource_target) LIKE '%taxonomy%'
					AND lower(data__transaction__resource_target) LIKE '%2.0%' THEN 'Factiva REST 2 Taxonomy Service'
				WHEN lower(data__transaction__resource_target) LIKE '%taxonomy%'
					AND lower(data__transaction__resource_target) LIKE '%1.0%' THEN 'Factiva REST 1 Taxonomy Service'
				WHEN lower(data__transaction__resource_target) LIKE '%alert%'
					AND lower(data__transaction__resource_target) LIKE '%2.0%' THEN 'Factiva REST 2 Alert Service'
				WHEN lower(data__transaction__resource_target) LIKE '%alert%'
					AND lower(data__transaction__resource_target) LIKE '%1.0%' THEN 'Factiva REST 1 Alert Service'
				WHEN lower(data__transaction__resource_target) LIKE '%company%'
					AND lower(data__transaction__resource_target) LIKE '%2.0%' THEN 'Factiva REST 2 Company Service'
				WHEN lower(data__transaction__resource_target) LIKE '%company%'
					AND lower(data__transaction__resource_target) LIKE '%1.0%' THEN 'Factiva REST 1 Company Service'
				WHEN lower(data__transaction__resource_target) LIKE '%events%'
					AND lower(data__transaction__resource_target) LIKE '%2.0%' THEN 'Factiva REST 2 Events Service'
				WHEN lower(data__transaction__resource_target) LIKE '%events%'
					AND lower(data__transaction__resource_target) LIKE '%1.0%' THEN 'Factiva REST 1 Events Service'
				WHEN lower(data__transaction__resource_target) LIKE '%signal%'
					AND lower(data__transaction__resource_target) LIKE '%2.0%' THEN 'Factiva REST 2 Signal Service'
				WHEN lower(data__transaction__resource_target) LIKE '%signal%'
					AND lower(data__transaction__resource_target) LIKE '%1.0%' THEN 'Factiva REST 1 Signal Service'
				WHEN lower(data__transaction__resource_target) LIKE '%user%'
					AND lower(data__transaction__resource_target) LIKE '%2.0%' THEN 'Factiva REST 2 User Service'
				WHEN lower(data__transaction__resource_target) LIKE '%user%'
					AND lower(data__transaction__resource_target) LIKE '%1.0%' THEN 'Factiva REST 1 User Service'
				WHEN lower(data__transaction__resource_target) LIKE '%executives%'
					AND lower(data__transaction__resource_target) LIKE '%2.0%' THEN 'Factiva REST 2 Executives Service'
				WHEN lower(data__transaction__resource_target) LIKE '%executives%'
					AND lower(data__transaction__resource_target) LIKE '%1.0%' THEN 'Factiva REST 1 Executives Service'
				WHEN lower(data__transaction__resource_target) LIKE '%code%'
					AND lower(data__transaction__resource_target) LIKE '%2.0%' THEN 'Factiva REST 2 Code Service'
				WHEN lower(data__transaction__resource_target) LIKE '%code%'
					AND lower(data__transaction__resource_target) LIKE '%1.0%' THEN 'Factiva REST 1 Code Service'
				WHEN lower(data__transaction__resource_target) LIKE '%newsradar%'
					AND lower(data__transaction__resource_target) LIKE '%2.0%' THEN 'Factiva REST 2 News Radar Service'
				WHEN lower(data__transaction__resource_target) LIKE '%newsradar%'
					AND lower(data__transaction__resource_target) LIKE '%1.0%' THEN 'Factiva REST 1 News Radar Service'
				WHEN lower(data__transaction__resource_target) LIKE '%industries%'
					AND lower(data__transaction__resource_target) LIKE '%2.0%' THEN 'Factiva REST 2 Industry Service'
				WHEN lower(data__transaction__resource_target) LIKE '%industries%'
					AND lower(data__transaction__resource_target) LIKE '%1.0%' THEN 'Factiva REST 1 Industry Service'
				WHEN lower(data__transaction__resource_target) LIKE '%list%'
					AND lower(data__transaction__resource_target) LIKE '%2.0%' THEN 'Factiva REST 2 List Service'
				WHEN lower(data__transaction__resource_target) LIKE '%list%'
					AND lower(data__transaction__resource_target) LIKE '%1.0%' THEN 'Factiva REST 1 List Service'
				WHEN lower(data__transaction__resource_target) LIKE '%author%'
					AND lower(data__transaction__resource_target) LIKE '%2.0%' THEN 'Factiva REST 2 Author Service'
				WHEN lower(data__transaction__resource_target) LIKE '%author%'
					AND lower(data__transaction__resource_target) LIKE '%1.0%' THEN 'Factiva REST 1 Author Service'
				WHEN lower(data__transaction__resource_target) LIKE '%suggest%'
					AND lower(data__transaction__resource_target) LIKE '%2.0%' THEN 'Factiva REST 2 Suggest Service'
				WHEN lower(data__transaction__resource_target) LIKE '%suggest%'
					AND lower(data__transaction__resource_target) LIKE '%1.0%' THEN 'Factiva REST 1 Suggest Service'
				WHEN lower(data__transaction__resource_target) LIKE '%heatmap%'
					AND lower(data__transaction__resource_target) LIKE '%2.0%' THEN 'Factiva REST 2 Heat Map Service'
				WHEN lower(data__transaction__resource_target) LIKE '%heatmap%'
					AND lower(data__transaction__resource_target) LIKE '%1.0%' THEN 'Factiva REST 1 Heat Map Service'
				WHEN lower(data__transaction__resource_target) LIKE '%taxonomy.asmx%' THEN 'FDK Taxonomy Service'
				WHEN lower(data__transaction__resource_target) LIKE '%marketdata.asmx%' THEN 'FDK Market Data Service'
				WHEN lower(data__transaction__resource_target) LIKE '%newsstand.asmx%' THEN 'FDK Newsstand Service'
							WHEN lower(data__transaction__resource_target) LIKE '%track.asmx%' THEN 'FDK Track Service'
				WHEN lower(data__transaction__resource_target) LIKE '%entitlement%'
					AND lower(data__transaction__resource_target) LIKE '%2.0%' THEN 'Factiva REST 2 Entitlement Service'
				WHEN lower(data__transaction__resource_target) LIKE '%entitlement%'
					AND lower(data__transaction__resource_target) LIKE '%1.0%' THEN 'Factiva REST 1 Entitlement Service'
				WHEN lower(data__transaction__resource_target) LIKE '%historicaldata.asmx%' THEN 'FDK Historical Data Service'
				WHEN lower(data__transaction__resource_target) LIKE '%savedinfo.asmx%' THEN 'FDK Saved Info Service'
				WHEN lower(data__transaction__resource_target) LIKE '%proxy%'
					AND lower(data__transaction__resource_target) LIKE '%2.0%' THEN 'Factiva REST 2 Proxy Service'
				WHEN lower(data__transaction__resource_target) LIKE '%proxy%'
					AND lower(data__transaction__resource_target) LIKE '%1.0%' THEN 'Factiva REST 1 Proxy Service'
				WHEN lower(data__transaction__resource_target) LIKE '%trigger%'
					AND lower(data__transaction__resource_target) LIKE '%2.0%' THEN 'Factiva REST 2 Trigger Service'
				WHEN lower(data__transaction__resource_target) LIKE '%trigger%'
					AND lower(data__transaction__resource_target) LIKE '%1.0%' THEN 'Factiva REST 1 Trigger Service'
				WHEN lower(data__transaction__resource_target) LIKE '%topstories%'
					AND lower(data__transaction__resource_target) LIKE '%2.0%' THEN 'Factiva REST 2 Top Stories Service'
				WHEN lower(data__transaction__resource_target) LIKE '%topstories%'
					AND lower(data__transaction__resource_target) LIKE '%1.0%' THEN 'Factiva REST 1 Top Stories Service'
				WHEN lower(data__transaction__resource_target) LIKE '%chart%'
					AND lower(data__transaction__resource_target) LIKE '%2.0%' THEN 'Factiva REST 2 Chart Service'
				WHEN lower(data__transaction__resource_target) LIKE '%chart%'
					AND lower(data__transaction__resource_target) LIKE '%1.0%' THEN 'Factiva REST 1 Chart Service'
				WHEN lower(data__transaction__resource_target) LIKE '%workspaces%'
					AND lower(data__transaction__resource_target) LIKE '%2.0%' THEN 'Factiva REST 2 Workspaces Service'
				WHEN lower(data__transaction__resource_target) LIKE '%workspaces%'
					AND lower(data__transaction__resource_target) LIKE '%1.0%' THEN 'Factiva REST 1 Workspaces Service'
				WHEN lower(data__transaction__resource_target) LIKE '%newsletter%'
					AND lower(data__transaction__resource_target) LIKE '%2.0%' THEN 'Factiva REST 2 Newsletter Service'
				WHEN lower(data__transaction__resource_target) LIKE '%newsletter%'
					AND lower(data__transaction__resource_target) LIKE '%1.0%' THEN 'Factiva REST 1 Newsletter Service'
				WHEN lower(data__transaction__resource_target) LIKE '%managedlists%'
					AND lower(data__transaction__resource_target) LIKE '%2.0%' THEN 'Factiva REST 2 Managed Lists Service'
				WHEN lower(data__transaction__resource_target) LIKE '%managedlists%'
					AND lower(data__transaction__resource_target) LIKE '%1.0%' THEN 'Factiva REST 1 Managed Lists Service'
				ELSE 'Other Undefined Factiva Legacy API' END AS api_name,
				data__client__tls_version as tls_version,
	   SUBSTRING(CAST(cycle_date AS varchar),1,7) AS year_month,
	   COUNT(DISTINCT id) transactions
	FROM pib_event_data.pib_legacy_api 
	WHERE cycle_date >>= DATE('2021-11-01')
		AND data__transaction__status_code = 200
		--and data__client__account_id in('9BOS005200')
		and data__client__account_id in('9BOS000500','9BOS004300','9BOS004700','9BOS005200')
		--AND cycle_date >>= DATE_ADD('day', -1, DATE_TRUNC('month', DATE_ADD('month', -12, CURRENT_DATE)))
	GROUP BY 1, 2, 3, 4, 5, 6,7
),

rc_legacy_api AS (
	SELECT 'R&C Legacy API' AS api_type,
		   account_id AS client_account_id,
		   'unknown' AS user_id,
		   'unknown' as transaction_resource_urn,
		   'R&C Legacy API' AS api_name,
		   null as tls_version,
		   SUBSTRING(CAST(period AS varchar),1,7) AS year_month,
		   SUM(requests) AS transactions
	FROM google_sheets_db.rc_legacy_api_usage_unpivot 
	WHERE period >>= DATE('2021-11-01')
		--and account_id in('9BOS005200')
		and account_id in('9BOS000500','9BOS004300','9BOS004700','9BOS005200')
		--AND period >>= DATE_ADD('day', -1, DATE_TRUNC('month', DATE_ADD('month', -12, CURRENT_DATE)))
	GROUP BY 1, 2, 3, 4, 5, 6,7
)

SELECT api_usage.*,
	   bad.sales_person AS ba_sales_person,
	   bad.account_sales_territory AS ba_territory_name,
	   bad.account_sales_region AS ba_territory_region,
	   comp.company_name,
       comp.company_sfdc_id,
	   td.territory_name,
	   grr.geo_region,
	   ud.user_full_name AS account_owner,
	   rsdud.user_full_name AS rsd,
	   cnt.country_name AS user_country,
	   cnt.region AS user_region,
	   mem.email as email,
	   mem.first_name as first_name,
	   mem.last_name as last_name
FROM (
	SELECT *
	FROM platform_trace 
	UNION ALL 
	SELECT * FROM platform_trace_private
	UNION ALL 
	SELECT *
	FROM factiva_legacy_api
	UNION ALL
	SELECT *
	FROM rc_legacy_api
) api_usage
LEFT JOIN dimension_external_db.pib_billing_account_dimension bad ON api_usage.client_account_id = bad.cibs_billing_account_id 
LEFT JOIN (SELECT * FROM dimension_external_db.pib_company_dimension WHERE status_flag <<>> 'DELETE') comp ON bad.salesforce_company_two = comp.company_sfdc_id 
LEFT JOIN (SELECT * FROM dimension_external_db.pib_territory_dimension WHERE status_flag <<>> 'DELETE') td ON comp.company_territory = td.territory_sfdc_id 
LEFT JOIN (SELECT * FROM dimension_external_db.pib_user_dimension WHERE status_flag <<>> 'DELETE') ud ON comp.owner_id = ud.user_sfdc_id
LEFT JOIN sandbox_mk.geo_region_rollup grr ON td.territory_name = grr.sales_territory
LEFT JOIN (SELECT * FROM dimension_external_db.pib_user_dimension WHERE status_flag <<>> 'DELETE') rsdud ON td.regional_sales_director = rsdud.user_sfdc_id
LEFT JOIN dimension_external_db.pib_membership_dimension mem ON (api_usage.client_account_id = mem.billing_account_id AND api_usage.client_user_id = mem.user_id)
LEFT JOIN reference_external_db.country_reference cnt ON mem.country_code = cnt.edw_code
