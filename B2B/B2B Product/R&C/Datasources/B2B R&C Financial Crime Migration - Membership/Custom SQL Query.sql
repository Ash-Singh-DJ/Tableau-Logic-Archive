-- Published data source : "B2B R&C Financial Crime Migration - Membership"  [B2B / B2B Product / R&C / Datasources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with RC_Legacy_Prelim as(
SELECT pib_member_id, cycle_date, billing_account_id, product_access_code as old_access_code, web_registration_date, user_status
FROM
	(SELECT pib_member_id, cycle_date, billing_account_id, date(web_registration_date) as web_registration_date, user_status,
	 case when length(plan_id) <<4 then concat('0',plan_id) else plan_id end as product_access_code,
     ROW_NUMBER() OVER (PARTITION BY pib_member_id ORDER BY cycle_date DESC) as seqnum
	 FROM dimension_external_db.pib_membership_history 
	 where billing_account_id not like '9ZZZ%' and billing_account_id not like '9ZFB%'
     and plan_id in ('0455','0456','0571','0573','0601','0603','0604','0491','0492','0499','0500','0577','0578','0585','0586',
	 '455','456','571','573','601','603','604','491','492','499','500','577','578','585','586',
	 '0555','0556','0572','0576','0602','0605','0606','0493','0494','0495','0496','0579','0580','0581','0582',
	 '555','556','572','576','602','605','606','493','494','495','496','579','580','581','582',
	 '2033','2035','2037','2039','0569','0570','569','570',
	 '0517','0518','0574','0575','0497','0498','0537','0538','0583','0584','0587','0588',
	  '517','518','574','575','497','498','537','538','583','584','587','588')
	 --and user_status ='A'
	 GROUP BY (1,2,3,4,5,6) 
	)
where seqnum = 1
and user_status = 'A'
group by (1,2,3,4,5,6)
order by cycle_date desc
),

RC_Legacy as( select pib_member_id, cycle_date, billing_account_id, old_access_code, web_registration_date, user_status
from
	(select hist.*, cmd.user_status as current_user_status 
	from RC_Legacy_Prelim as hist
	left join dimension_external_db.pib_membership_dimension cmd on hist.pib_member_id = cmd.pib_member_id )
where user_status = current_user_status
), --50933

RCFC_All_Codes as (
SELECT pib_member_id, cycle_date, billing_account_id, product_access_code as rcfc_access_code, web_registration_date, user_status
from (select pib_member_id, cycle_date, billing_account_id, date(web_registration_date) as web_registration_date, user_status,
	   case when length(plan_id) <<4 then concat('0',plan_id) else plan_id end as product_access_code,
       ROW_NUMBER() OVER (PARTITION BY pib_member_id, plan_id ORDER BY pib_member_id, plan_id, cycle_date) seqnum
	   from dimension_external_db.pib_membership_history
	   where billing_account_id not like '9ZZZ%' and billing_account_id not like '9ZFB%'
	   and plan_id  in ('0611','0614','0598','0599','0644','0610','0651','0659','0618','0647','0648','0649','0650','0658','0655','0663',
		             '611','614','598','599','644','610','651','659','618','647','648','649','650','658','655','663',
		             '0613','0616','0641','0642','0643','0609','0654','0662','0652','0660','0656','0664','0653','0661','0657','0665',
					 '613','616','641','642','643','609','654','662','652','660','656','664','653','661','657','665',
					 '2040','2041','2042','2043','0607','0608','0610','0609','607','608','610','609',
					 '0612','0615','612','615')
	   and cycle_date >>= date('2020-07-01') 
	   and user_status ='A'
) where seqnum = 1
and user_status = 'A'
group by (1,2,3,4,5,6)
), --15077

-- ************************* RDS Data *************************
RDS_Legacy as (
SELECT pib_member_id, billing_account_id, web_registration_date, old_access_code, cycle_date
from RC_Legacy
where old_access_code in ('0455','0456','0571','0573','0601','0603','0604','0491','0492','0499','0500','0577','0578','0585','0586')
GROUP BY (1,2,3,4,5) 
), --37183

RDS_RCFC as (
SELECT pib_member_id, billing_account_id, web_registration_date, rcfc_access_code, cycle_date
from RCFC_All_Codes
where rcfc_access_code in ('0611','0614','0598','0599','0644','0610','0651','0659','0618','0647','0648','0649','0650','0658','0655','0663')
group by (1,2,3,4,5)
),

RDS as (select s_old.*, s_new.rcfc_access_code, s_new.cycle_date as Neutral_migration_date,'RDS' as Product_type,
case when s_new.rcfc_access_code <<>> s_old.old_access_code then 'Yes' else 'No' end as Neutral_Migration
from  RDS_Legacy as s_old 
left join RDS_RCFC as s_new on s_new.pib_member_id = s_old.pib_member_id
order by (1,2,3,4,5,7,6,8)
), --37210

-- ************************* RDP Data *************************
RDP_Legacy as (
SELECT pib_member_id, billing_account_id, web_registration_date, old_access_code, cycle_date
from RC_Legacy
where old_access_code in ('0555','0556','0572','0576','0602','0605','0606','0493','0494','0495','0496','0579','0580','0581','0582')
GROUP BY (1,2,3,4,5) 
), 

RDP_RCFC as (
SELECT pib_member_id, billing_account_id, web_registration_date, rcfc_access_code, cycle_date
from RCFC_All_Codes
where rcfc_access_code in ('0613','0616','0641','0642','0643','0609','0654','0662','0652','0660','0656','0664','0653','0661','0657','0665')
group by (1,2,3,4,5)
),

RDP as (select p_old.*, p_new.rcfc_access_code, p_new.cycle_date as Neutral_migration_date,'RDP' as Product_type,
case when p_new.rcfc_access_code <<>> p_old.old_access_code then 'Yes' else 'No' end as Neutral_Migration
from  RDP_Legacy as p_old 
left join RDP_RCFC as p_new on p_new.pib_member_id = p_old.pib_member_id
order by (1,2,3,4,5,7,6,8)
), --10586

-- ************************* DJX Data *************************
DJX_Legacy as (
SELECT pib_member_id, billing_account_id, web_registration_date, old_access_code, cycle_date
from RC_Legacy
where old_access_code in ('2033','2035','2037','2039','0569','0570')
GROUP BY (1,2,3,4,5) 
), 

DJX_RCFC as (
SELECT pib_member_id, billing_account_id, web_registration_date, rcfc_access_code, cycle_date
from RCFC_All_Codes
where rcfc_access_code in ('2040','2041','2042','2043','0607','0608','0610','0609')
group by (1,2,3,4,5)
),

DJX as (select d_old.*, d_new.rcfc_access_code, d_new.cycle_date as Neutral_migration_date,'DJX' as Product_type,
case when d_new.rcfc_access_code <<>> d_old.old_access_code then 'Yes' else 'No' end as Neutral_Migration
from  DJX_Legacy as d_old 
left join DJX_RCFC as d_new on d_new.pib_member_id = d_old.pib_member_id
order by (1,2,3,4,5,7,6,8)
), --463

-- ************************* RDR Data *************************
RDR_Legacy as (
SELECT pib_member_id, billing_account_id, web_registration_date, old_access_code, cycle_date
from RC_Legacy
where old_access_code in ('0517','0518','0574','0575','0497','0498','0537','0538','0583','0584','0587','0588')
GROUP BY (1,2,3,4,5) 
), 

RDR_RCFC as (
SELECT pib_member_id, billing_account_id, web_registration_date, rcfc_access_code, cycle_date
from RCFC_All_Codes
where rcfc_access_code in ('0612','0615',
		'0611','0614','0598','0599','0644','0610','0651','0659','0618','0647','0648','0649','0650','0658','0655','0663',
		'0613','0616','0641','0642','0643','0609','0654','0662','0652','0660','0656','0664','0653','0661','0657','0665')
group by (1,2,3,4,5)
),

RDR as (select r_old.*, r_new.rcfc_access_code, r_new.cycle_date as Neutral_migration_date,'RDR' as Product_type,
case when r_new.rcfc_access_code <<>> r_old.old_access_code then 'Yes' else 'No' end as Neutral_Migration
from  RDR_Legacy as r_old 
left join RDR_RCFC as r_new on r_new.pib_member_id = r_old.pib_member_id
order by (1,2,3,4,5,7,6,8)
), --2787

Neutral_migration as (
select * from RDS
union all
select * from RDP
union all
select * from DJX
union all
select * from RDR), --51084

Nonneutral_migration as (
select rc_old.*, rc_new.rcfc_access_code, rc_new.cycle_date as Non_Neutral_migration_date, 'Non' as Product_type,
case when rc_new.rcfc_access_code <<>> rc_old.old_access_code then 'Yes' else 'No' end as Non_Neutral_Migration
from  RC_Legacy as rc_old 
left join RCFC_All_Codes as rc_new on rc_new.pib_member_id = rc_old.pib_member_id
),

RC_Data as (select nm.*, nnm.rcfc_access_code as rcfc_access_code2, nnm.Non_Neutral_migration_date, nnm.Non_Neutral_Migration
from Neutral_migration as nm
left join Nonneutral_migration as nnm on (nm.pib_member_id = nnm.pib_member_id)
--and nnm.rcfc_access_code <<>> nm.rcfc_access_code 
--and nnm.Non_Neutral_migration_date <<>> nm.migration_date)
),

