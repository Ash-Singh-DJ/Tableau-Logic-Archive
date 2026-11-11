-- Dashboard   : "B2B Factiva Retention Model Dashboard 3.0"  [B2B / B2B Sales / Product Usage]
-- Data source : "Churn Outputs and Explanations" (embedded in the workbook)
-- Relation    : Custom SQL "Territories, Owners, Etc"
-- Connection  : Athena (AwsDataCatalog / zoolander_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
SELECT comp.company_sfdc_id, td.territory_name, td.territory_roll_up, usr.user_full_name AS territory_owner,
        rsd_usr.user_full_name AS regional_sales_director
FROM dimension_external_db.pib_company_dimension comp
LEFT JOIN dimension_external_db.pib_territory_dimension td ON comp.company_territory = td.territory_sfdc_id
LEFT JOIN dimension_external_db.pib_user_dimension usr ON td.territory_owner = usr.user_sfdc_id 
LEFT JOIN dimension_external_db.pib_user_dimension rsd_usr ON td.regional_sales_director = rsd_usr.user_sfdc_id
GROUP BY 1, 2, 3, 4, 5
