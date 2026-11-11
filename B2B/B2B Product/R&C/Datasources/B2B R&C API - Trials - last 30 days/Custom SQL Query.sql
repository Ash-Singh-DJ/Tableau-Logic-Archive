-- Published data source : "B2B R&C API - Trials - last 30 days"  [B2B / B2B Product / R&C / Datasources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
SELECT pib_opportunity_sfdc_id, billing_account, opportunity_name, trial_flag, sale_type, lead_source, net_change, one_time_charge, opportunity_weighted_revenue / 12 as weighted_revenue, open_date, probability_percentage, fiscal_quarter, fiscal_year, created_date, opportunity_owner, account_name, product_line, product_category, product_service
FROM dimension_external_db.pib_opportunity_dimension od left join (select opportunity, product_line, product_category, product_service, net_change, one_time_charge from dimension_external_db.pib_product_services_dimension group by 1,2,3,4,5,6) pd
	on od.pib_opportunity_sfdc_id = pd.opportunity
WHERE open_date >>= current_date - interval '30' DAY AND open_date << current_date - interval '1' DAY
AND (lower(opportunity_name) LIKE '%trial%' or trial_flag = true)
and product_service in ('Adverse Media Analytics API','Adverse Media Search - API','Adv Media-Structured Profiles (Entities)-API','Batch Screening API','Cities & Ports – API','Dual-Use Goods-API','Marijuana-Related Business API','Money Services Businesses API','Risk API Sandbox Environment','Risk Database Premium API','SAM API Plus-Adv Md(Ents)','SAM API Plus-SOC','SAM API Plus-Watchlist','Scr&Mon-AdvMedia (Entities)-API','Scr&Mon-State-Owned Companies-API','Screening & Monitoring - Watchlist - API','State-Owned Companies-API','Watchlist-API')
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19
