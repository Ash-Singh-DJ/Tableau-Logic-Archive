-- Published data source : "B2B R&C API - Escalations created (month)"  [B2B / B2B Product / R&C / Datasources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
SELECT case_number, subject, description, status, opened_date, closed_date, last_modified_date, product_level_1, product_level_2, product_level_3, priority
FROM dimension_external_db.pib_customer_service_case_dimension
WHERE opened_date >>= current_date - INTERVAL '30' DAY
AND (product_level_1 IN ('API','CMA','Factiva','Multi-product','Newswires','OPIS','Other','Risk & Compliance','WSJ Pro')
	OR product_level_1 IS NULL)
AND product_level_2 IN ('Legacy R&C (Database/Search API)','R&C (Adverse Media Search API)','R&C (Database/Search API v2)','R&C (Screening & Monitoring API)','R&C (Trade Compliance API)')
GROUP BY 1,2,3,4,5,6,7,8,9,10,11
