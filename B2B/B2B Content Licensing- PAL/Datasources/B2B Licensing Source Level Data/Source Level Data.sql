-- Published data source : "B2B Licensing Source Level Data"  [B2B / B2B Content Licensing- PAL / Datasources]
-- Relation    : Custom SQL "Source Level Data"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
WITH source_usage_rnc_users AS (
	SELECT CASE WHEN STRPOS(post_prop8,'_') = 0 THEN UPPER(post_prop8) ELSE UPPER(SUBSTRING(post_prop8,1,STRPOS(post_prop8,'_')-1)) END source_code,
	       SUM(CASE WHEN (post_evar4 = 'Fact_ART_ArticleView' or post_prop3 = 'ARTICLE' or lower(post_pagename) like '%article%') 
	       				AND CAST(post_page_event AS varchar) = '0' AND (CAST(exclude_hit AS INTEGER) <<= 0 
	       				AND CAST(hit_source AS varchar) NOT IN ('5', '8', '9'))
	                  THEN 1 ELSE 0 END) article_views,
	       SUM(CASE WHEN pd.bu = 'R&C' 
	       				AND (post_evar4 = 'Fact_ART_ArticleView' or post_prop3 = 'ARTICLE' or lower(post_pagename) like '%article%') 
	       				AND CAST(post_page_event AS varchar) = '0' AND (CAST(exclude_hit AS INTEGER) <<= 0 
	       				AND CAST(hit_source AS varchar) NOT IN ('5', '8', '9'))
	                  THEN 1 ELSE 0 END) rnc_article_views
	FROM fact_external_db.omniture_event_fact omnit
	INNER JOIN dimension_external_db.pib_membership_dimension mem ON omnit.post_evar3 = mem.pib_member_id 
	LEFT JOIN reference_external_db.pib_product_dimension pd ON mem.plan_id = pd.access_code 
	WHERE reporting_suite = 'djfactiva'
		AND cycle_date >>= DATE_ADD('day', -1, DATE_TRUNC('month', DATE_ADD('month', -12, CURRENT_DATE)))
		AND cycle_date <<= DATE_ADD('day', -1, DATE_TRUNC('month', CURRENT_DATE))
	GROUP BY 1
),

rc_article_headlines AS (
	SELECT ti_td_article_headline, 
		   REVERSE(SUBSTRING(ti_td_article_headline, 1, 8)) AS an_reduced, 
		   COUNT(*) article_views
	FROM pib_event_data.pib_product_metrics djmet 
	WHERE (product = 'Financial Crime' OR product = 'RiskCenter' OR product_code = 'DJRCFC')
		AND ti_td_page_content_type = 'Article'
		AND ti_td_article_headline NOT LIKE '%drn:archive.newsarticle%'
		AND cycle_date >>= DATE_ADD('day', -1, DATE_TRUNC('month', DATE_ADD('month', -12, CURRENT_DATE)))
		AND cycle_date <<= DATE_ADD('day', -1, DATE_TRUNC('month', CURRENT_DATE))
	GROUP BY 1, 2
	ORDER BY article_views DESC
),

financial_crime_source_usg AS (
	SELECT UPPER(REVERSE(REGEXP_REPLACE(an_reduced,'^0+(?!$)'))) AS source_code,
		   SUM(article_views) AS article_views
	FROM rc_article_headlines
	GROUP BY 1
),

cntsrccurr as (
select srcinfo_code_value as SourceCode, docdata_sourcetype_value, srcinfo_sourcename, srcinfo_langn, srcinfo_statuscode_code_value, ippubinfo_publisher_code_value as ippubinfo_ip_code_value, ippubinfo_ip_name, billingdist_royaltyprovider_code_value, billingdist_billgroup_code_value, billingdist_billgroup_name, srcinfo_articletypen as article_coverage, srcinfo_coverage_value, srcinfo_firstissuedate_value, srcinfo_onlinedate_value, coalesce(cast(srcinfo_maxlag_value as int),0) max_lag, coalesce(cast(srcinfo_minlag_value as int),0) min_lag, srcinfo_nomlagn, ippubinfo_srcrightstype_code_value, billingdist_embargohours_value, billingdist_embargodays_value, billingdist_expirationhours_value, billingdist_expirationdays_value, ippubinfo_srcprimarytype_description, srcinfo_srcpriority_value, ippubinfo_allowtranslation_value, srcinfo_description as Description
from dimension_external_db.cdb_source_docs_current 
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26
order by 1
),

industry_1 AS (
  SELECT SourceCode,
         CASE WHEN lower(Description) LIKE '%bitcoin%' 
                OR lower(Description) LIKE '%cardano%'
                OR lower(Description) LIKE '%cryptocurrenc%'
                OR lower(Description) LIKE '%crypto-currenc%'
                OR Description LIKE '%DASH %'
                OR lower(Description) LIKE '%digital currency%'
                OR lower(Description) LIKE '%digital money%'
                OR lower(Description) LIKE '%dogecoin%'
                OR lower(Description) LIKE '%electronic currency%'
                OR lower(Description) LIKE '%eos%'
                OR lower(Description) LIKE '%ethereum%'
                OR Description LIKE '%IOTA %'
                OR lower(Description) LIKE '%litecoin%'
                OR lower(Description) LIKE '%monero%'
                OR lower(Description) LIKE '%namecoin%'
                OR lower(Description) LIKE '%online currency%'
                OR lower(Description) LIKE '%peercoin%'
                OR lower(Description) LIKE '%ppcoin%'
                OR lower(Description) LIKE '%primecoin%'
                OR lower(Description) LIKE '%pseudocurrenc%'
                OR lower(Description) LIKE '%pseudo-currenc%'
                OR Description LIKE '%Qtum%'
                OR lower(Description) LIKE '%ripple%'
                OR lower(Description) LIKE '%tezos%'
                OR Description LIKE '%Ven %'
                OR lower(Description) LIKE '%virtual money%'
                OR Description LIKE '%XRP %'
                OR lower(Description) LIKE '%zcash%'
              THEN 'Cryptocurrency/Bitcoin' ELSE NULL END IndustryName 
  FROM cntsrccurr),
  
