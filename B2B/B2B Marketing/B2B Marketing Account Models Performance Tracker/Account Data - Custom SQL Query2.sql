-- Dashboard   : "B2B Marketing Account Models Performance Tracker"  [B2B / B2B Marketing]
-- Data source : "Account Data" (embedded in the workbook)
-- Relation    : Custom SQL "Custom SQL Query2"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with newswires_counts as (
select
	sfdc_id,
	(
	select
		count(*)
	from
		zoolander_db.pib_account_model_newswires n
	left join dimension_external_db.pib_company_dimension comp on comp.company_sfdc_id = n.sfdc_id
	left join dimension_external_db.pib_territory_dimension td on td.territory_sfdc_id = comp.company_territory
	where
		(cycle_date  = (select max(cycle_date) from zoolander_db.pib_account_model_newswires))
		and newswires_fit_rating = 'A' and (td.territory_name is not null
			and td.territory_name not like 'BD%'
			and td.territory_name not like 'CUSTOMER%' and td.territory_name not like 'FNPEN%' and td.territory_name not like 'Pro Manager %' 
			and td.territory_name not like 'Proquest%' and td.territory_name not like 'Pro SI Territory%'
			and td.territory_name not like 'R&C Partners%' and td.territory_name not like 'WSJ %') and comp.status_flag <<>> 'DELETE'
	group by
		newswires_fit_rating) as newswires_A_number_accounts,
	(
	select
		count(*)
	from
		zoolander_db.pib_account_model_newswires n
	left join dimension_external_db.pib_company_dimension comp on comp.company_sfdc_id = n.sfdc_id
	left join dimension_external_db.pib_territory_dimension td on td.territory_sfdc_id = comp.company_territory
	where
		(cycle_date  = (select max(cycle_date) from zoolander_db.pib_account_model_newswires))
			and newswires_fit_rating = 'B' and (td.territory_name is not null
			and td.territory_name not like 'BD%'
			and td.territory_name not like 'CUSTOMER%' and td.territory_name not like 'FNPEN%' and td.territory_name not like 'Pro Manager %' 
			and td.territory_name not like 'Proquest%' and td.territory_name not like 'Pro SI Territory%'
			and td.territory_name not like 'R&C Partners%' and td.territory_name not like 'WSJ %') and comp.status_flag <<>> 'DELETE'
		group by
			newswires_fit_rating) as newswires_B_number_accounts,
	(
	select
		count(*)
	from
		zoolander_db.pib_account_model_newswires n
	left join dimension_external_db.pib_company_dimension comp on comp.company_sfdc_id = n.sfdc_id
	left join dimension_external_db.pib_territory_dimension td on td.territory_sfdc_id = comp.company_territory
	where
		(cycle_date  = (select max(cycle_date) from zoolander_db.pib_account_model_newswires))
			and newswires_fit_rating = 'C' and (td.territory_name is not null
			and td.territory_name not like 'BD%'
			and td.territory_name not like 'CUSTOMER%' and td.territory_name not like 'FNPEN%' and td.territory_name not like 'Pro Manager %' 
			and td.territory_name not like 'Proquest%' and td.territory_name not like 'Pro SI Territory%'
			and td.territory_name not like 'R&C Partners%' and td.territory_name not like 'WSJ %') and comp.status_flag <<>> 'DELETE'
		group by
			newswires_fit_rating) as newswires_C_number_accounts,
	(
	select
		count(*)
	from
		zoolander_db.pib_account_model_newswires n
	left join dimension_external_db.pib_company_dimension comp on comp.company_sfdc_id = n.sfdc_id
	left join dimension_external_db.pib_territory_dimension td on td.territory_sfdc_id = comp.company_territory
	where
		(cycle_date  = (select max(cycle_date) from zoolander_db.pib_account_model_newswires))
			and newswires_fit_rating = 'D' and (td.territory_name is not null
			and td.territory_name not like 'BD%'
			and td.territory_name not like 'CUSTOMER%' and td.territory_name not like 'FNPEN%' and td.territory_name not like 'Pro Manager %' 
			and td.territory_name not like 'Proquest%' and td.territory_name not like 'Pro SI Territory%'
			and td.territory_name not like 'R&C Partners%' and td.territory_name not like 'WSJ %') and comp.status_flag <<>> 'DELETE'
		group by
			newswires_fit_rating) as newswires_D_number_accounts
from
	zoolander_db.pib_account_model_newswires
where
	(cycle_date  = (select max(cycle_date) from zoolander_db.pib_account_model_newswires))
),

