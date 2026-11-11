-- Dashboard   : "FY24 Profiler Dashboard"  [B2B / One DJ - High Value Customer / Historical Fiscal Year Profilers]
-- Data source : "Date Display" (embedded in the workbook)
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
-- Mini data source to display the last-update dates of each Brand in the Profiler Dataset

-- max_date represents the start of the month for the 'automated' block
WITH max_date AS (
	SELECT 
		max(date) AS maxdate, 
		YEAR(max(date)) AS max_year,
		MONTH(max(date)) AS max_month, 
		date_add('month', 1, date(concat(CAST(YEAR(max(date)) AS varchar), '-', CAST(MONTH(max(date)) AS varchar), '-01'))) AS maxdate_reporting 
	FROM sandbox_hvc.date_alignment 
), 

-- desync_date represents the start of the month for the non-automated 'desync' block
desync_date AS (
	SELECT 
		max(date) AS desync, 
		YEAR(max(date)) AS desync_year,
		MONTH(max(date)) AS desync_month, 
		date_add('month', 1, date(concat(CAST(YEAR(max(date)) AS varchar), '-', CAST(MONTH(max(date)) AS varchar), '-01'))) AS desync_reporting 
	FROM sandbox_hvc.date_alignment_desync 
), 


-- B2B Section (Factiva, Risk & Compliance, Newswires)
b2b_unroll AS (
	SELECT 
		'B2B' AS category1, 
		'PIB Salesforce' AS crm1, 
		'TM1 Reports' AS billing1, 
		'Factiva' AS brand1, 
		(SELECT maxdate_reporting FROM max_date) AS last_updated 
	UNION ALL 
	SELECT 
		'B2B' AS category1, 
		'PIB Salesforce' AS crm1, 
		'TM1 Reports' AS billing1, 
		'Risk & Compliance' AS brand1, 
		(SELECT maxdate_reporting FROM max_date) AS last_updated 
	UNION ALL 
	SELECT 
		'B2B' AS category1, 
		'PIB Salesforce' AS crm1, 
		'TM1 Reports' AS billing1, 
		'Newswires' AS brand1, 
		(SELECT maxdate_reporting FROM max_date) AS last_updated 
), 


-- Non-Core Energy Section (Chemical Market Analytics, Coal Metals & Mining)
energy_unroll AS (
	SELECT 
		'Energy' AS category1, 
		'PIB Salesforce' AS crm1, 
		'Salesforce Opps Pipeline' AS billing1, 
		'Chemical Market Analytics' AS brand1, 
		(SELECT maxdate_reporting FROM max_date) AS last_updated 
	UNION ALL 
	SELECT 
		'Energy' AS category1, 
		'PIB Salesforce' AS crm1, 
		'Salesforce Opps Pipeline' AS billing1, 
		'Coal, Metals & Mining' AS brand1, 
		(SELECT maxdate_reporting FROM max_date) AS last_updated 
), 


-- Core Energy Section (OPIS Core)
opis_unroll AS (
	SELECT 
		'Energy' AS category1, 
		'OPIS Netsuite' AS crm1, 
		'Netsuite Book of Business' AS billing1, 
		'OPIS Core' AS brand1, 
		(SELECT maxdate_reporting FROM max_date) AS last_updated 
), 


-- WSJ Section (WSJ Pro, WSJ Corporate)
wsj_unroll AS (
	SELECT 
		'B2B' AS category1, 
		'PIB Salesforce' AS crm1, 
		'Jasper Reports' AS billing1, 
		'WSJ Pro' AS brand1, 
		(SELECT maxdate_reporting FROM max_date) AS last_updated 
	UNION ALL 
	SELECT 
		'B2B' AS category1, 
		'PIB Salesforce' AS crm1, 
		'Jasper Reports' AS billing1, 
		'WSJ Corporate' AS brand1, 
		(SELECT maxdate_reporting FROM max_date) AS last_updated 
), 


-- Advertising Section (Digital and Non-Digital Advertising)
adtech_unroll AS ( 
	SELECT 
		'Advertising' AS category1, 
		'AdTech Salesforce' AS crm1, 
		'ADW Database' AS billing1, 
		'Digital Advertising' AS brand1, 
		(SELECT maxdate_reporting FROM max_date) AS last_updated 
	UNION ALL 
	SELECT 
		'Advertising' AS category1, 
		'AdTech Salesforce' AS crm1,  
		'ADW Database' AS billing1, 
		'Non-Digital Advertising' AS brand1, 
		(SELECT maxdate_reporting FROM max_date) AS last_updated 
), 


-- C-Suite Section (C-Suite)
csuite_unroll AS (
	SELECT 
		'B2B' AS category1, 
		'PIB Salesforce + Cvent' AS crm1, 
		'Salesforce Opps + Cvent Memberships' AS billing1, 
		'C-Suite' AS brand1, 
		(SELECT maxdate_reporting FROM max_date) AS last_updated 
), 


-- Non-Advertising Partnerships Section (Corporate Partnerships)
corp_partner_unroll AS (
	SELECT 
		'Partnerships' AS category1, 
		'Bespoke deals (no CRM)' AS crm1, 
		'Google Sheets' AS billing1, 
		'Corporate Partnership' AS brand1, 
		(SELECT desync_reporting FROM desync_date) AS last_updated 
), 


-- Advertising Partnerships Section (Advertising Partnerships)
adv_partner_unroll AS (
	SELECT 
		'Partnerships' AS category1, 
		'Bespoke deals (no CRM)' AS crm1, 
		'Google Sheets' AS billing1, 
		'Advertising Partnership' AS brand1, 
		(SELECT desync_reporting FROM desync_date) AS last_updated 
), 


-- B2B Partnerships Section (PAL Accounts)
b2b_partner_unroll AS (
	SELECT 
		'Partnerships' AS category1, 
		'PIB Salesforce' AS crm1, 
		'TM1 Reports' AS billing1, 
		'Factiva Partnership' AS brand1, 
		(SELECT maxdate_reporting FROM max_date) AS last_updated 
	UNION ALL 
	SELECT 
		'Partnerships' AS category1, 
		'PIB Salesforce' AS crm1, 
		'TM1 Reports' AS billing1, 
		'Risk & Compliance Partnership' AS brand1, 
		(SELECT maxdate_reporting FROM max_date) AS last_updated 
	UNION ALL 
	SELECT 
		'Partnerships' AS category1, 
		'PIB Salesforce' AS crm1, 
		'TM1 Reports' AS billing1, 
		'Newswires Partnership' AS brand1, 
		(SELECT maxdate_reporting FROM max_date) AS last_updated 
) 


SELECT * FROM b2b_unroll 
UNION ALL 
SELECT * FROM adtech_unroll 
UNION ALL 
SELECT * FROM energy_unroll 
UNION ALL 
SELECT * FROM opis_unroll 
UNION ALL 
SELECT * FROM wsj_unroll 
UNION ALL 
SELECT * FROM csuite_unroll 
UNION ALL 
SELECT * FROM corp_partner_unroll 
UNION ALL 
SELECT * FROM adv_partner_unroll 
UNION ALL 
SELECT * FROM b2b_partner_unroll