industry_2 AS (
  SELECT SourceCode,
         CASE WHEN lower(Description) LIKE '%cyber security%' 
                OR lower(Description) LIKE '%information security%'
                OR lower(Description) LIKE '%infosec%'
                OR lower(Description) LIKE '%cyber defense%'
                OR lower(Description) LIKE '%internet safety%'
                OR lower(Description) LIKE '%data protection%'
                OR lower(Description) LIKE '%data security%'
                OR lower(Description) LIKE '%privacy software%'
                OR lower(Description) LIKE '%anti-virus software%'
                OR lower(Description) LIKE '%cybersecurity%'
                OR lower(Description) LIKE '%digital security tools%'
                OR lower(Description) LIKE '%encryption programs%'
                OR lower(Description) LIKE '%security management solutions%'
                OR lower(Description) LIKE '%security software%'
                OR lower(Description) LIKE '%threat detection systems%'
                OR lower(Description) LIKE '%threat management%'
                OR lower(Description) LIKE '%threat protection systems%'
              THEN 'Cybersecurity' ELSE NULL END IndustryName 
  FROM cntsrccurr),
  
industry_3 AS (
  SELECT SourceCode,
         CASE WHEN lower(Description) LIKE '%apprenticeship%' 
                OR lower(Description) LIKE '%learning%'
                OR lower(Description) LIKE '%college%'
                OR lower(Description) LIKE '%training%'
                OR lower(Description) LIKE '%school%'
                OR lower(Description) LIKE '%course%'
                OR lower(Description) LIKE '%education%'
                OR lower(Description) LIKE '%universit%'
                OR lower(Description) LIKE '%classroom%'
                OR lower(Description) LIKE '%management program%'
                OR lower(Description) LIKE '%edtech%'
                OR lower(Description) LIKE '%edutech%'
                OR lower(Description) LIKE '%instruction%'
                OR lower(Description) LIKE '%classes%'
                OR lower(Description) LIKE '%lessons%'
                OR lower(Description) LIKE '%tuition%'
                OR lower(Description) LIKE '%tutors%'
              THEN 'Education' ELSE NULL END IndustryName 
  FROM cntsrccurr),

industry_4 AS (
  SELECT SourceCode,
         CASE WHEN lower(Description) LIKE '%environment%' 
                OR lower(Description) LIKE '% esg %'
                OR lower(Description) LIKE 'esg %'
                OR lower(Description) LIKE '%green business%'
                OR lower(Description) LIKE '%green initiatives%'
                OR lower(Description) LIKE '%sustainability efforts%'
                OR lower(Description) LIKE '%sustainable business%'
                OR lower(Description) LIKE '%emission%'
                OR lower(Description) LIKE '%carbon footprint%'
                OR lower(Description) LIKE '%co2 reduction%'
                OR lower(Description) LIKE '%greenhouse gas%'
                OR lower(Description) LIKE '%eco-friendly%'
                OR lower(Description) LIKE '%green brands%'
                OR lower(Description) LIKE '%green products%'
                OR lower(Description) LIKE '%sustainable products%'
                OR lower(Description) LIKE '%corporate social responsibility%'
                OR lower(Description) LIKE '%corporate citizenship%'
                OR lower(Description) LIKE '%green investing%'
                OR lower(Description) LIKE '%responsible investing%'
                OR lower(Description) LIKE '%social investing%'
                OR lower(Description) LIKE '%socially conscious investing%'
                OR lower(Description) LIKE '%socially responsible investing%'
                OR lower(Description) LIKE '%sustainable investing%'
                OR lower(Description) LIKE '%sustainable production%'
                OR lower(Description) LIKE '%air quality%'
                OR lower(Description) LIKE '%energy management%'
                OR lower(Description) LIKE '%water management%'
                OR lower(Description) LIKE '%waste management%'
                OR lower(Description) LIKE '%hazardous materials management%'
                OR lower(Description) LIKE '%ecological impact%'
                OR lower(Description) LIKE '%human rights%'
                OR lower(Description) LIKE '%community relation%'
                OR lower(Description) LIKE '%customer privacy%'
                OR lower(Description) LIKE '%data security%'
                OR lower(Description) LIKE '%access & affordab%'
                OR lower(Description) LIKE '%access and affordab%'
                OR lower(Description) LIKE '%product quality and safety%'
                OR lower(Description) LIKE '%product quality & safety%'
                OR lower(Description) LIKE '%customer welfare%'
                OR lower(Description) LIKE '%selling practice%'
                OR lower(Description) LIKE '%product labeling%'
                OR lower(Description) LIKE '%labor practice%'
                OR lower(Description) LIKE '%employee health%'
                OR lower(Description) LIKE '%employee safety%'
                OR lower(Description) LIKE '%employee engagement%'
                OR lower(Description) LIKE '%employee diversity%'
                OR lower(Description) LIKE '%employee inclusion%'
                OR lower(Description) LIKE '%business model resilien%'
                OR lower(Description) LIKE '%supply chain manag%'
                OR lower(Description) LIKE '%materials sourcing%'
                OR lower(Description) LIKE '%material sourcing%'
                OR lower(Description) LIKE '%material efficiency%'
                OR lower(Description) LIKE '%materials efficiency%'
                OR lower(Description) LIKE '%climate change%'
                OR lower(Description) LIKE '%business ethic%'
                OR lower(Description) LIKE '%competitive behavior%'
                OR lower(Description) LIKE '%management of the legal & regulatory environment%'
                OR lower(Description) LIKE '%management of the legal and regulatory environment%'
                OR lower(Description) LIKE '%critical incident risk manage%'
                OR lower(Description) LIKE '%systemic risk manage%'
                OR lower(Description) LIKE '%renewable energ%'
                OR lower(Description) LIKE '%green bond%'
                OR lower(Description) LIKE '%executive compensation%'
                OR lower(Description) LIKE '%class action%'
                OR lower(Description) LIKE '%consumer protection%'
                OR lower(Description) LIKE '%product issues%'
                OR lower(Description) LIKE '%product recall%'
                OR lower(Description) LIKE '%labor dispute%'
              THEN 'ESG' ELSE NULL END IndustryName 
  FROM cntsrccurr),
  
