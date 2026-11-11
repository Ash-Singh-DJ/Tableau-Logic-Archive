-- Dashboard   : "B2B Factiva Retention Model Dashboard 3.0"  [B2B / B2B Sales / Product Usage]
-- Data source : "Churn Outputs and Explanations" (embedded in the workbook)
-- Relation    : Custom SQL "Churn Prediction Explanations"
-- Connection  : Athena (AwsDataCatalog / zoolander_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select * from zoolander_db.churn_v2_prediction_explanations  
where cycle_date = (select max(cycle_date) from zoolander_db.churn_v2_prediction_explanations)
