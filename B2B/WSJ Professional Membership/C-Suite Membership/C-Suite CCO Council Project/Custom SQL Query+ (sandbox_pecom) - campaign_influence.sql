-- Dashboard   : "C-Suite CCO Council Project"  [B2B / WSJ Professional Membership / C-Suite Membership]
-- Data source : "Custom SQL Query+ (sandbox_pecom)" = published source "CCO Datasource"  [B2B / WSJ Professional Membership / C-Suite Membership / Data Sources]
-- Relation    : Custom SQL "campaign_influence"
-- Connection  : Athena (AwsDataCatalog / sandbox_pecom), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with cmpn as (select sfdc_campaign_id, name, start_date
from dimension_external_db.pib_campaign_dimension
group by 1,2,3),

cmpnflu as (select campaign_id, opportunity_id
from dimension_external_db.pib_campaign_influence
group by 1,2)
,
opp as (select pib_opportunity_sfdc_id, opportunity_name, sales_stage, opportunity_amount, open_date, marketing_tactic, annualized_opportunity_revenue, contact_email, contact_name, contact_phone, owner_full_name
from dimension_external_db.pib_opportunity_dimension
where status_flag <<>> 'DELETE'
group by 1,2,3,4,5,6,7,8,9,10,11),
ps_dim as (SELECT opportunity, product_service
FROM dimension_external_db.pib_product_services_dimension
WHERE status_flag <<>> 'DELETE'
group by 1,2), 
evnt as (select event_id, event_title, event_code, event_start_date
from csuite_external_db.event
group by 1,2,3,4),

evntcfd as (select event_id, max(case when field_name = 'SF Campaign ID' THEN field_value END) as SF_Campaign_ID,
		max(case when field_name = 'Event Category' THEN field_value END) as Event_Category
from csuite_external_db.event_customfielddetail 
where (field_name = 'SF Campaign ID' or field_name = 'Event Category')
group by 1)
select cmpn.*, cmpnflu.opportunity_id, opp.*, ps_dim.product_service, evnt.event_id, coalesce(event_title, 'R&C') as event_title from cmpn 
left join cmpnflu on cmpn.sfdc_campaign_id=cmpnflu.campaign_id
left join opp on cmpnflu.opportunity_id=opp.pib_opportunity_sfdc_id
left join ps_dim on opp.pib_opportunity_sfdc_id = ps_dim.opportunity

left join evntcfd on cmpn.sfdc_campaign_id=evntcfd.SF_Campaign_ID
left join evnt on evntcfd.event_id = evnt.event_id
where (name like '%R&C%' or (
(lower(Event_Category) is not null)))
 and start_date >>= date('2023-07-01')