industry_5 AS (
  SELECT SourceCode,
         CASE WHEN lower(Description) LIKE '%mineral extraction%' 
                OR lower(Description) LIKE '%metallurgical transformation%'
                OR lower(Description) LIKE '%exploitation of minerals%'
                OR lower(Description) LIKE '%natural resource extraction%'
                OR lower(Description) LIKE '%ore mining%'
                OR lower(Description) LIKE '%mineral production%'
                OR lower(Description) LIKE '%mineral processing%'
                OR lower(Description) LIKE '%ore processing%'
                OR lower(Description) LIKE '%extracting minerals%'
                OR lower(Description) LIKE '%mineral dressing%'
                OR lower(Description) LIKE '%ore dressing%'
                OR lower(Description) LIKE '%metal extraction%'
                OR lower(Description) LIKE '%oil extraction%'
                OR lower(Description) LIKE '%gas extraction%'
                OR lower(Description) LIKE '%petroleum%'
                OR lower(Description) LIKE '%natural gas%'
                OR lower(Description) LIKE '%well drilling%'
                OR lower(Description) LIKE '%hydraulic fracturing%'
                OR lower(Description) LIKE '%rendering%'
                OR lower(Description) LIKE '%gas production%'
                OR lower(Description) LIKE '%mechanical pressing%'
                OR lower(Description) LIKE '%volatile solvents extracting%'
                OR lower(Description) LIKE '%fracking%'
              THEN 'Extraction' ELSE NULL END IndustryName 
  FROM cntsrccurr),
  
industry_6 AS (
  SELECT SourceCode,
         CASE WHEN lower(Description) LIKE '%employment screening%' 
                OR lower(Description) LIKE '%human resource%'
                OR lower(Description) LIKE '% hr %'
                OR lower(Description) LIKE 'hr %'
                OR lower(Description) LIKE '%employment service%'
                OR lower(Description) LIKE '%executive search%'
                OR lower(Description) LIKE '%recruitment agenc%'
                OR lower(Description) LIKE '%talent management%'
                OR lower(Description) LIKE '%career planning%'
                OR lower(Description) LIKE '%career development%'
                OR lower(Description) LIKE '%health and safety at work%'
                OR lower(Description) LIKE '%safety at work%'
                OR Description LIKE '%DEI%'
                OR lower(Description) LIKE '%diversity, equity, inclusion%'
                OR lower(Description) LIKE '%divesity equity inclusion%'
                OR lower(Description) LIKE '%divesity equity & inclusion%'
                OR lower(Description) LIKE '%divesity equity and inclusion%'
                OR lower(Description) LIKE '%diversity, equity, and inclusion%'
                OR lower(Description) LIKE '%diversity, equity and inclusion%'
                OR lower(Description) LIKE '%diversity, equity, & inclusion%'
                OR lower(Description) LIKE '%diversity, equity & inclusion%'
                OR lower(Description) LIKE '%future working%'
                OR lower(Description) LIKE '%remote working%'
                OR lower(Description) LIKE '%return to work%'
                OR lower(Description) LIKE '%return-to-work%'
                OR lower(Description) LIKE '%return to office%'
                OR lower(Description) LIKE '%return-to-office%'
              THEN 'HR and Recruitment' ELSE NULL END IndustryName 
  FROM cntsrccurr),

industry_7 AS (
  SELECT SourceCode,
         CASE WHEN lower(Description) LIKE '%military%' 
                OR lower(Description) LIKE '%defense equipment%'
                OR lower(Description) LIKE '%defence equipment%'
                OR lower(Description) LIKE '%defense products%'
                OR lower(Description) LIKE '%defence products%'
                OR lower(Description) LIKE '%ammunition%'
                OR lower(Description) LIKE '%anti-personnel mine%'
                OR lower(Description) LIKE '%armament%'
                OR lower(Description) LIKE '% arms %'
                OR lower(Description) LIKE 'arms %'
                OR lower(Description) LIKE '%bomb%'
                OR lower(Description) LIKE '%grenade%'
                OR lower(Description) LIKE '%artillery%'
                OR lower(Description) LIKE '%landmine%'
                OR lower(Description) LIKE '%munition%'
                OR lower(Description) LIKE '%naval mine%'
                OR lower(Description) LIKE '%torpedo%'
                OR lower(Description) LIKE '%weapon%'
                OR lower(Description) LIKE '%warhead%'
                OR lower(Description) LIKE '%bullet%'
                OR lower(Description) LIKE '%cartridge%'
                OR lower(Description) LIKE '%shells%'
                OR lower(Description) LIKE '% gun %'
                OR lower(Description) LIKE 'gun %'
                OR lower(Description) LIKE '%guns%'
                OR lower(Description) LIKE '%firearm%'
                OR lower(Description) LIKE '%fighter jet%'
                OR lower(Description) LIKE '%missile%'
                OR lower(Description) LIKE '%jet fighter%'
                OR lower(Description) LIKE '%defense contract%'
                OR lower(Description) LIKE '%defence contract%'
                OR lower(Description) LIKE '% tanks%'
                OR lower(Description) LIKE 'tanks %'
                OR lower(Description) LIKE 'tank %'
                OR lower(Description) LIKE '% tank %'
                OR lower(Description) LIKE '%aircraft carrier%'
                OR lower(Description) LIKE '%gunboat%'
                OR lower(Description) LIKE '%warship%'
                OR lower(Description) LIKE '%nuclear submarine%'
                OR lower(Description) LIKE '%attack submarine%'
              THEN 'Military' ELSE NULL END IndustryName 
  FROM cntsrccurr),

industry_8 AS (
  SELECT SourceCode,
         CASE WHEN lower(Description) LIKE '%packaging%' 
                OR lower(Description) LIKE '%cling films%'
                OR lower(Description) LIKE '%bottles%'
                OR lower(Description) LIKE '%boxes%'
                OR lower(Description) LIKE '%plastic crates%'
                OR lower(Description) LIKE '%cartons%'
                OR lower(Description) LIKE '%plastic wraps%'
                OR lower(Description) LIKE '%containers%'
                OR lower(Description) LIKE '%glass jars%'
                OR lower(Description) LIKE '%glass tanks%'
                OR lower(Description) LIKE '%wooden crates%'
                OR lower(Description) LIKE '%wooden pallets%'
              THEN 'Paper and Packaging' ELSE NULL END IndustryName 
  FROM cntsrccurr),

