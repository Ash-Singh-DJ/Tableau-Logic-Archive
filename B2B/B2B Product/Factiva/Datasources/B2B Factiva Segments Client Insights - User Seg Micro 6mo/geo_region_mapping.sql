-- Published data source : "B2B Factiva Segments Client Insights - User Seg Micro 6mo"  [B2B / B2B Product / Factiva / Datasources]
-- Relation    : Custom SQL "geo_region_mapping"
-- Connection  : Athena (AwsDataCatalog / zoolander_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with territory_region_map as
(
select td.territory_name, case when substring(td.territory_name,1,3) = 'AME' 
or td.territory_name = 'GAT AMEX'
or td.territory_name = 'GAT BCG'
or td.territory_name = 'GAT BOA'
or td.territory_name = 'GAT BOOZ ALLEN'
or td.territory_name = 'GAT CITIGROUP'
or td.territory_name = 'GAT D & T'
or td.territory_name = 'GAT Goldman'
or td.territory_name = 'GAT JP Morgan'
or td.territory_name = 'GAT KPMG'
or td.territory_name = 'GAT McKinsey'
or td.territory_name = 'GAT MITSUBISHI'
or td.territory_name = 'GAT MMC'
or td.territory_name = 'GAT Morgan Stanley'
or td.territory_name = 'GAT NEWS CORP'
or td.territory_name = 'GAT PWC'
or td.territory_name = 'GAT WPP'
or td.territory_name = 'GAT BARCLAYS'
or td.territory_name = 'GAT X'
then 'AME'
when substring(td.territory_name,1,4) = 'EMEA' 
or td.territory_name = 'GAT ACCENTURE'
or td.territory_name = 'GAT Bain'
or td.territory_name = 'GAT BP AMOCO'
or td.territory_name = 'GAT Credit Suisse'
or td.territory_name = 'GAT Deutsche'
or td.territory_name = 'GAT EY'
or td.territory_name = 'GAT HSBC'
or td.territory_name = 'GAT NOMURA'
or td.territory_name = 'GAT SUMITOMO'
or td.territory_name = 'GAT UBS'
or td.territory_name = 'R&C Partners - EMEA'
or td.territory_name = 'SAT UBS'
or td.territory_name = 'UKIA UK'
then 'EMEA'
when substring(td.territory_name,1,2) = 'AP' then 'APAC'
when td.territory_name like 'Pro%'
or td.territory_name like 'WSJ Pro%'
or td.territory_name like 'CTSE%'
or td.territory_name like 'C-Suite%'
or td.territory_name like 'Corporate%'
then 'WSJ'
when td.territory_name like 'OPIS%'
then 'OPIS'
when td.territory_name like 'WSJ Corporate%'
or td.territory_name like 'WSJ BD%'
or td.territory_name like 'BD%'
or td.territory_name like 'CP%'
or td.territory_name = 'Proquest'
then 'PAL'
else 'Other'
end as geo_region from dimension_external_db.pib_territory_dimension td
)

select * from territory_region_map
