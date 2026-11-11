-- Published data source : "B2B R&C API Pipeline"  [B2B / B2B Product / R&C / Datasources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
SELECT sales_stage, opportunity_name, opportunity_number, in_forecast, opportunity_effective_date, account_name, opportunity_owner, psd.specialist, td.region_code, psd.product_line, psd.status, probability_percentage, pipeline_category, annualized_opportunity_revenue, total_one_time_revenue, total_opportunity_one_time_revenue, sale_type, psd.name, psd.product_category, psd.product_service, opportunity_total_monthly_recurring_revenue, opportunity_territory, last_activity_date
FROM dimension_external_db.pib_opportunity_dimension od
	left join (SELECT territory_sfdc_id, territory_name, region_code
	FROM dimension_external_db.pib_territory_dimension
	group by 1,2,3) td on od.opportunity_territory = td.territory_sfdc_id
	
	left join (SELECT name, opportunity, product_line, product_category, product_service, specialist, status
	FROM dimension_external_db.pib_product_services_dimension
	where status_flag <<>> 'DELETE'
	group by 1,2,3,4,5,6,7) psd on od.pib_opportunity_sfdc_id = psd.opportunity

WHERE sale_type IN ('New To Company','Upsell - New Contract','Upsell - Existing Contract')
AND account_name <<>> 'ZZZ Internal Factiva Accounts-Admin Portal'
AND probability_percentage >>= 5 AND probability_percentage <<= 99
and territory_name not like '%BD%' and territory_name not like '%Pro %' and territory_name not like '%Choice%' and territory_name not like '%Proquest%' and territory_name not like '%Partners%' and territory_name not like '%WSJ%' and territory_name not like '%CSTE%' and territory_name not like '%FNPEN%' and territory_name not like '%BCI%' and territory_name not like '%OPIS%'
and product_line = 'Risk & Compliance'
and product_service in ('Adverse Media Analytics API','Adverse Media Search - API','Adv Media-Structured Profiles (Entities)-API','Batch Screening API','Cities & Ports – API','Dual-Use Goods-API','Money Services Businesses API','Risk API Sandbox Environment','Risk Database Premium API','SAM API Plus-Adv Md(Ents)','SAM API Plus-SOC','SAM API Plus-Watchlist','Scr&Mon-AdvMedia (Entities)-API','Scr&Mon-State-Owned Companies-API','Screening & Monitoring - Watchlist - API','State-Owned Companies-API','Watchlist-API','UBO - API')
and CASE
    WHEN month(last_activity_date) >>= 7 THEN year(last_activity_date) + 1
    ELSE year(last_activity_date)
  END
  IN (
    CASE WHEN month(current_date) >>= 7 THEN year(current_date) + 1 ELSE year(current_date) END,
    CASE WHEN month(current_date) >>= 7 THEN year(current_date) + 2 ELSE year(current_date) + 1 END
  )
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23