factiva_counts as (
select
	sfdc_id,
	(
	select
		count(*)
	from
		zoolander_db.pib_account_model_factiva f
	left join dimension_external_db.pib_company_dimension comp on comp.company_sfdc_id = f.sfdc_id
	left join dimension_external_db.pib_territory_dimension td on td.territory_sfdc_id = comp.company_territory
	where
		(cycle_date  = (select max(cycle_date) from zoolander_db.pib_account_model_factiva))
		and factiva_fit_rating = 'A' and (td.territory_name is not null
		
		and td.territory_name not like 'BD%'
			and td.territory_name not like 'CUSTOMER%' and td.territory_name not like 'FNPEN%' and td.territory_name not like 'Pro Manager %' 
			and td.territory_name not like 'Proquest%' and td.territory_name not like 'Pro SI Territory%'
			and td.territory_name not like 'R&C Partners%' and td.territory_name not like 'WSJ %') and comp.status_flag <<>> 'DELETE'
			--, 'CUSTOMER', 'FNPEN', 'Pro Manager', 'Proquest', 'Pro SI Territory', 'R&C Partners', 'WSJ '))
		group by
		factiva_fit_rating) as factiva_A_number_accounts,
	(
	select
		count(*)
	from
		zoolander_db.pib_account_model_factiva f
	left join dimension_external_db.pib_company_dimension comp on comp.company_sfdc_id = f.sfdc_id
	left join dimension_external_db.pib_territory_dimension td on td.territory_sfdc_id = comp.company_territory
	where
		(cycle_date  = (select max(cycle_date) from zoolander_db.pib_account_model_factiva))
			and factiva_fit_rating = 'B' and (td.territory_name is not null 
			
			and td.territory_name not like 'BD%'
			and td.territory_name not like 'CUSTOMER%' and td.territory_name not like 'FNPEN%' and td.territory_name not like 'Pro Manager %' 
			and td.territory_name not like 'Proquest%' and td.territory_name not like 'Pro SI Territory%'
			and td.territory_name not like 'R&C Partners%' and td.territory_name not like 'WSJ %') and comp.status_flag <<>> 'DELETE'
			group by
			factiva_fit_rating) as factiva_B_number_accounts,
	(
	select
		count(*)
	from
		zoolander_db.pib_account_model_factiva f
	left join dimension_external_db.pib_company_dimension comp on comp.company_sfdc_id = f.sfdc_id
	left join dimension_external_db.pib_territory_dimension td on td.territory_sfdc_id = comp.company_territory
	where
		(cycle_date  = (select max(cycle_date) from zoolander_db.pib_account_model_factiva))
			and factiva_fit_rating = 'C' and (td.territory_name is not null
			and td.territory_name not like 'BD%'
			and td.territory_name not like 'CUSTOMER%' and td.territory_name not like 'FNPEN%' and td.territory_name not like 'Pro Manager %' 
			and td.territory_name not like 'Proquest%' and td.territory_name not like 'Pro SI Territory%'
			and td.territory_name not like 'R&C Partners%' and td.territory_name not like 'WSJ %') and comp.status_flag <<>> 'DELETE'
	group by
			factiva_fit_rating) as factiva_C_number_accounts,
	(
	select
		count(*)
	from
		zoolander_db.pib_account_model_factiva f
	left join dimension_external_db.pib_company_dimension comp on comp.company_sfdc_id = f.sfdc_id
	left join dimension_external_db.pib_territory_dimension td on td.territory_sfdc_id = comp.company_territory
	where
		(cycle_date  = (select max(cycle_date) from zoolander_db.pib_account_model_factiva))
			and factiva_fit_rating = 'D' and (td.territory_name is not null
			and td.territory_name not like 'BD%'
			and td.territory_name not like 'CUSTOMER%' and td.territory_name not like 'FNPEN%' and td.territory_name not like 'Pro Manager %' 
			and td.territory_name not like 'Proquest%' and td.territory_name not like 'Pro SI Territory%'
			and td.territory_name not like 'R&C Partners%' and td.territory_name not like 'WSJ %') and comp.status_flag <<>> 'DELETE'
	group by
			factiva_fit_rating) as factiva_D_number_accounts
from
	zoolander_db.pib_account_model_factiva
where
	(cycle_date  = (select max(cycle_date) from zoolander_db.pib_account_model_factiva))
),

