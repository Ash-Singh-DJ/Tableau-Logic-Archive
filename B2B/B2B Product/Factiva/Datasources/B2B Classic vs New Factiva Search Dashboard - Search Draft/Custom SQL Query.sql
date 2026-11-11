-- Published data source : "B2B Classic vs New Factiva Search Dashboard - Search Draft"  [B2B / B2B Product / Factiva / Datasources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with lv as 
(select mem.pib_member_id, product, count(distinct user_info_session_id) sesh_count,

count(distinct case when (ti_td_page_content_type = 'SearchResults'
and (ti_td_page_section = 'Search' or ti_td_page_section = 'Home') and djm.Product = 'Factiva')
or 
(ti_td_page_content_type = 'ResearchTools' 
and ti_td_page_content_type_detail = 'search results'
and ti_td_search_record_type is not null and djm.Product = 'New Factiva')
and event_name = 'page_view' 
then user_info_session_id end) search_sesh_count


from pib_event_data.pib_product_metrics djm
inner join dimension_external_db.pib_membership_dimension mem on djm.user_info_user_ref = mem.pib_member_id  
where djm.product in ('Factiva', 'New Factiva')
group by 1,2)

select substring(cast(cycle_date as varchar),1,7) year_month, mem.pib_member_id , mem.user_id, djm.product, comp.company_name, bill.cibs_billing_account_id, mem.plan_id,
(CASE when mem.plan_id in ('0001','0003','0004','0005','0007','0009','0010','0011','0013','0016','0017','0018','0019','0021','0023','0024', '0086', '0087',
'0026','0027','0032','0035','0039','0047','0048','0053','0054','0055','0057','0060','0063','0064','0068','0069','0071','0073','0074',
'0075','0076','0077','0078','0081','0085','0092','0096','0098','0101','0102','0103','0106','0107','0108','0110','0111','0120','0121','0122',
'0123','0129','0132','0133','0134','0135','0144','0146','0147','0152','0154','0159','0161','0162','0169','0170','0179','0180','0181','0182',
'0184','0186','0188','0190','0191','0192','0193','0194','0197','0198','0199','0202','0203','0204','0206','0209','0210','0211','0212','0214',
'0215','0216','0217','0218','0219','0220','0221','0222','0223','0225','0226','0227','0228','0229','0230','0234','0251','0254','0257','0259',
'0263','0265','0267','0268','0276','0296','0297','0302','0303','0314','0315','0324','0327','0332','0349','0355','0357','0365','0369','0371',
'0374','0376','0377','0378','0381','0383','0389','0391','0395','0401','0402','0406','0407','0408','0412','0414','0416','0417','0427','0428',
'0429','0434','0435','0436','0438','0439','0440','0442','0443','0447','0450','0454','0473','0476','0489','0490','0493','0494','0495','0496',
'0501','0502','0504','0505','0506','0507','0508','0510','0512','0513','0520','0521','0522','0523','0527','0529','0530','0531','0533','0534',
'0535','0539','0551','0552','0553','0554','0555','0556','0564','0565','0566','0569','0570','0572','0576','0579','0580','0581','0582','0596',
'0602','0605','0606','0613','0616','0641','0642','0643','2000','2001','2004','2005','2008','2009','2012','2013','2016','2017','2020','2021',
'2024','2025','2028','2029','2032','2033','2034','2035','2036','2037','2038','2039','2800','2801','2802','2803','2804','2805','2806','2807',
'2820','2821','2822','2823','3000','3001','3002','3003','3004','3007','3008','3009','3010','3011','3012','3013','3014','3015','3016','3017',
'3018','3019','3021','3022','3025','3026','3027','3028','3029','3030','3033','3036','3039','3053','3054','3056','3057','3058','3059','3060',
'3061','3062','3070','4005','4006','4007','4008','4009','4012','4200','4207','4209','4502','5027','5028','5029','5032','5033','5034','5045','5046',
'5047','5048','5052','5053','5056','5057','5059','5060','5061','5069','5070','5071','5072','5073','5074','5094','5095','5096','5097','5098',
'5099','5100','5101','5102','5103','5104','5105','5106','5107','5108','5109','5110','5111','5112','5113','5116','5117','5206','6000','6001',
'6003','6009','6010','6011','6013','6016','6017','6019','6020','6021','6022','6024','6026','6033','6037','6040','6044','6045','6048','6050',
'6051','6052','6053','6055','6056','6057','6059','6060','6075','6085','6101','6102','6103','6104','6105','6106','6120','6500','6501','7902',
'7904','7905','7906','7907','7910','7916','7917','8022','8025','8236','8237','8246','8247','8500','8503','8504','8506','8507','8509','8510',
'8511','8512','9900','9903','9907','9912','9913','9917','9918','9919','9925','9926','9927','9934','9975','SELF','SLF2','TEST','WSJC','PG20','9980')
then 'nf_access' end) as access,

lv.sesh_count,
lv.search_sesh_count,

sum(case when ti_td_page_content_type = 'SearchResults'
and ti_td_page_section = 'Home'
and ti_td_page_subsection = 'Simple Search Results'
and event_name = 'page_view'
and djm.product = 'Factiva' then 1 else 0 end) Simple_Searches,

sum(case when ti_td_page_content_type = 'SearchResults'
and ti_td_page_section = 'Search'
and ti_td_page_subsection = 'Search'
and ti_td_page_driver = 'searchBuilder_Search'
and event_name = 'page_view'
and djm.product = 'Factiva' 
and ti_td_search_filters_filters_author_included_count is null
and ti_td_search_filters_filters_subject_included_count is null
and ti_td_search_filters_filters_organization_included_count is null 
and ti_td_search_filters_filters_region_included_count is null
and ti_td_search_filters_filters_industry_included_count is null
and ti_td_search_filters_filters_executive_included_count is null
and ti_td_search_filters_filters_content_sources_included_count is null
and ti_td_search_filters_filters_author_excluded_count is null
and ti_td_search_filters_filters_subject_excluded_count is null
and ti_td_search_filters_filters_organization_excluded_count is null 
and ti_td_search_filters_filters_region_excluded_count is null
and ti_td_search_filters_filters_industry_excluded_count is null
and ti_td_search_filters_filters_executive_excluded_count is null
and ti_td_search_filters_filters_content_sources_excluded_count is null then 1 else 0 end) SB_Searches,

sum(case when ti_td_page_content_type = 'SearchResults'
and ti_td_page_section = 'Search'
and ti_td_page_subsection = 'Search'
and ti_td_page_driver = 'SavedSearch_SelectSearch'
and event_name = 'page_view'
and djm.product = 'Factiva' then 1 else 0 end) Saved_Searches,

count(distinct case when (ti_td_page_content_type = 'SearchResults'
and (ti_td_page_section = 'Search' or ti_td_page_section = 'Home') and djm.Product = 'Factiva')
or 
(ti_td_page_content_type = 'ResearchTools' 
and ti_td_page_content_type_detail = 'search results'
and ti_td_search_record_type is not null and djm.Product = 'New Factiva')
and event_name = 'page_view' 
then visit_id end) search_visits,

count(distinct case when (djm.Product = 'New Factiva' or djm.Product = 'Factiva') 
and (event_name = 'page_view' or event_name = 'user_action') 
then visit_id end) total_visits,

count(distinct case when (ti_td_page_content_type = 'SearchResults'
and (ti_td_page_section = 'Search' or ti_td_page_section = 'Home') and djm.Product = 'Factiva')
or 
(ti_td_page_content_type = 'ResearchTools' 
and ti_td_page_content_type_detail = 'search results'
and ti_td_search_record_type is not null and djm.Product = 'New Factiva')
and event_name = 'page_view' 
then mem.pib_member_id end) search_users,


sum(case when ti_td_page_content_type = 'ResearchTools'
and ti_td_page_section = 'keyword'
and ti_td_page_content_type_detail = 'search results'
and ti_td_search_record_type = 'free text'
and ti_td_module_tracker like '%previous_page_location%'
and event_name = 'page_view'
and djm.product = 'New Factiva' then 1 else 0 end) NF_Free_text_Searches,

sum(case when ti_td_page_content_type = 'ResearchTools'
and ti_td_page_section = 'Company'
and ti_td_page_content_type_detail = 'search results'
and ti_td_search_record_type = 'company'
and ti_td_module_tracker like '%previous_page_location%'
and event_name = 'page_view'
and djm.product = 'New Factiva' then 1 else 0 end) NF_Company_Searches,


sum(case when ti_td_page_content_type = 'ResearchTools'
and ti_td_page_section = 'Industry'
and ti_td_page_content_type_detail = 'search results'
and ti_td_search_record_type = 'industry'
and ti_td_module_tracker like '%previous_page_location%'
and event_name = 'page_view'
and djm.product = 'New Factiva' then 1 else 0 end) NF_Industry_Searches,

sum(case when ti_td_page_content_type = 'ResearchTools'
and ti_td_page_section = 'keyword'
and ti_td_page_content_type_detail = 'search results'
and ti_td_search_record_type = 'region'
and ti_td_module_tracker not like '%Interest%'
and event_name = 'page_view'
and djm.product = 'New Factiva' then 1 else 0 end) NF_Region_Searches,

sum(case when ti_td_page_content_type = 'ResearchTools'
and ti_td_page_section = 'keyword'
and ti_td_page_content_type_detail = 'search results'
and ti_td_search_record_type = 'newssubject'
and ti_td_module_tracker like '%previous_page_location%'
and event_name = 'page_view'
and djm.product = 'New Factiva' then 1 else 0 end) NF_newssubject_Searches,

sum(case when ti_td_page_content_type = 'ResearchTools'
and ti_td_page_section = 'keyword'
and ti_td_page_content_type_detail = 'search results'
and ti_td_search_record_type = 'person'
and event_name = 'page_view'
and ti_td_module_tracker like '%previous_page_location%'
and djm.product = 'New Factiva' then 1 else 0 end) NF_person_Searches,

sum(case when ti_td_page_content_type = 'ResearchTools'
and ti_td_page_content_type_detail = 'search results'
and ti_td_search_record_type is not null
and event_name = 'page_view'
and ti_td_module_tracker like '%previous_page_location%'
and djm.product = 'New Factiva' then 1 else 0 end) total_NF_Searches,

sum(case when ti_td_page_content_type = 'ResearchTools'
and ti_td_page_content_type_detail = 'search results'
and ti_td_search_record_type is not null
and event_name = 'page_view'
and ti_td_module_tracker like '%Interest%'
and djm.product = 'New Factiva' then 1 else 0 end) total_NF_Interest_Searches


from pib_event_data.pib_product_metrics djm
inner join dimension_external_db.pib_membership_dimension mem on djm.user_info_user_ref = mem.pib_member_id 
left join dimension_external_db.pib_billing_account_dimension bill on mem.billing_account_id = bill.cibs_billing_account_id 
left join dimension_external_db.pib_company_dimension comp on bill.salesforce_company_two = comp.company_sfdc_id
left join lv on (mem.pib_member_id = lv.pib_member_id and djm.product = lv.product)
where djm.product in ('Factiva', 'New Factiva')
and cycle_date >>= cast('2023-09-01' as date)
group by 1,2,3,4,5,6,7,8,9,10
