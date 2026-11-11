-- Published data source : "B2B New Factiva Onboarding Metrics - SRE Subscribers"  [B2B / B2B Product / Factiva / Datasources / B2B New Factiva Onboarding Data Sources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select product_type, count(distinct user_id) as unique_users from dimension_external_db.pib_alerts 
where product_type in ('sre','sba', 'iba')
and report_date >>= date_add('day', -10, current_date)
and account_id not like '9ZZZ%'
and account_id not like '9ZFB%'
and account_id <<>> '9DOW003600'
and account_id <<>> '9DOW007100'
and account_id  <<>> '9FAC067700'
group by 1
