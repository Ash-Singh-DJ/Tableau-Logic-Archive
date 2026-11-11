-- Dashboard   : "Lazard Freres Factiva Usage"  [B2B / B2B Sales / Product Usage]
-- Data source : "Lazard Reg in Month Query" (embedded in the workbook)
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select substring(cast(web_registration_date as varchar),1,7) year_month,

count(distinct EID) reg_in_month 


from dimension_external_db.pib_membership_dimension mem
LEFT JOIN dimension_external_db.pib_billing_account_dimension bad on mem.billing_account_id = bad.cibs_billing_account_id
LEFT JOIN dimension_external_db.pib_company_dimension comp on comp.company_sfdc_id = bad.salesforce_company_two
--and user_status = 'A'
where web_registration_date >>= cast('2022-07-01' as date)
and comp.company_name = 'LAZARD FRERES SAS'
group by 1
order by substring(cast(web_registration_date as varchar),1,7)