rnc_corporate_counts as (
select
	sfdc_id,
	(
	select
		count(*)
	from
		zoolander_db.pib_account_model_rnc_corporate rc
	left join dimension_external_db.pib_company_dimension comp on comp.company_sfdc_id = rc.sfdc_id
	left join dimension_external_db.pib_territory_dimension td on td.territory_sfdc_id = comp.company_territory
	where
		(cycle_date  = (select max(cycle_date) from zoolander_db.pib_account_model_rnc_corporate))
		and rnc_corporate_fit_rating = 'A' and (td.territory_name is not null
			and td.territory_name not like 'BD%'
			and td.territory_name not like 'CUSTOMER%' and td.territory_name not like 'FNPEN%' and td.territory_name not like 'Pro Manager %' 
			and td.territory_name not like 'Proquest%' and td.territory_name not like 'Pro SI Territory%'
			and td.territory_name not like 'R&C Partners%' and td.territory_name not like 'WSJ %') and comp.status_flag <<>> 'DELETE'
	group by
		rnc_corporate_fit_rating) as rnc_corporate_A_number_accounts,
	(
	select
		count(*)
	from
		zoolander_db.pib_account_model_rnc_corporate rc
	left join dimension_external_db.pib_company_dimension comp on comp.company_sfdc_id = rc.sfdc_id
	left join dimension_external_db.pib_territory_dimension td on td.territory_sfdc_id = comp.company_territory
	where
		(cycle_date  = (select max(cycle_date) from zoolander_db.pib_account_model_rnc_corporate))
			and rnc_corporate_fit_rating = 'B' and (td.territory_name is not null
			and td.territory_name not like 'BD%'
			and td.territory_name not like 'CUSTOMER%' and td.territory_name not like 'FNPEN%' and td.territory_name not like 'Pro Manager %' 
			and td.territory_name not like 'Proquest%' and td.territory_name not like 'Pro SI Territory%'
			and td.territory_name not like 'R&C Partners%' and td.territory_name not like 'WSJ %') and comp.status_flag <<>> 'DELETE'
		group by
			rnc_corporate_fit_rating) as rnc_corporate_B_number_accounts,
	(
	select
		count(*)
	from
		zoolander_db.pib_account_model_rnc_corporate rc
	left join dimension_external_db.pib_company_dimension comp on comp.company_sfdc_id = rc.sfdc_id
	left join dimension_external_db.pib_territory_dimension td on td.territory_sfdc_id = comp.company_territory
	where
		(cycle_date  = (select max(cycle_date) from zoolander_db.pib_account_model_rnc_corporate))
			and rnc_corporate_fit_rating = 'C' and (td.territory_name is not null
			and td.territory_name not like 'BD%'
			and td.territory_name not like 'CUSTOMER%' and td.territory_name not like 'FNPEN%' and td.territory_name not like 'Pro Manager %' 
			and td.territory_name not like 'Proquest%' and td.territory_name not like 'Pro SI Territory%'
			and td.territory_name not like 'R&C Partners%' and td.territory_name not like 'WSJ %') and comp.status_flag <<>> 'DELETE'
		group by
			rnc_corporate_fit_rating) as rnc_corporate_C_number_accounts,
	(
	select
		count(*)
	from
		zoolander_db.pib_account_model_rnc_corporate rc
	left join dimension_external_db.pib_company_dimension comp on comp.company_sfdc_id = rc.sfdc_id
	left join dimension_external_db.pib_territory_dimension td on td.territory_sfdc_id = comp.company_territory
	where
		(cycle_date  = (select max(cycle_date) from zoolander_db.pib_account_model_rnc_corporate))
			and rnc_corporate_fit_rating = 'D' and (td.territory_name is not null
			and td.territory_name not like 'BD%'
			and td.territory_name not like 'CUSTOMER%' and td.territory_name not like 'FNPEN%' and td.territory_name not like 'Pro Manager %' 
			and td.territory_name not like 'Proquest%' and td.territory_name not like 'Pro SI Territory%'
			and td.territory_name not like 'R&C Partners%' and td.territory_name not like 'WSJ %') and comp.status_flag <<>> 'DELETE'
		group by
			rnc_corporate_fit_rating) as rnc_corporate_D_number_accounts
from
	zoolander_db.pib_account_model_rnc_corporate
where
	(cycle_date  = (select max(cycle_date) from zoolander_db.pib_account_model_rnc_corporate))
),

