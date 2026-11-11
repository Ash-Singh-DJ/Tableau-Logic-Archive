-- Published data source : "B2B R&C Upsell Opportunity - R&C ASAM Data"  [B2B / B2B Sales / Data Sources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with 
stats as(select billing_id, sum(active_clients) active_clients, 
sum(assesments) as assesments, cycle_date from 
dimension_external_db.asam_usage_stats
where lower(billing_id) not like ('%old%')
group by 1,4
),

comp as (
SELECT ba.cibs_billing_account_id, 
        ba.salesforce_contract_renewal_date, 
        ba.salesforce_billing_account_id,
        ba.salesforce_trial_flag,
        ba.country,
        ba.account_sales_region,
        comp.company_name, 
        corp.corporate_name,
        terr.territory_roll_up,
        usr.user_full_name as rsd,
        usr2.user_full_name AS salesperson
FROM dimension_external_db.pib_billing_account_dimension ba 
--ON ba.salesforce_billing_account_id = cib.cibs_billing_account 
LEFT JOIN dimension_external_db.pib_company_dimension comp on ba.salesforce_company_two = comp.company_sfdc_id
LEFT JOIN dimension_external_db.pib_corporate_dimension corp ON comp.parent_sfdc_id = corp.corporate_sfdc_id 
LEFT JOIN dimension_external_db.pib_territory_dimension terr ON comp.company_territory = terr.territory_sfdc_id 
LEFT JOIN dimension_external_db.pib_user_dimension usr ON usr.user_sfdc_id = terr.regional_sales_director 
LEFT JOIN dimension_external_db.pib_user_dimension usr2 ON usr2.user_sfdc_id = terr.territory_owner
WHERE ba.cibs_billing_account_id in (select distinct billing_id from stats)       
),

main as(
select stats.*, comp.*
from stats
left join comp on comp.cibs_billing_account_id = stats.billing_id
),

asam_cib as(
SELECT  cibs_billing_account, product_id, sum(transaction_volume) transaction_volume
FROM dimension_external_db.pib_cibs_billing_charges_dimension cib
WHERE lower(product_id) in ('asme','asdm','asbu','asem','amun','amdx','axen','abxe','adsm') 
and current_chg = 'Current'
group by 1,2
)


select main.*, asam_cib.*
from main
left join asam_cib on asam_cib.cibs_billing_account = main.salesforce_billing_account_id
