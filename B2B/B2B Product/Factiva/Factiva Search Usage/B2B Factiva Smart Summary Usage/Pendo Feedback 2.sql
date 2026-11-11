-- Dashboard   : "B2B Factiva Smart Summary Usage"  [B2B / B2B Product / Factiva / Factiva Search Usage]
-- Data source : "Pendo Feedback 2" = published source "Pendo Feedback 2"  [B2B / B2B Content Licensing- PAL]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with  
jf as 
(select pib_member_id, department_code, job_function_code_last_updated_at 
from dimension_external_db.pib_membership_dimension 
where job_function_code_last_updated_at is not null
and department_code <<>> 'OT')


select 
user_info_user_ref as EID, mem.user_id, mem.first_name, mem.last_name, mem.email, mem.billing_account_id, comp.company_name, comp.company_industry, 
jf.department_code,

count(distinct case when product = 'Factiva' and (event_name = 'page_view' or event_name = 'user_action') then visit_id end) as  f_visits,
count(distinct case when product = 'New Factiva' and (event_name = 'page_view' or event_name = 'user_action') then visit_id end) as nf_visits


from pib_event_data.pib_product_metrics djm
LEFT JOIN dimension_external_db.pib_billing_account_dimension bad on djm.user_info_account_id = bad.cibs_billing_account_id
LEFT JOIN dimension_external_db.pib_company_dimension comp on comp.company_sfdc_id = bad.salesforce_company_two
LEFT JOIN dimension_external_db.pib_membership_dimension mem ON mem.pib_member_id = djm.user_info_user_ref
left join jf on mem.pib_member_id = jf.pib_member_id
where product in ('Factiva', 'New Factiva')
and user_info_user_ref in ('E6OO2HVCQHVPEKOJVPIZBZ36TU',
'E6OO2HVCQHVPFX4U7JSMHOGN5I',
'E6OO2HVCQHVPFOMOHRN6PGXV6Y',
'D3WZYJYBD4BQBBE5OG5Q6BIDAA',
'D3WZYJYBD4BQBSY2QVYCL5QGAA',
'E6OO2HVCQHVPFX4U7JSMHOGN5I',
'D3WZYJYBD4BQBBE5OG5Q6BIDAA',
'D3WZYJYBD4BQBBE5OG5Q6BIDAA',
'D3WZYJ7S5KA2FXYYWFNZ2EYEKI',
'D3WZYJ7S5KA2FRP6IPIUK764W4',
'D3WZYJ7S5KA2FRP6IPIUK764W4',
'D3WZYJ7S5KA2E73IYYLQNZTM4U',
'D3WZYJYBD4BQBLPE5KBNATYAAA',
'D3WZYJ7S5KA2FCFHPXTVVEH4CQ',
'E6OO2HVCQHVPFX4U7JSMHOGN5I',
'D3WZYJ7S5KA2EWRQTHTQGKD3BE',
'D3WZYJ7S5KA2EZYUMZVTXFKE6I',
'D3WZYJYBD4BQBVDREOXOOGYAAA',
'D3WZYJYBD4BQBZCCNH6HUSIDAA',
'E6OO2HVCQHVPFX4U7JSMHOGN5I',
'D3WZYJ7S5KA2ENRESCA2JOBCUM',
'D3WZYJ7S5KA2E7DVOXBKWFPM4M',
'E6OO2HVCQHVPFX4U7JSMHOGN5I',
'D3WZYJ7S5KA2E5UDVXXX63LVFQ',
'D3WZYJ7S5KA2FETYG7DOHIP434',
'E6OO2HVCQHVPE52XOST2H5SMOA',
'E6OO2HVCQHVPF6KPINC5OAN4KM',
'E6OO2HVCQHVPFHBVRQYZMZUFE4',
'D3WZYJ7S5KA2FUDB6DRC7R6D5U',
'E6OO2HVCQHVPF6KPINC5OAN4KM',
'E6OO2HVCQHVPFHBVRQYZMZUFE4',
'D3WZYJ7S5KA2EABPMLDKEMJOUU',
'E6OO2HVCQHVPEE5MBHL2YDQLNI',
'D3WZYJ7S5KA2ERU4T5U4K5AH7U',
'E6OO2HVCQHVPEHHS7WFN54PGAI',
'E6OO2HVCQHVPF2I77PBGNQKJQQ',
'D3WZYJYBD4BQBL2H7JPHNSYAAA',
'D3WZYJYBD4BQAPAMSHAK54YBAA',
'E6OO2HVCQHVPFLUSSST2DAPTIU',
'D3WZYJ7S5KA2E6RRMDGC32G4A4',
'D3WZYJ7S5KA2F7CVR24FZ5KUHY',
'E6OO2HVCQHVPEKOJVPIZBZ36TU',
'E6OO2HVCQHVPF6KPINC5OAN4KM',
'D3WZYJ7S5KA2EABPMLDKEMJOUU',
'D3WZYJYBD4BQAKD7SM3EGUYAAA')


and cycle_date >>= date_add('day', -90, current_date)
group by 1,2,3,4,5,6,7,8,9
