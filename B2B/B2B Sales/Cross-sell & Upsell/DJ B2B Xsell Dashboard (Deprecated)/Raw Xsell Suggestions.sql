-- Dashboard   : "DJ B2B Xsell Dashboard (Deprecated)"  [B2B / B2B Sales / Cross-sell & Upsell]
-- Data source : "Raw Xsell Suggestions" (embedded in the workbook)
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / sandbox_hvc), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
SELECT 
    xs.*, 
    CASE WHEN substr(targeted_product, 1, 4) = 'FTVA' THEN 'Factiva' 
        WHEN substr(targeted_product, 1, 4) = 'RNC ' THEN 'Risk & Compliance' 
        WHEN substr(targeted_product, 1, 4) = 'NWRS' THEN 'Newswires' END brand, 
    regexp_extract(targeted_product, '[A-Z]+ - (.+)', 1) product_group, 
    comp.company_name, 
    ter.territory_name AS sales_territory, 
    usr.user_full_name AS account_owner, 
    usr2.user_full_name AS regional_sales_director, 
    firm.region, 
    firm.country, 
    firm.state, 
    firm.is_multinational AS multinational, 
    firm.is_large_company AS large_company 
FROM sandbox_mk.temp_table xs 
LEFT JOIN dimension_external_db.pib_company_dimension comp 
	ON xs.target_sfdc_id = comp.company_sfdc_id 
LEFT JOIN dimension_external_db.pib_territory_dimension ter 
	ON ter.territory_sfdc_id = comp.company_territory 
LEFT JOIN dimension_external_db.pib_user_dimension usr 
	ON ter.territory_owner = usr.user_sfdc_id 
LEFT JOIN dimension_external_db.pib_user_dimension usr2 
	ON ter.regional_sales_director = usr2.user_sfdc_id 
LEFT JOIN sandbox_hvc.firmographic_summary firm 
	ON xs.targeted_duns = firm.duns_number