industry_9 AS (
  SELECT SourceCode,
         CASE WHEN lower(Description) LIKE '%consultan%' 
                OR lower(Description) LIKE '%consulting%'
                OR lower(Description) LIKE '%compliance advisors%'
                OR lower(Description) LIKE '%compliance advisers%'
                OR lower(Description) LIKE '%compliance specialists%'
                OR lower(Description) LIKE '%risk management services%'
              THEN 'Professional Services/Consulting Advisory' ELSE NULL END IndustryName 
  FROM cntsrccurr),

industry_10 AS (
  SELECT SourceCode,
         CASE WHEN lower(Description) LIKE '%lodging%' 
                OR lower(Description) LIKE '%accommodation%'
                OR lower(Description) LIKE '%bed and breakfast%'
                OR lower(Description) LIKE '%b & b%'
                OR lower(Description) LIKE '%b and b%'
                OR lower(Description) LIKE '%b&b%'
                OR lower(Description) LIKE '% inn %'
                OR lower(Description) LIKE 'inn %'
                OR lower(Description) LIKE '% inns %'
                OR lower(Description) LIKE 'inns %'
                OR lower(Description) LIKE '%activity camp%'
                OR lower(Description) LIKE '%camp ground%'
                OR lower(Description) LIKE '%camp site%'
                OR lower(Description) LIKE '%camping%'
                OR lower(Description) LIKE '%campsite%'
                OR lower(Description) LIKE '%campground%'
                OR lower(Description) LIKE '%holiday camp%'
                OR lower(Description) LIKE '%rv park%'
                OR lower(Description) LIKE '%tent trailer%'
                OR lower(Description) LIKE '%travel trailer%'
                OR lower(Description) LIKE '%hotel%'
                OR lower(Description) LIKE '%motel%'
                OR lower(Description) LIKE '%guest house%'
                OR lower(Description) LIKE '%guesthouse%'
                OR lower(Description) LIKE '%hostel%'
                OR lower(Description) LIKE '%restaurant%'
                OR lower(Description) LIKE '%cafe%'
                OR lower(Description) LIKE '%fast food%'
                OR lower(Description) LIKE '%tourism%'
                OR lower(Description) LIKE '%hospitality%'
                OR lower(Description) LIKE '%airline booking%'
                OR lower(Description) LIKE '%airline reservation%'
                OR lower(Description) LIKE '%scenic service%'
                OR lower(Description) LIKE '%sightseeing service%'
                OR lower(Description) LIKE '%balloon ride%'
                OR lower(Description) LIKE '%city tour%'
                OR lower(Description) LIKE '%escorted tour%'
                OR lower(Description) LIKE '%luxury river cruise%'
                OR lower(Description) LIKE '%bus tour%'
                OR lower(Description) LIKE '%sight seeing%'
                OR lower(Description) LIKE '%sightseeing%'
                OR lower(Description) LIKE '%tour bus%'
                OR lower(Description) LIKE '%tour guide%'
                OR lower(Description) LIKE '%tourist guide%'
                OR lower(Description) LIKE '%travel agenc%'
                OR lower(Description) LIKE '%package holiday%'
                OR lower(Description) LIKE '%travel agent%'
              THEN 'Travel, Tourism and Hospitality' ELSE NULL END IndustryName 
  FROM cntsrccurr),

industry_11 AS (
  SELECT SourceCode,
         CASE WHEN lower(Description) LIKE '%cannabi%' 
                OR lower(Description) LIKE '%marijuana%'
                OR Description LIKE '%CBD%'
                OR lower(Description) LIKE '%edible pot%'
                OR lower(Description) LIKE '% hemp %'
                OR lower(Description) LIKE 'hemp %'
                OR lower(Description) LIKE '% hemp-%'
                OR lower(Description) LIKE 'hemp-%'
                OR lower(Description) LIKE '%medical pot%'
                OR lower(Description) LIKE '%pot shop%'
                OR lower(Description) LIKE '%pot store%'
              THEN 'Cannabis, Marijuana' ELSE NULL END IndustryName 
  FROM cntsrccurr),

