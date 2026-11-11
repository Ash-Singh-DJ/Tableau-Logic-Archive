-- Dashboard   : "B2B Factiva Gen AI Article Usage"  [B2B / B2B Product / Factiva]
-- Data source : "Split by Source" = published source "Split by Source"  [B2B / B2B Product / Factiva]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select sc3, SourceName,
IPCode,
IPName, 
billing_account_id,
company_name,
substring(cast(datetime as varchar),1,7) as year_month,
count(*) as article_count from (

with lu as 
(select bam.user_key, bam.billing_account_id, comp.company_name from pib_event_data.user_key_billing_account_mappings bam
left join dimension_external_db.pib_billing_account_dimension bill on bam.billing_account_id = bill.cibs_billing_account_id 
LEFT JOIN dimension_external_db.pib_company_dimension comp on bill.salesforce_company_two = comp.company_sfdc_id)


select 
an,
UPPER(case when substring(an, 1, strpos(an,'0')-1) like '%2%' then
substring(an, 1, strpos(an,'2')-1) else
substring(an, 1, strpos(an,'0')-1) end) as sc3,
gen.user_key,
datetime,
work_id,
lu.billing_account_id,
lu.company_name,
user_id,
SourceName,
IPCode,
IPName

from 
pib_event_data.gen_ai_article_usage gen
left join lu on gen.user_key = lu.user_key
left join sandbox_mk.source_db_clean mk on UPPER(case when substring(gen.an, 1, strpos(gen.an,'0')-1) like '%2%' then
substring(gen.an, 1, strpos(an,'2')-1) else
substring(gen.an, 1, strpos(an,'0')-1) end) = mk.SourceCode
where datetime >>= cast('2025-01-01' as date)


)
group by 1,2,3,4,5,6,7
