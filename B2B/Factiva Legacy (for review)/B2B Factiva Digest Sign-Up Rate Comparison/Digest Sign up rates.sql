-- Dashboard   : "B2B Factiva Digest Sign-Up Rate Comparison"  [B2B / Factiva Legacy (for review)]
-- Data source : "Digest Sign up rates" = published source "B2B Factiva Digest Sign-Up Rate Comparison - Sign up rates"  [B2B / B2B Product / Factiva / Datasources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with sre as 
(select cycle_date, count(distinct EID) sr_enabled from 
(with lena as (
select date_time, cycle_date, event_name, ti_td_page_section, ti_td_page_subsection, ti_td_action,  ti_td_page_url, user_info_user_ref as EID from pib_event_data.pib_product_metrics
where ti_td_page_section = 'Onboarding'
and product = 'New Factiva'
and date_time >> cast('2024-01-01' as date)
and ti_td_action like 'saturday_review%'
order by user_info_user_ref, date_time)
select EID, ti_td_action, ti_td_page_section, cycle_date,  max(lena.date_time) as date_time  from 
lena
where date_time = (select max(date_time) from lena lenb where lena.EID = lenb.EID)
group by 1,2,3,4)
where ti_td_action = 'saturday_review_enable'
group by 1)


select djm.cycle_date, dat.day_of_week, coalesce(sre.sr_enabled,0) as sr_enabled,

COUNT(distinct CASE WHEN djm.event_name = 'user_action' AND ti_td_action = 'complete_onboarding' THEN djm.user_info_user_ref end) onboard_user_count,
count(distinct case when djm.event_name = 'user_action' and ti_td_action = 'complete_onboarding' and ti_td_ad_digest_email_enabled = true then djm.user_info_user_ref  end) digest_enabled 


from pib_event_data.pib_product_metrics djm
left join dimension_external_db.pib_membership_dimension mem on djm.user_info_user_ref = mem.pib_member_id
left join dimension_external_db.pib_billing_account_dimension bill on mem.billing_account_id = bill.cibs_billing_account_id 
left join dimension_external_db.pib_company_dimension comp on bill.salesforce_company_two  = comp.company_sfdc_id 
left join sre on djm.cycle_date = sre.cycle_date
left join reference_external_db.date_dimension dat on cast(djm.cycle_date as varchar)  = substring(cast(dat.full_date as varchar),1, 10) 
where product = 'New Factiva'


and djm.cycle_date >>= cast('2023-04-01' as date)
and mem.billing_account_id not like '9ZZZ%'
and mem.billing_account_id not like '9ZFB%'
and mem.billing_account_id <<>> '9DOW003600'
group by 1,2,3
order by djm.cycle_date