industry_12 AS (
  SELECT SourceCode,
         CASE WHEN lower(Description) LIKE '% crime %' 
                OR lower(Description) LIKE 'crime %'
                OR lower(Description) LIKE '%breach of trust%'
                OR lower(Description) LIKE '%community sentence%'
                OR lower(Description) LIKE '%conspirac%'
                OR lower(Description) LIKE '%court proceeding%'
                OR lower(Description) LIKE '%court sentence%'
                OR lower(Description) LIKE '%court ruling%'
                OR lower(Description) LIKE '% crimes %'
                OR lower(Description) LIKE 'crimes %'
                OR lower(Description) LIKE '%criminal%'
                OR lower(Description) LIKE '%delinquency%'
                OR lower(Description) LIKE '%discharge%'
                OR lower(Description) LIKE '% abuse %'
                OR lower(Description) LIKE 'abuse %'
                OR lower(Description) LIKE 'abuses %'
                OR lower(Description) LIKE '% abuses %'
                OR lower(Description) LIKE '%extradition%'
                OR lower(Description) LIKE '% fines %'
                OR lower(Description) LIKE 'fines %'
                OR lower(Description) LIKE '%flytipping%'
                OR lower(Description) LIKE '%fly-tipping%'
                OR lower(Description) LIKE '%illegal%'
                OR lower(Description) LIKE '%investigat%'
                OR lower(Description) LIKE '%judicial proceeding%'
                OR lower(Description) LIKE '%juvenile%'
                OR lower(Description) LIKE '%lawsuit%'
                OR lower(Description) LIKE '%legal action%'
                OR lower(Description) LIKE '%litigation%'
                OR lower(Description) LIKE '%missing person%'
                OR lower(Description) LIKE '%offence%'
                OR lower(Description) LIKE '%offense%'
                OR lower(Description) LIKE '%prison sentence%'
                OR lower(Description) LIKE '%procuration%'
                OR lower(Description) LIKE '%prosecution%'
                OR lower(Description) LIKE '%public nuisance%'
                OR lower(Description) LIKE '%public order%'
                OR lower(Description) LIKE '%black market%'
                OR lower(Description) LIKE '%fraud%'
                OR lower(Description) LIKE '%informal economy%'
                OR lower(Description) LIKE '%shadow economy%'
                OR lower(Description) LIKE '%underground economy%'
                OR lower(Description) LIKE '%bad check%'
                OR lower(Description) LIKE '%check kiting%'
                OR lower(Description) LIKE '%check washing%'
                OR lower(Description) LIKE '%cheque scam%'
                OR lower(Description) LIKE '%counterfeit%'
                OR lower(Description) LIKE '%fake check%'
                OR lower(Description) LIKE '%fake cheque%'
                OR lower(Description) LIKE '%paper hanging%'
                OR lower(Description) LIKE '%graft%'
                OR lower(Description) LIKE '%influence peddling%'
                OR lower(Description) LIKE '%intimidation%'
                OR lower(Description) LIKE '%nepotism%'
                OR lower(Description) LIKE '%corruption%'
                OR lower(Description) LIKE '%vote buying%'
                OR lower(Description) LIKE '%bribe%'
                OR lower(Description) LIKE '%hush money%'
                OR lower(Description) LIKE '%kickback%'
                OR lower(Description) LIKE '%pay-off%'
                OR lower(Description) LIKE '%payoff%'
                OR lower(Description) LIKE '%secret commission%'
                OR lower(Description) LIKE '%slush fund%'
                OR lower(Description) LIKE '%cloned credit card%'
                OR lower(Description) LIKE '%credit card cloning%'
                OR lower(Description) LIKE '%credit card generator%'
                OR lower(Description) LIKE '%credit card scam%'
                OR lower(Description) LIKE '%credit card scheme%'
                OR lower(Description) LIKE '%credit card skimming%'
                OR lower(Description) LIKE '%doctored card%'
                OR lower(Description) LIKE '%fake card%'
                OR lower(Description) LIKE '%fake credit card%'
                OR lower(Description) LIKE '%stolen credit card%'
                OR lower(Description) LIKE '%alleged mismanagement of fund%'
                OR lower(Description) LIKE '%alleged misuse of fund%'
                OR lower(Description) LIKE '%defalcation%'
                OR lower(Description) LIKE '%diversion of fund%'
                OR lower(Description) LIKE '%diverting fund%'
                OR lower(Description) LIKE '%embezzl%'
                OR lower(Description) LIKE '%malversation%'
                OR lower(Description) LIKE '%misapplication of fund%'
                OR lower(Description) LIKE '%misappropriation of fund%'
                OR lower(Description) LIKE '%peculation%'
                OR lower(Description) LIKE '%blackmail%'
                OR lower(Description) LIKE '%coercion%'
                OR lower(Description) LIKE '%exaction%'
                OR lower(Description) LIKE '%extorting%'
                OR lower(Description) LIKE '%loan shark%'
                OR lower(Description) LIKE '%shakedown%'
                OR lower(Description) LIKE '%cash for crash%'
                OR lower(Description) LIKE '%crash for cash%'
                OR lower(Description) LIKE '%faking death%'
                OR lower(Description) LIKE '%false insurance%'
                OR lower(Description) LIKE '%insurance scam%'
                OR lower(Description) LIKE '%staged car collision%'
                OR lower(Description) LIKE '%boiler room%'
                OR lower(Description) LIKE '%dirty money%'
                OR lower(Description) LIKE '%launder%'
                OR lower(Description) LIKE '%predatory mortgage lending%'
                OR lower(Description) LIKE '%straw buyer%'
                OR lower(Description) LIKE '%front running%'
                OR lower(Description) LIKE '%pump-and-dump%'
                OR lower(Description) LIKE '%securities litigation%'
                OR lower(Description) LIKE '%share manipulation%'
                OR lower(Description) LIKE '%stock manipulation%'
                OR lower(Description) LIKE '%stock market manipulation%'
                OR lower(Description) LIKE '%unauthorized trading%'
                OR lower(Description) LIKE '%tax avoidance%'
                OR lower(Description) LIKE '%tax evasion%'
                OR lower(Description) LIKE '%evasion of customs duty%'
                OR lower(Description) LIKE '%false income tax return%'
                OR lower(Description) LIKE '%false tax return%'
                OR lower(Description) LIKE '%profit shifting%'
                OR lower(Description) LIKE '%tax dodging%'
                OR lower(Description) LIKE '%tax exile%'
                OR lower(Description) LIKE '%tax haven%'
                OR lower(Description) LIKE '%tax inversion%'
                OR lower(Description) LIKE '%tax litigation%'
                OR lower(Description) LIKE '%tax noncompliance%'
                OR lower(Description) LIKE '%tax shelter%'
                OR lower(Description) LIKE '%transfer pricing manipulation%'
                OR lower(Description) LIKE '%under-invoicing%'
                OR lower(Description) LIKE '%benefit cheat%'
                OR lower(Description) LIKE '%welfare cheat%'
              THEN 'Crime/Financial Crime' ELSE NULL END IndustryName 
  FROM cntsrccurr),

industry_13 AS (
  SELECT SourceCode,
         CASE WHEN lower(Description) LIKE '%betting%' 
                OR lower(Description) LIKE '%gaming%'
                OR lower(Description) LIKE '%gambling%'
                OR lower(Description) LIKE '%casino%'
                OR lower(Description) LIKE '%bingo hall%'
                OR lower(Description) LIKE '%bookmaker%'
                OR lower(Description) LIKE '%lottery%'
                OR lower(Description) LIKE '%turf accountant%'
                OR lower(Description) LIKE '%fantasy sport%'
                OR lower(Description) LIKE '%poker%'
                OR lower(Description) LIKE '%sports bet%'
                OR lower(Description) LIKE '%sports wagering%'
                OR lower(Description) LIKE '%sportsbook%'
              THEN 'Gaming/Gambling/Casinos' ELSE NULL END IndustryName 
  FROM cntsrccurr),

