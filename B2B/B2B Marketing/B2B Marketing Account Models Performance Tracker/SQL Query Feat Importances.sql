-- Dashboard   : "B2B Marketing Account Models Performance Tracker"  [B2B / B2B Marketing]
-- Data source : "SQL Query Feat Importances" (embedded in the workbook)
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / zoolander_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select * from zoolander_db.account_model_factiva_feat_importance
where cycle_date = (select max(cycle_date) from zoolander_db.account_model_factiva_feat_importance)
union
select * from zoolander_db.account_model_newswires_feat_importance
where cycle_date = (select max(cycle_date) from zoolander_db.account_model_newswires_feat_importance)
union
select * from zoolander_db.account_model_rnc_corporate_feat_importance
where cycle_date = (select max(cycle_date) from zoolander_db.account_model_rnc_corporate_feat_importance)
union
select * from zoolander_db.account_model_rnc_financial_feat_importance
where cycle_date = (select max(cycle_date) from zoolander_db.account_model_rnc_financial_feat_importance)
order by model_name
