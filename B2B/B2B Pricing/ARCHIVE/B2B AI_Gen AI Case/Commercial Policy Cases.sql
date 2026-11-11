-- Dashboard   : "B2B AI_Gen AI Case"  [B2B / B2B Pricing / ARCHIVE]
-- Data source : "Commercial Policy Cases" = published source "Commercial Policy Cases"  [B2B / B2B Pricing / Datasources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
SELECT 
service_case.case_number,
service_case.status,
service_case.category,
service_case.type as case_type,
service_case.price_discount_premium as discount1, 
service_case.discount_level as discount2,
service_case.description_commercial,
service_case.product_line,
service_case.product_service,
service_case.billing_account_number,
service_case.opened_date,
dat.fiscal_quarter_name AS case_opened_FQ,
service_case.closed_date,
billing_account.account_sales_territory as territory,
service_case.opportunity,
billing_account.account_sales_region as region,
service_case.extension_period_weeks,
case_manager_dimension.user_full_name as case_manager,
additional_submit_dimension.user_full_name as additional_submit_to,
service_case.number_of_months,
billing_account.salesforce_billing_start_date,
billing_account.salesforce_trial_days,
billing_account.salesforce_trial_flag as is_trial_account,
billing_account.trial_or_sale_indicator,
billing_account.trial_to_sale_date,
service_case.owner_id,
user_dimension.user_full_name as owner_full_name,
service_case.has_unread_comments_flag,
service_case.has_self_service_comments,
service_case.last_modified_by_id,
last_modified_dimension.user_full_name as last_modified_by_full_name,
service_case.trial_length_weeks,
service_case.billing_frequency,
service_case.cancellation_term,
comp.company_name as account_name, 
comp.company_industry,
service_case.annualized_opportunity_revenue,
product_services.delivery_product,
pib_opportunity.opportunity_country as country,
pib_opportunity.opportunity_production_url as opportunity_comments,
pib_opportunity.opportunity_name,
pib_opportunity.opportunity_amount,
pib_opportunity.opportunity_effective_date,
pib_opportunity.sale_type,
pib_opportunity.opportunity_owner,
pib_opportunity.opportunity_number,
product_services.num_seats_or_copies,
product_services.currency_iso_code,
pib_opportunity.trial_started,
service_case.sales_escalation_flag,
service_case.duplicated,
comp.goverment_account_flag AS government_account_flag,
service_case.primary_discounting_reason,
service_case.other_competitor,
service_case.law_firm 
FROM 
dimension_external_db.pib_customer_service_case_dimension as service_case 
LEFT JOIN dimension_external_db.pib_opportunity_dimension as pib_opportunity on 
     service_case.opportunity = pib_opportunity.pib_opportunity_sfdc_id 
LEFT JOIN
dimension_external_db.pib_billing_account_dimension as billing_account on 
     pib_opportunity.billing_account = billing_account.salesforce_billing_account_id 
LEFT JOIN dimension_external_db.pib_user_dimension as user_dimension on
     service_case.owner_id = user_dimension.user_sfdc_id
LEFT JOIN dimension_external_db.pib_user_dimension as case_manager_dimension on
     service_case.owner_id = case_manager_dimension.user_sfdc_id
LEFT JOIN dimension_external_db.pib_user_dimension as additional_submit_dimension on
     service_case.additional_submit_to = additional_submit_dimension.user_sfdc_id
LEFT JOIN dimension_external_db.pib_user_dimension as last_modified_dimension on
     service_case.last_modified_by_id = last_modified_dimension.user_sfdc_id
LEFT JOIN dimension_external_db.pib_product_services_dimension as product_services on 
     service_case.opportunity = product_services.opportunity
LEFT JOIN fact_external_db.pib_account_hierarchy_fact as acc_hier on
     pib_opportunity.pib_opportunity_sfdc_id = acc_hier.pib_opportunity_sfdc_id
LEFT JOIN (SELECT company_sfdc_id, company_name, company_industry, goverment_account_flag FROM dimension_external_db.pib_company_dimension WHERE
	status_flag <<>> 'DELETE') as comp
	on acc_hier.company_sfdc_id = comp.company_sfdc_id
LEFT JOIN reference_external_db.date_dimension dat ON date(dat.full_date) = date(service_case.opened_date) 
where service_case.record_type = '012390000005z2eAAA' and service_case.status_flag <<>> 'DELETE'
