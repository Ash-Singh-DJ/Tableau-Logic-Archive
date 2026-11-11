-- Published data source : "B2B Factiva Article Views by Source: Comparative Views - Smart Summary backend"  [B2B / B2B Product / Factiva / Datasources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with src as
(WITH total_codes AS (
  SELECT sc.SourceCode, SourceName, royalty_provider_code, ipcode, ipname, Language, PST, RightsCode,
         sg.GroupCode as CountryCode, sg.GroupName as CountryName,
         CASE WHEN djs.GroupCode IS NOT NULL THEN 'DJ' ELSE 'Non-DJ' END DJ_Source_Flag,
         CASE WHEN tt.GroupCode IS NOT NULL THEN 'Think Tank' ELSE 'Other' END Think_Tank_Flag,
         ROW_NUMBER() OVER(PARTITION BY sc.SourceCode) AS rk
  FROM sandbox_mk.factiva_content_source_current sc
  LEFT JOIN (SELECT SourceCode, GroupCode, GroupName
             FROM sandbox_mk.factiva_content_source_group_current 
             WHERE GroupTypeCode in ('roo','ROO')
               AND GroupCode IN (SELECT CountryCode FROM sandbox_mk.full_roo_table)) sg ON sc.SourceCode = sg.SourceCode
  LEFT JOIN (SELECT SourceCode, GroupCode
             FROM sandbox_mk.factiva_content_source_group_current 
             WHERE lower(GroupCode) = 'tdjp') djs ON sc.SourceCode = djs.SourceCode
  LEFT JOIN (SELECT SourceCode, GroupCode
             FROM sandbox_mk.factiva_content_source_group_current 
             WHERE lower(GroupCode) = 'ttank') tt ON sc.SourceCode = tt.SourceCode)
             
SELECT *
FROM total_codes
WHERE rk=1)





select substring(cast(letters_request_date_time as varchar),1,10) year_month_day, begin_letter_account_code as billing_account, mem.pib_member_id, letters_publication_code, UPPER(src.SourceCode) as SourceCode, src.CountryName, 
src.SourceName, src.royalty_provider_code, comp.company_name,

UPPER(case when substring(ce.letters_accession_number, 1, strpos(ce.letters_accession_number,'0')-1) like '%2%' then
substring(ce.letters_accession_number, 1, strpos(ce.letters_accession_number,'2')-1) else
substring(ce.letters_accession_number, 1, strpos(ce.letters_accession_number,'0')-1) end) as sc3,




src.Language,  src.ipcode, src.ipname, 'genai' as type

from publisher_reporting_db.commerce_envelope ce 
inner join dimension_external_db.pib_membership_dimension mem on ce.begin_letter_eid = mem.pib_member_id
left join dimension_external_db.pib_billing_account_dimension bill on mem.billing_account_id = bill.cibs_billing_account_id 
left join dimension_external_db.pib_company_dimension comp on bill.salesforce_company_two = comp.company_sfdc_id 
left join src on UPPER(case when substring(ce.letters_accession_number, 1, strpos(ce.letters_accession_number,'0')-1) like '%2%' then
substring(ce.letters_accession_number, 1, strpos(ce.letters_accession_number,'2')-1) else
substring(ce.letters_accession_number, 1, strpos(ce.letters_accession_number,'0')-1) end) = src.SourceCode

where letters_function_code = 'VAI01'
and begin_letter_access_point_code = 'AIM'
and letters_request_date_time >>= cast('2024-11-01' as date)
and ce.letters_accession_number not like 'WC%'


union all



select SUBSTRING(CAST(cycle_date AS varchar), 1, 10) year_month_day, mem.billing_account_id, mem.pib_member_id, null as letters_publication_code,   
UPPER(src.SourceCode) as SourceCode, src.CountryName, 
src.SourceName, src.royalty_provider_code, comp.company_name,

UPPER(substring(ti_td_page_content_source_code, 12, (strpos(ti_td_page_content_source_code,']')-13))) as sc3,

src.Language,  src.ipcode, src.ipname, 'click' as type

from pib_event_data.pib_product_metrics djm
join dimension_external_db.pib_membership_dimension mem on djm.user_info_user_ref = mem.pib_member_id 
left join dimension_external_db.pib_billing_account_dimension bill on mem.billing_account_id = bill.cibs_billing_account_id 
left join dimension_external_db.pib_company_dimension comp on bill.salesforce_company_two  = comp.company_sfdc_id 
left join src on UPPER(substring(djm.ti_td_page_content_source_code, 12, (strpos(djm.ti_td_page_content_source_code,']')-13))) = src.SourceCode 
where cycle_date >>= cast('2024-11-01' as date)


and product ='New Factiva'
and event_name in ('user_action', 'page_view')
and ti_td_article_id is not null
and ti_td_module_tracker like '%searchSummary%'