industry_14 AS (
  SELECT SourceCode,
         CASE WHEN lower(Description) LIKE '%alternative trading system%' 
                OR lower(Description) LIKE '%dark pool%'
                OR lower(Description) LIKE '%interdealer broker%'
                OR lower(Description) LIKE '%inter-dealer broker%'
                OR lower(Description) LIKE '%interdealer platform%'
                OR lower(Description) LIKE '%prop trading firm%'
                OR lower(Description) LIKE '%proprietary trading firm%'
                OR lower(Description) LIKE '%automated trading%'
                OR lower(Description) LIKE '%discount broker%'
                OR lower(Description) LIKE '%online broker%'
                OR lower(Description) LIKE '%online trading%'
                OR lower(Description) LIKE '%investment%'
                OR lower(Description) LIKE '%securities%'
                OR lower(Description) LIKE '%investing%'
                OR lower(Description) LIKE '%commodity contract%'
                OR lower(Description) LIKE '%financial adviser%'
                OR lower(Description) LIKE '%financial advisor%'
                OR lower(Description) LIKE '%financial plan%'
                OR lower(Description) LIKE '%financial research%'
                OR lower(Description) LIKE '%all-to-all dealing platform%'
                OR lower(Description) LIKE '%all-to-all platform%'
                OR lower(Description) LIKE '%all-to-all trading platform%'
                OR lower(Description) LIKE '%central limit order book%'
                OR lower(Description) LIKE '%central order book%'
                OR Description LIKE '%CLOB%'
                OR lower(Description) LIKE '%commodity exchange%'
                OR lower(Description) LIKE '%electronic trading%'
                OR Description LIKE '%ETP%'
                OR lower(Description) LIKE '%e-trading%'
                OR lower(Description) LIKE '%etrading%'
                OR lower(Description) LIKE '%financial exchange%'
                OR lower(Description) LIKE '%margin trading%'
                OR lower(Description) LIKE '%margin trade%'
                OR lower(Description) LIKE '%swap execution facilit%'
                OR lower(Description) LIKE '%trading house%'
              THEN 'Securities and Investing' ELSE NULL END IndustryName 
  FROM cntsrccurr),

src as (select srcinfo_code_value, groups.group_code--array_split(srcinfo_groups_group,',')
from dimension_external_db.cdb_source_docs_current srcc cross join unnest(split(srcc.srcinfo_groups_group,',')) as groups(group_code)
--where srcinfo_code_value = 'WC40298'
group by 1,2),

grp as (select groupinfo_code_value, groupinfo_grouptypecode_code_value, groupinfo_groupname, 'find out' as region_type
from dimension_external_db.cdb_group_docs_current
group by 1,2,3,4),

cntsrcgrpcurr as (select src.srcinfo_code_value, src.group_code, lower(grp.groupinfo_grouptypecode_code_value) as groupinfo_grouptypecode_code_value, grp.groupinfo_groupname, rtc.roo_region_type as region_type
from src left join grp on src.group_code = grp.groupinfo_code_value
	LEFT JOIN dimension_external_db.cdb_region_type_code rtc ON rtc.roo_group_code = src.group_code
group by 1,2,3,4,5),
  
remaining_industries AS (
  SELECT srcinfo_code_value,
         CASE WHEN upper(group_code) IN ('TGORC','TGOV') THEN 'Government and Public Sector'
              WHEN upper(group_code) IN ('TLGL') THEN 'Legal'
              WHEN upper(group_code) IN ('TOWS') THEN 'Not For Profit and Social'
              WHEN upper(group_code) IN ('TSPO') THEN 'Sports'
              ELSE NULL
              END IndustryName
  FROM cntsrcgrpcurr
  WHERE groupinfo_grouptypecode_code_value IN ('tyg','TYG')),

custom_industries AS (
  SELECT * FROM (
    SELECT * FROM industry_1
    UNION ALL
    SELECT * FROM industry_2
    UNION ALL
    SELECT * FROM industry_3
    UNION ALL
    SELECT * FROM industry_4
    UNION ALL
    SELECT * FROM industry_5
    UNION ALL
    SELECT * FROM industry_6
    UNION ALL
    SELECT * FROM industry_7
    UNION ALL
    SELECT * FROM industry_8
    UNION ALL
    SELECT * FROM industry_9
    UNION ALL
    SELECT * FROM industry_10
    UNION ALL
    SELECT * FROM industry_11
    UNION ALL
    SELECT * FROM industry_12
    UNION ALL
    SELECT * FROM industry_13
    UNION ALL
    SELECT * FROM industry_14
    UNION ALL
    SELECT * FROM remaining_industries)
  WHERE IndustryName IS NOT NULL),

full_industries AS (
  SELECT srcinfo_code_value, 
	 CASE WHEN groupinfo_groupname = 'Healthcare/Life Sciences' THEN 'Health Care/Life Sciences'
	      ELSE groupinfo_groupname END as IndustryName
  FROM cntsrcgrpcurr
  WHERE lower(groupinfo_grouptypecode_code_value) = 'ing'  
  UNION ALL 
  SELECT * FROM custom_industries
),

country_industry_sources as (
  SELECT cntsrccurr.SourceCode, ARRAY_JOIN(ARRAY_AGG(IndustryName), ',') industry_list
  FROM cntsrccurr
  LEFT JOIN full_industries sgi ON cntsrccurr.SourceCode = sgi.srcinfo_code_value
  WHERE IndustryName IS NOT NULL
  GROUP BY 1
),

source_roo AS (
	SELECT srcinfo_code_value, groupinfo_groupname AS country_name, group_code AS country_code
	FROM cntsrcgrpcurr
    WHERE lower(groupinfo_grouptypecode_code_value) IN ('roo')
/*region_type needs attention*/
    	AND region_type = 'Co'
    GROUP BY 1,2,3
),

