-- Published data source : "B2B PIB User-List Dashboard Query"  [B2B / B2B Sales / Data Sources]
-- Relation    : Custom SQL "Billing Acct Information"
-- Connection  : Athena (AwsDataCatalog / reference_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
WITH bad as (SELECT cibs_billing_account_id,
                    salesforce_contract_name,
                    salesforce_status,
                    account_sales_territory,
                    account_sales_region,
                    sales_person,
                    contract_id,
                    salesforce_account_name,
                    salesforce_company_two
     FROM dimension_external_db.pib_billing_account_dimension
     GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9),

ahf as ( select
contract_id,
company_sfdc_id,
corporate_sfdc_id
from fact_external_db.pib_account_hierarchy_fact
group by 1, 2, 3),

pcmd as ( select
company_name,
company_sfdc_id
from
dimension_external_db.pib_company_dimension
group by 1, 2),

pcrd as ( select
corporate_name,
corporate_sfdc_id
from
dimension_external_db.pib_corporate_dimension
group by 1, 2),

ptd as (select territory_roll_up,
               territory_name,
               regional_sales_director
from dimension_external_db.pib_territory_dimension
group by territory_roll_up,
         territory_name,
         regional_sales_director),

user_dim as (select user_sfdc_id,
                    user_full_name
from dimension_external_db.pib_user_dimension
group by 1, 2)


SELECT bad.cibs_billing_account_id,
       bad.salesforce_status,
       bad.salesforce_contract_name,
       pcmd.company_name,
       pcrd.corporate_name,
       bad.sales_person,
       bad.account_sales_territory,
       ptd.territory_roll_up,
       account_sales_region,
       user_dim.user_full_name as rsd
FROM bad
LEFT JOIN ahf ON bad.contract_id = ahf.contract_id
LEFT JOIN pcrd ON ahf.corporate_sfdc_id = pcrd.corporate_sfdc_id
LEFT JOIN pcmd ON bad.salesforce_company_two = pcmd.company_sfdc_id
LEFT JOIN ptd ON bad.account_sales_territory = ptd.territory_name
LEFT JOIN user_dim ON ptd.regional_sales_director = user_dim.user_sfdc_id
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
