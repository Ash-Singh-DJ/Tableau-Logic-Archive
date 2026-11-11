-- Dashboard   : "B2B Factiva Expert Searches Dashboard"  [B2B / B2B Product / Factiva / Factiva Search Usage]
-- Data source : "FES" (embedded in the workbook)
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with Omnit as 
(select substring(cast(date_time as varchar),1,7) year_month, user_info_user_ref, event_name, 
 cast(ti_td_search_filters_factiva_expert_search_code as integer) search_code,
  ti_td_search_filters_factiva_expert_search_descriptor,
  substring(ti_td_search_filters_factiva_expert_search_descriptor, strpos(ti_td_search_filters_factiva_expert_search_descriptor,'(')) test,
 count(ti_td_search_filters_factiva_expert_search_code) search_code_count 
  from pib_event_data.pib_product_metrics
 where product = 'Factiva'
 and ti_td_search_filters_factiva_expert_search_code is not null 
 and date_time >>= cast('2022-10-01' as date)
 group by 1,2,3,4,5,6),

 mem_fact AS (
  SELECT billing_account_id, contract_id, pib_member_id
  FROM fact_external_db.pib_membership_fact
  GROUP BY billing_account_id, contract_id, pib_member_id),

product_master AS (
  SELECT access_code, master_product, product_line, bu
  FROM reference_external_db.pib_product_master
  group by access_code, master_product, product_line, bu),

Bill_Acct_Dim AS (
  SELECT cibs_billing_account_id, contract_id, subscription_date, salesforce_status
  FROM dimension_external_db.pib_billing_account_dimension
  GROUP BY cibs_billing_account_id, contract_id, subscription_date, salesforce_status),

mem_dim AS (
  SELECT pib_member_id, country_code, plan_id, user_id, billing_account_id
  FROM dimension_external_db.pib_membership_dimension
  GROUP BY pib_member_id, country_code, plan_id, user_id, billing_account_id),

Contract_Dim AS (
  SELECT contract_id
  FROM dimension_external_db.pib_contract_dimension
  GROUP BY contract_id),

Acct_Fact AS ( 
  SELECT contract_id, company_sfdc_id
  FROM fact_external_db.pib_account_hierarchy_fact
  GROUP BY contract_id, company_sfdc_id),

Comp AS ( 
  SELECT company_name, company_sfdc_id, company_industry, company_territory, company_country
  FROM dimension_external_db.pib_company_dimension),

Terr AS (
  SELECT territory_sfdc_id, territory_name
FROM dimension_external_db.pib_territory_dimension)

select Omnit.*, 
mem_dim.user_id,
mem_dim.plan_id,
Comp.company_name,
mem_dim.billing_account_id,
Terr.territory_name,
product_master.product_line,
product_master.master_product,
mk.geo_region

FROM Omnit
LEFT JOIN mem_dim ON mem_dim.pib_member_id = Omnit.user_info_user_ref
LEFT JOIN mem_fact ON mem_fact.pib_member_id = mem_dim.pib_member_id
LEFT JOIN Contract_Dim ON mem_fact.contract_id = Contract_Dim.contract_id
LEFT JOIN Acct_Fact ON Contract_Dim.contract_id = Acct_Fact.contract_id
LEFT JOIN Comp ON Acct_Fact.company_sfdc_id = Comp.company_sfdc_id
LEFT JOIN product_master ON mem_dim.plan_id = product_master.access_code
LEFT JOIN Terr ON Comp.company_territory = Terr.territory_sfdc_id
left join sandbox_mk.geo_region_rollup mk on Terr.territory_name = mk.sales_territory 

group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