source_royalty AS (
	SELECT roy.source_code,
		   (SELECT MAX(cycle_date) FROM dimension_external_db.royalty_monthly_management_report) AS latest_month,
		   SUM(CASE WHEN cycle_date = (SELECT MAX(cycle_date) FROM dimension_external_db.royalty_monthly_management_report)
		   			THEN royalty_usd ELSE 0 END) AS latest_month_royalty,
		   AVG(CASE WHEN date_diff('month',DATE(cycle_date),DATE((SELECT MAX(cycle_date) FROM dimension_external_db.royalty_monthly_management_report))) 
		   				IN (1, 2, 3) THEN royalty_usd END) three_month_average
	FROM dimension_external_db.royalty_monthly_management_report roy
	GROUP BY 1, 2
),

cvi as (select case 
		   when month(period) in (1, 2, 3) then concat(cast(year(period) as varchar), ' ', 'Q4-Q1')
		   when month(period) in (4, 5, 6) then concat(cast(year(period) as varchar), ' ', 'Q1-Q2')
		   when month(period) in (7, 8, 9) then concat(cast(year(period) as varchar), ' ', 'Q2-Q3')
		   when month(period) in (10, 11, 12) then concat(cast(year(period) as varchar), ' ', 'Q3-Q4')
		   end 
		   as cy_quarter, *
                from sandbox_mk.factiva_content_value_index_ui),

source_factiva_vi AS (
	SELECT source_code, cy_quarter, 
		   normal_demand_index AS demand_index,
		   normal_strategic_value_multiplier AS strategic_multiplier,
		   value_index,
		   CAST(payments_actual AS double) AS actual_royalty_usd_est,
		   CAST(predicted_cost AS double) AS predicted_royalty_usd,
		   payment_level,
		   CAST(max_on_target AS double) AS max_on_target
	FROM cvi
	WHERE cy_quarter = (SELECT MAX(cy_quarter) FROM cvi) and cycle_date = (select max(cycle_date) from cvi)
),

multiple_rpcs AS (
	SELECT ippubinfo_ip_code_value, COUNT(DISTINCT billingdist_royaltyprovider_code_value)
	FROM cntsrccurr 
	WHERE srcinfo_statuscode_code_value = 'ACT'
	GROUP BY 1
	HAVING COUNT(DISTINCT billingdist_royaltyprovider_code_value) >> 1
),

document_counts AS (
	SELECT source_code, SUM(article_count) documents
	FROM (SELECT source_code, CAST(publication_month AS varchar) start_date, CAST(end_date AS varchar) end_date, article_count, CAST(actual_start_date AS varchar) actual_start_date, CAST(actual_end_date AS varchar) actual_end_date
                FROM dimension_external_db.content_volumes) 
	WHERE DATE(SUBSTRING(start_date,1,10)) >>= DATE_ADD('day', -1, DATE_TRUNC('month', DATE_ADD('month', -12, CURRENT_DATE)))
	      AND DATE(SUBSTRING(start_date,1,10)) <<= DATE_ADD('day', -1, DATE_TRUNC('month', CURRENT_DATE))
	GROUP BY 1
),

ipr as (
select cast(contract_id as integer) as contractid, status, input_provider_name as inputprovidername, country_of_origin as countryoforigin, territory, input_provider_code, publisher_relation_contact as publisherrelationcontact, vendor_number as vendornumber, vendor_name as vendorname, cast(contract_eff_date as varchar) as contracteffdate, cast(contract_term as varchar) as contractterm, cast(term_end_date as varchar) as termenddate, case when auto_renewal = True then 'True' else 'False' end as autorenewal, cast(renewal_term as varchar) as renewalterm, case when termination_delete_content = True then 'True' else 'False' end as terminationdeletecontent, cast(termination_delete_content_time_frame as varchar) as terminationdeletecontenttimeframe, cast(royalty_rate_for_ip as varchar) as royaltyrateforip, case when fixed_fee = True then 'True' else 'False' end as fixedfee, cast(fixed_fee_amount as varchar) as fixedfeeamount, fixed_fee_frequency as fixedfeefrequency, case when guaranteed_min = True then 'True' else 'False' end as guaranteedmin, cast(g_min_amount as varchar) as gminamount, g_min_frequency as gminfrequency, case when new_ad_notify = True then 'True' else 'False' end as newadnotify, case when new_ad_consent = True then 'True' else 'False' end as newadconsent, case when blocking = True then 'True' else 'False' end as blocking, case when extranet_distribution = True then 'True' else 'False' end as extranetdistribution, cast(factiva_storage as varchar) as factivastorage, case when third_party_storage = True then 'True' else 'False' end as thirdpartystorage, case when customer_headline_storage = True then 'True' else 'False' end as customerheadlinestorage, cast(customer_article_storage as varchar) as customerarticlestorage,	case when new_product_notify = True then 'True' else 'False' end as newproductnotify, case when new_product_consent = True then 'True' else 'False' end as newproductconsent, case when translation_rights = True then 'True' else 'False' end as translationrights, case when embargo = True then 'True' else 'False' end as embargo, case when expiry = True then 'True' else 'False' end as expiry, payment_notes as paymentnotes, commercial_stat_notes as commercialstatnotes
from dimension_external_db.ip_rights_data_current 
)