-- Get RSD
Terr_RSD as (select user_sfdc_id, user_full_name
from dimension_external_db.pib_user_dimension
group by (1,2)),

-- Join tables with other company-level information
Dim AS (
select mbd.pib_member_id, 
	   mbd.user_id,
	   mbd.billing_account_id,
	   concat(mbd.first_name, ' ', mbd.last_name) full_name,
	   mbd.email, 
	   comp.company_name, 
	   comp.company_industry, 
	   comp.company_sfdc_id, 
	   comp.company_website, 
	   td.territory_name,
	   td.region_code as region,
	   Terr_RSD.user_full_name as RSD
	   from dimension_external_db.pib_membership_dimension as mbd 
left join dimension_external_db.pib_billing_account_dimension as bad on bad.cibs_billing_account_id = mbd.billing_account_id
left join dimension_external_db.pib_company_dimension as comp on bad.salesforce_company_two = comp.company_sfdc_id
left join dimension_external_db.pib_territory_dimension as td on comp.company_territory  = td.territory_sfdc_id
LEFT JOIN Terr_RSD ON td.regional_sales_director = Terr_RSD.user_sfdc_id
where mbd.user_status ='A'
and mbd.billing_account_id not like '9ZZZ%' and mbd.billing_account_id not like '9ZFB%'
group by (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)
),

