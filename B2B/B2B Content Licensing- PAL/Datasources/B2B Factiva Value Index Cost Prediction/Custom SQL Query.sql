-- Published data source : "B2B Factiva Value Index Cost Prediction"  [B2B / B2B Content Licensing- PAL / Datasources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / sandbox_mk), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
--- Value Index Score Dashboard Query ---
with contract_info as (
select gmff.rpc_id, gmff.contract_type, gmff.cycle_date as gmff_cycle_date
, rm.source_code 
from dimension_external_db.royalty_monthly_guaranteed_minimum_report gmff 
left join dimension_external_db.royalty_monthly_management_report rm
	on gmff.rpc_id = rm.royalty_provider_code and gmff.cycle_date = rm.cycle_date 
--where gmff.cycle_date = (select max(cycle_date) from dimension_external_db.royalty_monthly_guaranteed_minimum_report)
order by gmff.cycle_date desc
),

vi_data as (
select distinct * from sandbox_mk.factiva_content_value_index_ui
where (period = (select max(period) from sandbox_mk.factiva_content_value_index_ui) 
		or (period = date('2024-06-01') and cycle_date = date('2024-10-29'))
		or (period = date('2024-09-01') and cycle_date = date('2025-03-21'))
		or (period = date('2024-10-01') and cycle_date = date('2025-04-21'))
		or (period = date('2024-11-01') and cycle_date = date('2025-04-22'))
		)
)

select distinct vi.*, ci.rpc_id
, case when ci.rpc_id = 'HKECJ' and ci.gmff_cycle_date in (date('2024-12-01'), date('2024-06-01')) then 'FF, GM' 
		else ci.contract_type end as contract_type
, ci.gmff_cycle_date
from vi_data vi
left join contract_info ci
	on vi.source_code = ci.source_code and vi.period = ci.gmff_cycle_date
