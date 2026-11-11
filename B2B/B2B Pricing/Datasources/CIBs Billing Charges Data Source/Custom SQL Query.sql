-- Published data source : "CIBs Billing Charges Data Source"  [B2B / B2B Pricing / Datasources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / reference_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
WITH tm AS (
    SELECT billing_account_number,
           SUM(exit_rate * 12)              annualized_rev,
           SUM(total_non_recurring_revenue) total_non_recurring_revenue
    FROM fact_external_db.tm1_fact
    WHERE billing_date = (SELECT MAX(billing_date) FROM fact_external_db.tm1_fact)
    GROUP BY 1
),

eco AS (
    SELECT cibs_billing_account_id,
           email_address AS marketing_email_address
    FROM (
        SELECT cibs_billing_account_id,
               email_address,
               ROW_NUMBER() OVER (PARTITION BY cibs_billing_account_id ORDER BY updated_at DESC) AS rn
        FROM csuite_external_db.eloqua_cdo_current_risk_certification
        WHERE email_address IS NOT NULL
    ) t
    WHERE rn = 1
)

SELECT cibs_billing_charges_id,
       bad.cibs_billing_account_id,
       comp.company_name,
       comp.company_sfdc_id,
       cibs.name                          AS link_to_details,
       cibs.product_description,
       cibs.start_date,
       cibs.end_date,
       cibs.current_chg,
       cibs.transaction_volume,
       cibs.seats,
       cibs.currency_iso_code,
       bad.salesforce_local_currency,
       cibs.amount,
       bad.customers_first_name,
       bad.customers_last_name,
       bad.email,
       eco.marketing_email_address,
       bad.country                        AS billing_account_country,
       bad.state,
       bad.salesforce_partner_flag,
       bad.salesforce_status,
       bad.salesforce_billing_account_id,
       contract_dim.salesforce_contract_number,
       terr.territory_name,
       usr.user_full_name                 AS owner_of_territory,
       tm.annualized_rev,
       tm.total_non_recurring_revenue
FROM dimension_external_db.pib_cibs_billing_charges_dimension cibs
LEFT JOIN dimension_external_db.pib_billing_account_dimension bad         ON bad.salesforce_billing_account_id = cibs.cibs_billing_account
LEFT JOIN dimension_external_db.pib_company_dimension comp                ON bad.salesforce_company_two = comp.company_sfdc_id
LEFT JOIN dimension_external_db.pib_contract_dimension contract_dim       ON contract_dim.contract_id = bad.contract_id
LEFT JOIN dimension_external_db.pib_territory_dimension terr              ON terr.territory_sfdc_id = bad.salesforce_territory
LEFT JOIN dimension_external_db.pib_user_dimension usr                    ON usr.user_sfdc_id = terr.territory_owner
LEFT JOIN reference_external_db.fx_rates_current fx                       ON fx.currency = bad.salesforce_local_currency
LEFT JOIN tm                                                               ON tm.billing_account_number = bad.cibs_billing_account_id
LEFT JOIN eco                                                              ON eco.cibs_billing_account_id = bad.cibs_billing_account_id
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28
