-- Dashboard   : "B2B Factiva Business Metrics: Registered and Active Users"  [B2B / B2B Product / Factiva]
-- Data source : "BB Report" = published source "B2B Factiva Business Metrics: Registered and Active Users - BB Report"  [B2B / B2B Product / Factiva / Datasources]
-- Relation    : Custom SQL "Reg in month"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select substring(cast(web_registration_date as varchar),1,10) year_month, 
mem.billing_account_id, 


count(distinct EID) reg_in_month 


from dimension_external_db.pib_membership_dimension mem
--and user_status = 'A'
where web_registration_date >>= cast('2021-11-01' as date)
and mem.billing_account_id like '9%' 
group by 1,2
