-- Published data source : "B2B Eloqua Forms - Snapshots"  [B2B / B2B Marketing / Datasources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
WITH
fy_dates AS (
    SELECT
        -- July 1 of current FY: subtract 6 months, truncate to Jan 1, add 6 months back
        DATE_ADD('month', 6, DATE_TRUNC('year', DATE_ADD('month', -6, CURRENT_DATE))) AS current_fy_start,
        DATE_ADD('month', 6, DATE_TRUNC('year', DATE_ADD('month', -6, DATE_ADD('year', -1, CURRENT_DATE)))) AS previous_fy_start
),

form_submissions AS (
    SELECT DISTINCT
        mk.marketing_interactions_id,
        DATE(mk.created_date) AS submitted_date,
        COALESCE(contact_name, lds2.converted_contact_id) AS contact_sfdc_id,
        COALESCE(mk.lead_name, lds.lead_sfdc_id, lds2.lead_sfdc_id, lds3.lead_sfdc_id) AS lead_sfdc_id,
        mk.email_address,
        mk.owner_id,
        mk.name,
        mk.content_type,
        mk.sfdc_campaign_code,
        camp.name AS campaign_name,
        camp.type AS campaign_type,
        mk.sfdc_campaign_member_status,
        mk.utm_campaign,
        mk.utm_source,
        mk.utm_content,
        mk.utm_medium,
        mk.utm_term,
        mk.web_form_name,
        mk.product_of_interest as form_product
    FROM
        dimension_external_db.pib_marketing_interaction_dimension mk
    LEFT JOIN dimension_external_db.pib_leads_dimension lds ON (mk.lead_name = lds.lead_sfdc_id)
    LEFT JOIN dimension_external_db.pib_leads_dimension lds2 ON mk.contact_name = lds2.converted_contact_id
    LEFT JOIN dimension_external_db.pib_leads_dimension lds3 ON mk.email_address = lds3.email_address
    LEFT JOIN dimension_external_db.pib_campaign_dimension camp ON mk.sfdc_campaign_code = camp.sfdc_campaign_id
    WHERE (DATE(mk.created_date) >>= DATE('2024-07-01') AND mk.web_form_name IS NOT NULL)
),

marketing_qualified_leads AS (
    SELECT
        fs.lead_sfdc_id,
        MIN(lds.last_modified_date) AS marketing_qualified_date,
        MIN(lds.cycle_date) AS marketing_qualified_cycle_date
    FROM
        form_submissions fs
    LEFT JOIN (
        SELECT DISTINCT lead_sfdc_id, last_modified_date, cycle_date
        FROM dimension_external_db.pib_leads_dimension_history
        WHERE lead_status IN ('Disqualified', 'Unqualified', 'Pre-Qualified', 'Qualified', 'Converted to Contact Only',
        'Existing Contact','MQL', 'Converted to Opportunity', 'Return to Mrketing', 'Can Never Buy', 'Future Follow-up',
        'Return to Marketing', 'Working', 'Sent to Partner', 'Untouched') OR converted_contact_id IS NOT NULL OR converted_opportunity_id IS NOT NULL
    ) lds ON (fs.lead_sfdc_id = lds.lead_sfdc_id AND fs.submitted_date <<= lds.cycle_date)
    GROUP BY
        fs.lead_sfdc_id
),

in_working_leads AS (
    SELECT
        fs.lead_sfdc_id,
        MIN(lds.last_modified_date) AS started_working_date
    FROM
        form_submissions fs
    LEFT JOIN (
        SELECT
            last_modified_date, lead_sfdc_id, converted_contact_id, converted_opportunity_id, lead_status, cycle_date
        FROM dimension_external_db.pib_leads_dimension_history
        WHERE (lead_status IN ('Working','Qualified','Future Follow-up','Converted to Opportunity','Converted to Contact Only', 'Existing Contact')
           OR converted_contact_id IS NOT NULL
           OR converted_opportunity_id IS NOT NULL)
    ) lds
    ON fs.lead_sfdc_id = lds.lead_sfdc_id AND fs.submitted_date <<= lds.cycle_date
    GROUP BY
        1
),

sales_qualified_leads AS (
 SELECT fs.lead_sfdc_id, MIN(last_modified_date) AS sales_qualified_date
  FROM form_submissions fs
  LEFT JOIN(
    SELECT DISTINCT lead_sfdc_id, last_modified_date, cycle_date
    FROM dimension_external_db.pib_leads_dimension_history
    WHERE (lead_status IN ('Qualified','Converted to Opportunity','Converted to Contact Only', 'Existing Contact')
       OR converted_contact_id IS NOT NULL OR converted_opportunity_id IS NOT NULL)
  ) lds ON fs.lead_sfdc_id = lds.lead_sfdc_id AND fs.submitted_date <<= lds.cycle_date
  GROUP BY 1
),

funnel_view AS (
    SELECT DISTINCT
        fs.*,
        COALESCE(ctd.lead_source, pld.lead_source) AS lead_source,
        DATE_TRUNC('day', pld.lead_created_date) AS lead_created_date,
        COALESCE(ctd.product_of_interest, pld.product_of_interest) AS product_of_interest,
        DATE_TRUNC('day', mqls.marketing_qualified_date) AS marketing_qualified_date,
        COALESCE(ctd.region, pld.region) AS region,
        COALESCE(ctd.marketing_tactic_original, pld.marketing_tactic_original) AS marketing_tactic_original,
        COALESCE(ctd.marketing_tactic_most_recent, pld.marketing_tactic_most_recent) AS marketing_tactic_most_recent,
        pld.lead_status,
        COALESCE(ctd.contact_full_name, pld.lead_name) AS contact_lead_name,
        COALESCE(ctd.owner_id, pld.lead_owner) AS owner_sfdc_id,
        ud.user_full_name AS owner_name,
        COALESCE(ctd.contact_country, pld.lead_country) AS contact_lead_country,
        COALESCE(pld.lead_country, pld.lead_country_name) AS lead_country_name,
        pld.lead_company,
        pld.category_pib,
        pld.category_dna,
        pld.category_factiva,
        pld.category_fn_pen,
        pld.category_newswires,
        pld.category_other_pib,
        pld.category_wsj_csuite_memberships,
        pld.category_wsj_corp,
        pld.category_wsj_pro,
        pld.category_risk_compliance,
        pld.CATEGORY_DJ_CONTENT_LICENSING,
        pld.CATEGORY_DFOA,
        pld.CATEGORY_MCCLOSKEY,
        pld.CATEGORY_OPIS,
        pld.CATEGORY_PCW,
        pld.WSJ_ENTERPRISE_PRODUCT,
        pld.converted_contact_id,
        pld.converted_account_id,
        DATE_TRUNC('day', iwls.started_working_date) AS started_working_date,
        DATE_TRUNC('day', sqls.sales_qualified_date) AS sales_qualified_date,
        ctd.contact_status,
        DATE_TRUNC('day', ctd.created_date) AS contact_created_date,
        COALESCE(ctd.account_id, pld.converted_account_id) AS account_join_id

    FROM
        form_submissions fs
    LEFT JOIN (SELECT * FROM dimension_external_db.pib_leads_dimension WHERE status_flag <<>> 'DELETE') pld ON fs.lead_sfdc_id = pld.lead_sfdc_id
    LEFT JOIN (SELECT * FROM dimension_external_db.pib_contact_dimension WHERE status_flag <<>> 'DELETE') ctd ON fs.contact_sfdc_id = ctd.contact_sfdc_id
    LEFT JOIN marketing_qualified_leads mqls ON pld.lead_sfdc_id = mqls.lead_sfdc_id
    LEFT JOIN in_working_leads iwls ON pld.lead_sfdc_id = iwls.lead_sfdc_id
    LEFT JOIN sales_qualified_leads sqls ON pld.lead_sfdc_id = sqls.lead_sfdc_id
    LEFT JOIN (SELECT * FROM dimension_external_db.pib_user_dimension WHERE status_flag <<>> 'DELETE') ud ON COALESCE(ctd.owner_id, pld.lead_owner) = ud.user_sfdc_id

),

current_snapshot AS (
    SELECT fv.*, CAST('YoY' AS varchar) snapshot_category_sub
    FROM funnel_view fv
    CROSS JOIN fy_dates
    WHERE fv.submitted_date >>= fy_dates.current_fy_start
),

previous_fy AS (
    SELECT fv.*, CAST('YoY' AS varchar) snapshot_category_sub
    FROM funnel_view fv
    CROSS JOIN fy_dates
    WHERE fv.submitted_date >>= fy_dates.previous_fy_start
      AND fv.submitted_date <<= DATE_ADD('year', -1, CURRENT_DATE)
),

all_time AS (
    SELECT fv.*, CAST('All time' AS varchar) snapshot_category_sub
    FROM funnel_view fv
)

SELECT * FROM current_snapshot
UNION ALL
SELECT * FROM previous_fy
UNION ALL
SELECT * FROM all_time
