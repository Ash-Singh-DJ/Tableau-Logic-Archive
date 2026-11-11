-- Published data source : "B2B PIB User-List Dashboard Query"  [B2B / B2B Sales / Data Sources]
-- Relation    : Custom SQL "User & Usage Information"
-- Connection  : Athena (AwsDataCatalog / reference_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
WITH LastLoginOmnit as (SELECT post_evar3,
                    max(case when reporting_suite in ('djfactiva', 'djappfactiva') then cycle_date else null end) last_login_factiva,
                    max(case when reporting_suite = 'djriskcomplianceprod' then cycle_date else null end) last_login_RC,
                    max(case when reporting_suite = 'factivadjnewsplusprod' then cycle_date else null end) last_login_NP
FROM fact_external_db.omniture_event_fact
WHERE reporting_suite in ('djfactiva', 'djappfactiva', 'djriskcomplianceprod', 'factivadjnewsplusprod')
  and cycle_date >>= date('2017-06-01')
GROUP BY 1
ORDER BY 1),

LastLoginDJM AS (
	SELECT
		user_info_user_ref,
		max(cycle_date) AS last_login_RCFC
	FROM pib_event_data.pib_product_metrics
	WHERE cycle_date >>= DATE('2021-11-01')
		AND product IN ('Financial Crime', 'RiskCenter')
		AND (event_name IS NOT NULL OR "action" IS NOT NULL OR ti_td_event_name IS NOT NULL OR ti_td_action IS NOT NULL)
	GROUP BY 1
),

ConsumerOmnit as (SELECT case when post_evar3 like 'V1-%' or post_evar3 like 'V2-%' then post_evar3 else 'V2-' || post_evar3 end AS vxid_clean,
                              max(case when reporting_suite = 'djglobal' and (lower(post_prop8) not like 'dwsjn%' and ((lower(channel) like '%online journal%' or lower(channel) like '%wsj%') or post_prop24 = 'The Wall Street Journal')) then cycle_date else null end) last_login_wsj,
                              max(case when reporting_suite in ('djappwsj', 'djwsjiphone', 'djwsjipad') then cycle_date else null end) last_login_wsjApps,
                              max(case when reporting_suite = 'djglobal' and ((lower(channel) like '%barron%' or channel like '%bol%') or post_prop24 = 'Barron s' or post_prop1 in ('Barrons US', 'Barrons EMEA', 'Barrons APAC') or post_prop5 = 'www.barrons.com/') then cycle_date else null end) last_login_barrons,
                              max(case when reporting_suite in ('djappbarrons') then cycle_date else null end) last_login_barronsApps
                      FROM fact_external_db.omniture_event_fact
                      WHERE cycle_date >>= date('2017-06-01')
                      group by 1),

mem_dim AS ( select
pib_member_id,
uu_id,
user_id,
long_user_id,
first_name,
last_name,
country_code,
city,
email_login,
plan_id,
email,
billing_account_id,
user_status,
web_registration_date,
login_date
from dimension_external_db.pib_membership_dimension
where billing_account_id NOT LIKE '9ZFB%'
    and billing_account_id NOT LIKE '9ZZZ%'
    and user_status = 'A'),

VXID as (
  SELECT encrypted_uuid_v1 as VXID, uuid
  FROM subscription_external_db.identity_lookup
  WHERE encrypted_uuid_v1 IS NOT NULL
  UNION
  SELECT encrypted_uuid_v2 as VXID, uuid
  FROM subscription_external_db.identity_lookup
  WHERE encrypted_uuid_v1 IS NOT NULL)
SELECT mem_dim.user_id,
       mem_dim.pib_member_id,
       mem_dim.email,
       mem_dim.first_name,
       mem_dim.last_name,
       mem_dim.plan_id,
      mem_dim.long_user_id,
       mem_dim.email_login,
       mem_dim.country_code,
       mem_dim.city,
       mem_dim.billing_account_id,
       mem_dim.user_status,
       mem_dim.web_registration_date,
       mem_dim.login_date,
       LastLoginOmnit.last_login_factiva,
       LastLoginOmnit.last_login_NP,
       LastLoginOmnit.last_login_RC,
       LastLoginDJM.last_login_RCFC,
       max(ConsumerOmnit.last_login_wsj) last_login_wsj,
       max(ConsumerOmnit.last_login_wsjapps) last_login_wsjapps,
       max(ConsumerOmnit.last_login_barrons) last_login_barrons,
       max(ConsumerOmnit.last_login_barronsApps) last_login_barronsApps
FROM  mem_dim
LEFT JOIN LastLoginOmnit ON mem_dim.pib_member_id = LastLoginOmnit.post_evar3
LEFT JOIN LastLoginDJM ON mem_dim.pib_member_id = LastLoginDJM.user_info_user_ref
LEFT JOIN VXID ON mem_dim.uu_id = VXID.uuid
LEFT JOIN ConsumerOmnit ON VXID.VXID = ConsumerOmnit.vxid_clean
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18
