-- Published data source : "B2B R&C API - Welcome letter cases - past Quarter"  [B2B / B2B Product / R&C / Datasources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
SELECT product_level_2, owner_id, company_name, subject, TYPE AS case_type, opened_date, closed_date, account_id, billing_account_number
FROM dimension_external_db.pib_customer_service_case_dimension
WHERE lower(case_sub_type) LIKE '%welcome package%'
AND status = 'Closed'
AND product_level_2 IN ('Legacy R&C (Database/Search API)','R&C (Adverse Media Search API)','R&C (Database/Search API v2)','R&C (Due Diligence Reports API)','R&C (Screening & Monitoring API)','R&C (Trade Compliance API)')
AND year(closed_date) = 
        CASE 
            WHEN quarter(current_date) = 1 THEN year(current_date) - 1
            ELSE year(current_date)
        END
    AND quarter(closed_date) = 
        CASE 
            WHEN quarter(current_date) = 1 THEN 4
            ELSE quarter(current_date) - 1
        END
GROUP BY 1,2,3,4,5,6,7,8,9
ORDER BY 6 DESC
