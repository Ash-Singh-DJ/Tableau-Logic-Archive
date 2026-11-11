-- Published data source : "B2B Factiva Emails: Deliveries and Opens - Open Rates Email"  [B2B / B2B Product / Factiva / Datasources]
-- Relation    : Custom SQL "NLID"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select nlid, nlid_name from (



with nle as 
(select date_time, post_prop40, substring(post_prop40, 1, strpos(post_prop40,'_')-1) as nlid, substring(post_prop40,strpos(post_prop40,'_')+1,250) as nlid_name,


SUM(CASE WHEN reporting_suite = 'djfactiva' and cast(post_page_event as varchar) = '0' AND (CAST(exclude_hit AS integer) <<= 0 AND cast(hit_source as varchar) NOT IN ('5', '8', '9'))
                    AND (post_evar4 = 'Fact_ART_ArticleView' or post_prop3 = 'ARTICLE' or lower(post_pagename) like '%article%')
                    AND lower(post_pagename) NOT LIKE '%login%' AND post_prop40 <<>> '' THEN 1 ELSE 0 END) newsletter_article_views
                    
                    
                     FROM fact_external_db.omniture_event_fact
WHERE reporting_suite = 'djfactiva'
--and post_prop40 like '%533453%'
and cycle_date >>= CAST('2020-01-01' as date)
group by 1,2,3,4)

select * from nle 
where date_time = (select max(date_time) from nle nl2 where nle.nlid = nl2.nlid)

)
where nlid_name <<>> ''

group by 1,2
