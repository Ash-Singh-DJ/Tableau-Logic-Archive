-- Dashboard   : "B2B Single Day Users on Factiva"  [B2B / Factiva Legacy (for review)]
-- Data source : "Last Page 2" = published source "B2B Single Day Users on Factiva - Last Page 2"  [B2B / B2B Product / Factiva / Datasources]
-- Relation    : Custom SQL "Cluster Group"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with lena as (
select cycle_date, eid, cluster_name from sandbox_mk.factiva_user_seg_12mo)

select cycle_date, eid, cluster_name from lena

where cycle_date = (select max(cycle_date) from lena lenb where lena.EID = lenb.EID)
order by eid
