-- Published data source : "CCO Membership Campaign Influence"  [B2B / WSJ Professional Membership / C-Suite Membership / Data Sources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
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

evnt as (select event_id, event_title, event_code, event_start_date
from csuite_external_db.event
group by 1,2,3,4),

evntcfd as (select event_id, max(case when field_name = 'SF Campaign ID' THEN field_value END) as SF_Campaign_ID,
		max(case when field_name = 'Event Category' THEN field_value END) as Event_Category
from csuite_external_db.event_customfielddetail 
where (field_name = 'SF Campaign ID' or field_name = 'Event Category')
group by 1)
select cmpn.*, cmpnflu.opportunity_id, evnt.event_id, coalesce(event_title, 'R&C') as event_title from cmpn 
left join cmpnflu on cmpn.sfdc_campaign_id=cmpnflu.campaign_id
left join evntcfd on cmpn.sfdc_campaign_id=evntcfd.SF_Campaign_ID
left join evnt on evntcfd.event_id = evnt.event_id
where (name like '%R&C%' or (
(lower(Event_Category) like '%ceo%'
		or lower(Event_Category) like '%cfo%'
		or lower(Event_Category) like '%cio%'
		or lower(Event_Category) like '%cmo%'
		or lower(Event_Category) like '%cco%'

		or lower(Event_Category) like '%cross c-suite%'
		or lower(Event_Category) like '%other%'
                or lower(Event_Category) like '%journal house%')))
 and start_date >>= date('2023-07-01')