SELECT DISTINCT cntsrccurr.SourceCode AS source_code, cntsrccurr.srcinfo_sourcename AS source_name, 
	   cntsrccurr.docdata_sourcetype_value AS source_type, cntsrccurr.srcinfo_statuscode_code_value as status, cntsrccurr.ippubinfo_srcprimarytype_description, 
	   cntsrccurr.srcinfo_langn,
	   cntsrccurr.ippubinfo_ip_code_value AS ip_code, cntsrccurr.ippubinfo_ip_name AS ip_name, 
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
			ELSE ippubinfo_ip_code_value END AS ip_code_adj,
	   cntsrccurr.billingdist_royaltyprovider_code_value,
	   cntsrccurr.article_coverage AS article_coverage, 
	   cntsrccurr.srcinfo_coverage_value AS source_coverage,
	   cntsrccurr.srcinfo_firstissuedate_value AS first_online_issue, 
	   cntsrccurr.srcinfo_onlinedate_value AS online_date,
	   cntsrccurr.max_lag as maxlag, cntsrccurr.min_lag as minlag,
	   cntsrccurr.srcinfo_nomlagn AS online_availability, 
	   cntsrccurr.ippubinfo_srcrightstype_code_value AS rights_code, 
	   cntsrccurr.billingdist_embargohours_value AS embargo_hours, 
	   cntsrccurr.billingdist_embargodays_value AS embargo_days,
	   cntsrccurr.billingdist_expirationhours_value AS expiration_hours, 
	   cntsrccurr.billingdist_expirationdays_value AS expiration_days, 
	   cntsrccurr.srcinfo_srcpriority_value as priority_band, 
	   cntsrccurr.ippubinfo_allowtranslation_value AS auto_translate,
	   cntsrccurr.Description as description,
	   roo.country_code,
	   roo.country_name,
	   cis.industry_list AS industry_list,
	   roy.latest_month AS royalty_month,
	   COALESCE(roy.latest_month_royalty,0) AS royalty_usd,
	   COALESCE(roy.three_month_average,0) AS prev_3mo_royalty_avg,
	   COALESCE(roy.latest_month_royalty,0) - COALESCE(roy.three_month_average,0) AS diff_vs_3mo_avg,
	   case when COALESCE(roy.three_month_average,0) = 0 then null else ((COALESCE(roy.latest_month_royalty,0) - COALESCE(roy.three_month_average,0)) 
	   		/ COALESCE(roy.three_month_average,0)) end AS pct_diff_vs_3mo_avg,
	   fvi.cy_quarter AS latest_factiva_vi_quarter,
	   fvi.demand_index AS fvi_demand_index,
	   fvi.strategic_multiplier AS fvi_strategic_multiplier,
	   fvi.value_index AS fvi_value_index,
	   COALESCE(fvi.actual_royalty_usd_est,0) AS fvi_6mo_actual_royalty_usd_est,
	   fvi.predicted_royalty_usd AS fvi_6mo_predicted_royalty_usd,
	   fvi.payment_level AS fvi_payment_level,
	   fvi.max_on_target AS fvi_6mo_max_on_target,
	   COALESCE(rnc_sc.ame,0) AS ame_profiles_created,
	   COALESCE(rnc_sc.sip,0) AS sip_profiles_created,
	   COALESCE(rnc_sc.pep,0) AS pep_profiles_created,
	   COALESCE(rnc_sc.siplt,0) AS siplt_profiles_created,
	   COALESCE(rnc_sc.soc,0) AS soc_profiles_created,
	   COALESCE(rnc_sc.sor,0) AS sor_profiles_created,
	   COALESCE(rnc_sc.rca,0) AS rca_profiles_created,
	   COALESCE(rnc_sc.total,0) AS total_profiles_created,
	   COALESCE(rnc_sc.ame_unique,0) AS ame_unique_profiles_created,
	   COALESCE(rnc_sc.sip_unique,0) AS sip_unique_profiles_created,
	   COALESCE(rnc_sc.pep_unique,0) AS pep_unique_profiles_created,
	   COALESCE(rnc_sc.siplt_unique,0) AS siplt_unique_profiles_created,
	   COALESCE(rnc_sc.soc_unique,0) AS soc_unique_profiles_created,
	   COALESCE(rnc_sc.sor_unique,0) AS sor_unique_profiles_created,
	   COALESCE(rnc_sc.rca_unique,0) AS rca_unique_profiles_created,
	   COALESCE(rnc_sc.total_unique,0) AS total_unique_profiles_created,
	   COALESCE(rnc_sc.ame_article_links,0) AS ame_article_links,
	   COALESCE(rnc_sc.sip_article_links,0) AS sip_article_links,
	   COALESCE(rnc_sc.pep_article_links,0) AS pep_article_links,
	   COALESCE(rnc_sc.siplt,0) AS siplt_article_links,
	   COALESCE(rnc_sc.soc,0) AS soc_article_links,
	   COALESCE(rnc_sc.sor,0) AS sor_article_links,
	   COALESCE(rnc_sc.rca,0) AS rca_article_links,
	   COALESCE(rnc_sc.total_article_links,0) AS total_article_links,
	   COALESCE(rnc_usg.article_views,0) AS total_article_views,
	   COALESCE(rnc_usg.rnc_article_views,0) AS rnc_article_views,
	   COALESCE(fc.article_views,0) AS rcfc_article_views,
	   rvi.rnc_key_industry,
	   rvi.profile_index AS rvi_profile_index,
	   rvi.usage_index AS rvi_usage_index,
	   rvi.strategic_multiplier AS rvi_strategic_multiplier,
	   rvi.gap_country AS rvi_gap_country,
	   rvi.tax_haven AS rvi_tax_haven,
	   rvi.ifc AS rvi_ifc,
	   rvi.mafia AS rvi_mafia,
	   rvi.rnc_value_index AS rvi_value_index,
	   COALESCE(docs.documents, 0) AS last_12mo_doc_count
FROM cntsrccurr
LEFT JOIN ipr ON cntsrccurr.ippubinfo_ip_code_value = ipr.input_provider_code 
LEFT JOIN ipr ip_rpc ON cntsrccurr.billingdist_royaltyprovider_code_value = ip_rpc.input_provider_code 
LEFT JOIN sandbox_mk.sources_used_for_rnc_all_time rnc_sc ON cntsrccurr.SourceCode = rnc_sc.source_code 
LEFT JOIN source_usage_rnc_users rnc_usg ON cntsrccurr.SourceCode = rnc_usg.source_code
LEFT JOIN financial_crime_source_usg fc ON cntsrccurr.SourceCode = fc.source_code
LEFT JOIN country_industry_sources cis ON cntsrccurr.SourceCode = cis.SourceCode
LEFT JOIN source_roo AS roo ON cntsrccurr.SourceCode = roo.srcinfo_code_value
LEFT JOIN source_royalty AS roy ON cntsrccurr.SourceCode = roy.source_code
LEFT JOIN (SELECT * FROM sandbox_mk.rnc_value_index
		   WHERE cycle_date = (SELECT MAX(cycle_date) FROM sandbox_mk.rnc_value_index)) rvi ON cntsrccurr.SourceCode = rvi.source_code 
LEFT JOIN source_factiva_vi fvi ON cntsrccurr.SourceCode = fvi.source_code
LEFT JOIN document_counts docs ON cntsrccurr.SourceCode = docs.source_code
