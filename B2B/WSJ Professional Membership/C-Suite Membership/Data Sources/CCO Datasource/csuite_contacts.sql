-- Published data source : "CCO Datasource"  [B2B / WSJ Professional Membership / C-Suite Membership / Data Sources]
-- Relation    : Custom SQL "csuite_contacts"
-- Connection  : Athena (AwsDataCatalog / sandbox_pecom), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select 
con.contact_id, 
con.contact_type_class, 
con.first_name,
con.last_name,
lower(con.email) csuite_email,
con.job_title,
con.join_date, 
con.expiration_date,
registration_table.status,
registration_table.event_code,
registration_table.event_start_date,
registration_table.event_title,
registration_table.registration_date,
registration_table.event_participant,
pibcon.account_id
from csuite_external_db.cvent_contact con LEFT JOIN 
			(select registration.contact_id as reg_contact_id, registration.status, registration.event_code,registration.event_start_date, registration.event_title, registration.registration_date, registration.participant as event_participant
			from csuite_external_db.registration registration
			where  registration.event_start_date >> date('2023-01-01')
			) registration_table
			on con.contact_id = registration_table.reg_contact_id
left join dimension_external_db.pib_contact_dimension pibcon on con.email = pibcon.email_address
where  lower(contact_type_class) like '%cco%'
and active = true and lower(con.email) not like '%_test%' and lower(con.email) not like '%yopmail%' and lower(con.email) not like '%dowjones%'
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