rnc_financial_counts as (
select
	sfdc_id,
	(
	select
		count(*)
	from
		zoolander_db.pib_account_model_rnc_financial rf
	left join dimension_external_db.pib_company_dimension comp on comp.company_sfdc_id = rf.sfdc_id
	left join dimension_external_db.pib_territory_dimension td on td.territory_sfdc_id = comp.company_territory
	where
		(cycle_date  = (select max(cycle_date) from zoolander_db.pib_account_model_rnc_financial))
		and rnc_financial_fit_rating = 'A' and (td.territory_name is not null
			and td.territory_name not like 'BD%'
			and td.territory_name not like 'CUSTOMER%' and td.territory_name not like 'FNPEN%' and td.territory_name not like 'Pro Manager %' 
			and td.territory_name not like 'Proquest%' and td.territory_name not like 'Pro SI Territory%'
			and td.territory_name not like 'R&C Partners%' and td.territory_name not like 'WSJ %') and comp.status_flag <<>> 'DELETE'
	group by
		rnc_financial_fit_rating) as rnc_financial_A_number_accounts,
	(
	select
		count(*)
	from
		zoolander_db.pib_account_model_rnc_financial rf
	left join dimension_external_db.pib_company_dimension comp on comp.company_sfdc_id = rf.sfdc_id
	left join dimension_external_db.pib_territory_dimension td on td.territory_sfdc_id = comp.company_territory
	where
		(cycle_date  = (select max(cycle_date) from zoolander_db.pib_account_model_rnc_financial))
			and rnc_financial_fit_rating = 'B' and (td.territory_name is not null
			and td.territory_name not like 'BD%'
			and td.territory_name not like 'CUSTOMER%' and td.territory_name not like 'FNPEN%' and td.territory_name not like 'Pro Manager %' 
			and td.territory_name not like 'Proquest%' and td.territory_name not like 'Pro SI Territory%'
			and td.territory_name not like 'R&C Partners%' and td.territory_name not like 'WSJ %') and comp.status_flag <<>> 'DELETE'
		group by
			rnc_financial_fit_rating) as rnc_financial_B_number_accounts,
	(
	select
		count(*)
	from
		zoolander_db.pib_account_model_rnc_financial rf
	left join dimension_external_db.pib_company_dimension comp on comp.company_sfdc_id = rf.sfdc_id
	left join dimension_external_db.pib_territory_dimension td on td.territory_sfdc_id = comp.company_territory
	where
		(cycle_date  = (select max(cycle_date) from zoolander_db.pib_account_model_rnc_financial))
			and rnc_financial_fit_rating = 'C' and (td.territory_name is not null
			and td.territory_name not like 'BD%'
			and td.territory_name not like 'CUSTOMER%' and td.territory_name not like 'FNPEN%' and td.territory_name not like 'Pro Manager %' 
			and td.territory_name not like 'Proquest%' and td.territory_name not like 'Pro SI Territory%'
			and td.territory_name not like 'R&C Partners%' and td.territory_name not like 'WSJ %') and comp.status_flag <<>> 'DELETE'
		group by
			rnc_financial_fit_rating) as rnc_financial_C_number_accounts,
	(
	select
		count(*)
	from
		zoolander_db.pib_account_model_rnc_financial rf
	left join dimension_external_db.pib_company_dimension comp on comp.company_sfdc_id = rf.sfdc_id
	left join dimension_external_db.pib_territory_dimension td on td.territory_sfdc_id = comp.company_territory
	where
		(cycle_date  = (select max(cycle_date) from zoolander_db.pib_account_model_rnc_financial))
			and rnc_financial_fit_rating = 'D' and (td.territory_name is not null
			and td.territory_name not like 'BD%'
			and td.territory_name not like 'CUSTOMER%' and td.territory_name not like 'FNPEN%' and td.territory_name not like 'Pro Manager %' 
			and td.territory_name not like 'Proquest%' and td.territory_name not like 'Pro SI Territory%'
			and td.territory_name not like 'R&C Partners%' and td.territory_name not like 'WSJ %') and comp.status_flag <<>> 'DELETE'
		group by
			rnc_financial_fit_rating) as rnc_financial_D_number_accounts
from
	zoolander_db.pib_account_model_rnc_financial
where
	(cycle_date  = (select max(cycle_date) from zoolander_db.pib_account_model_rnc_financial))
)

select fc.*, nc.newswires_A_number_accounts, nc.newswires_B_number_accounts, nc.newswires_C_number_accounts, nc.newswires_D_number_accounts,
rcc.rnc_corporate_A_number_accounts, rcc.rnc_corporate_B_number_accounts, rcc.rnc_corporate_C_number_accounts, rcc.rnc_corporate_D_number_accounts,
rcf.rnc_financial_A_number_accounts, rcf.rnc_financial_B_number_accounts, rcf.rnc_financial_C_number_accounts, rcf.rnc_financial_D_number_accounts,
td.territory_name 
from factiva_counts fc 
left join newswires_counts nc on fc.sfdc_id = nc.sfdc_id
left join rnc_corporate_counts rcc on fc.sfdc_id = rcc.sfdc_id
left join rnc_financial_counts rcf on fc.sfdc_id = rcf.sfdc_id
left join dimension_external_db.pib_company_dimension comp on comp.company_sfdc_id = fc.sfdc_id
left join dimension_external_db.pib_territory_dimension td on td.territory_sfdc_id = comp.company_territory
