-- Published data source : "B2B Forecast Datasource"  [B2B / B2B Sales / Sales Leadership & Operations / Datasources]
-- Relation    : Custom SQL "Product Service mapping"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
SELECT
	product_service
	, product_line
	, CASE
	    WHEN product_line IN
	        ('Factiva'
	        , 'Curation Services'
	        , 'DJX')
	        THEN 'K&I'
	    WHEN product_line IN
	        ('Risk & Compliance')
	        THEN 'R&C'
	    WHEN product_line IN
	        ('Newswires')
	        THEN 'NAD'
	    ELSE UPPER(product_line)
	  END AS bu
	, 'SFDC Product Service Attributes' AS lookup_source
	FROM dimension_external_db.pib_product_service_attributes
	
	UNION ALL
	
	SELECT
	sfdc_product AS product_service
	, product_line
	, bu
	, 'Legacy Product Dimension' AS lookup_source
	FROM reference_external_db.pib_product_dimension
	WHERE sfdc_product NOT IN (SELECT product_service FROM dimension_external_db.pib_product_service_attributes)
	AND sfdc_product IS NOT null