Renew as (SELECT comp.company_sfdc_id, bad.cibs_billing_account_id,
		   CASE WHEN bad.salesforce_contract_renewal_date <<= current_date
		   		THEN date_add('year',date_diff('year',bad.salesforce_contract_renewal_date,current_date) + 1,bad.salesforce_contract_renewal_date)
		   		ELSE bad.salesforce_contract_renewal_date END AS contract_renewal_date
	FROM dimension_external_db.pib_company_dimension comp
	LEFT JOIN dimension_external_db.pib_billing_account_dimension bad ON comp.company_sfdc_id = bad.salesforce_company_two
	WHERE comp.status_flag <<>> 'DELETE'
		AND company_status = 'Customer'
		AND bad.actual_termination_date IS NULL
	GROUP BY 1, 2, 3
	ORDER BY comp.company_sfdc_id)

select RC_Data.*, Renew.contract_renewal_date,
case when Neutral_Migration = 'No' and Non_Neutral_Migration = 'No' then 'Not Migrated'
when Neutral_Migration = 'Yes' and Non_Neutral_Migration = 'Yes' then 'Migrated (Neutral migration)'
when Neutral_Migration = 'No' and Non_Neutral_Migration = 'Yes' then 'Migrated (Upsell/downsell)' end as Migration_Flag,
Dim.user_id, Dim.full_name, Dim.email, Dim.company_name, Dim.company_industry, Dim.territory_name, Dim.region, Dim.RSD
from RC_Data
left join Dim on RC_Data.pib_member_id = Dim.pib_member_id
left join Renew on Renew.cibs_billing_account_id = RC_Data.billing_account_id
