-- Published data source : "B2B R&C API - Partner Count of API Customers"  [B2B / B2B Product / R&C / Datasources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select delivery_channel_s, pd.partner, opportunity_owner, sale_type, opportunity_number, probability_percentage, adjusted_effective_date, opportunity_name, annualized_opportunity_revenue, lead_source, open_date, pd.name, product_service, account_name, product_line
from dimension_external_db.pib_opportunity_dimension od left join (select name, opportunity, delivery_channel_s, partner, delivery_product, product_service, product_line, adjusted_effective_date from dimension_external_db.pib_product_services_dimension where status_flag <<>> 'DELETE' group by 1,2,3,4,5,6,7,8) pd
	on od.pib_opportunity_sfdc_id = pd.opportunity
where sales_stage = 'Closed (Win/Loss)'
and (delivery_channel_s not in ('Not Applicable','Other') or delivery_channel_s is null)
and delivery_product = 'Risk & Compliance'
and product_service in ('Adverse Media Analytics API','Adverse Media Search - API','Adv Media-Structured Profiles (Entities)-API','Batch Screening API','Cities & Ports – API','Dual-Use Goods-API','Marijuana-Related Business API','Money Services Businesses API','Risk API Sandbox Environment','Risk Database Premium API','SAM API Plus-Adv Md(Ents)','SAM API Plus-SOC','SAM API Plus-Watchlist','Scr&Mon-AdvMedia (Entities)-API','Scr&Mon-State-Owned Companies-API','Screening & Monitoring - Watchlist - API','State-Owned Companies-API','Watchlist-API')
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
order by 1,5
