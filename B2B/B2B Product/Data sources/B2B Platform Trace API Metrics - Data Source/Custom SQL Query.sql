-- Published data source : "B2B Platform Trace API Metrics - Data Source"  [B2B / B2B Product / Data sources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
WITH ptm AS (
    SELECT client_user_id,
           client_account_id,
           DATE_TRUNC('month', event_datetime) AS request_date,
           dd.week_number_in_fiscal_year AS request_week,
           event_level,
           transaction_status_code,
           transaction_resource_urn,
           transaction_method,
           request_headers_accept,
           request_headers_content_type,
           REGEXP_EXTRACT_ALL(transaction_resource_target, '/[^(?|/)]*') endpoint_string,
           COUNT(DISTINCT request_headers_x_dj_transaction_id) AS hits
    FROM pib_event_data.pib_platform_trace ptm
    LEFT JOIN reference_external_db.date_dimension dd ON DATE(ptm.event_datetime) = DATE(dd.full_date)
    WHERE cycle_date >>= DATE_ADD('day', -1, DATE_TRUNC('month', DATE_ADD('month', -12, CURRENT_DATE)))
        AND event_source <<>> 'in_web_apigee'
    GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11

    UNION ALL 

    SELECT client_user_id,
           client_account_id,
           DATE_TRUNC('month', event_datetime) AS request_date,
           dd.week_number_in_fiscal_year AS request_week,
           event_level,
           transaction_status_code,
           transaction_resource_urn,
           transaction_method,
           request_headers_accept,
           request_headers_content_type,
           REGEXP_EXTRACT_ALL(transaction_resource_target, '/[^(?|/)]*') endpoint_string,
           COUNT(DISTINCT request_headers_x_dj_transaction_id) AS hits
    FROM pib_event_data.pib_platform_trace_private_user ptm
    LEFT JOIN reference_external_db.date_dimension dd ON DATE(ptm.event_datetime) = DATE(dd.full_date)
    WHERE cycle_date >>= DATE_ADD('day', -1, DATE_TRUNC('month', DATE_ADD('month', -12, CURRENT_DATE)))
    GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11
),

ptm_lvs AS (
    SELECT client_user_id,
           client_account_id,
           request_date,
           request_week,
           event_level,
           transaction_status_code,
           transaction_resource_urn,
           transaction_method,
           request_headers_accept,
           request_headers_content_type,
           try(endpoint_string[1]) AS lv1_endpoint,
           CASE 
                WHEN regexp_like(try(endpoint_string[2]), '/[0-9.]+$') 
                    OR regexp_like(try(endpoint_string[2]), '/[A-Z]+$')
                    OR LENGTH(try(endpoint_string[2])) = 37
                THEN try(endpoint_string[3]) 
                ELSE try(endpoint_string[2]) 
                END AS lv2_endpoint,
           CASE 
                WHEN regexp_like(try(endpoint_string[3]), '/[0-9.]+$') 
                    OR regexp_like(try(endpoint_string[3]), '/[A-Z]+$')
                    OR LENGTH(try(endpoint_string[3])) = 37
                THEN try(endpoint_string[4]) 
                WHEN regexp_like(try(endpoint_string[2]), '/[0-9.]+$') 
                    OR regexp_like(try(endpoint_string[2]), '/[A-Z]+$')
                    OR LENGTH(try(endpoint_string[2])) = 37
                THEN 
                    CASE WHEN LENGTH(try(endpoint_string[4])) = 37
                    THEN NULL ELSE try(endpoint_string[4]) END
                ELSE try(endpoint_string[3]) 
                END AS lv3_endpoint,
           SUM(hits) AS hits
    FROM ptm 
    WHERE client_account_id IS NOT NULL AND client_account_id <<>> ''
    GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13
)

SELECT client_user_id,
       mem.plan_id,
       client_account_id,
       request_date,
       request_week,
       event_level,
       transaction_status_code,
       lower(transaction_resource_urn) AS transaction_resource_urn,
       transaction_method,
       request_headers_accept,
       request_headers_content_type,
       lower(lv1_endpoint) AS lv1_endpoint,
       CASE WHEN lv2_endpoint LIKE '/drn:archive.blogs%' THEN '/drn:archive.blogs.{id}'
            WHEN lv2_endpoint LIKE '/drn:archive.newsarticle%' THEN '/drn:archive.newsarticle.{id}'
            WHEN lv2_endpoint LIKE '/drn:archive.pdfarticle%' THEN '/drn:archive.pdfarticle.{id}'
            WHEN lv2_endpoint LIKE '/drn:archive.picturearticle%' THEN '/drn:archive.picturearticle.{id}'
            WHEN lv2_endpoint LIKE '/drn:realtime.linkedarticle%' THEN '/drn:realtime.linkedarticle.{id}'
            WHEN lv1_endpoint = '/newswires-newsletters' AND lv2_endpoint IS NOT NULL THEN '/{id}'
            WHEN transaction_resource_urn = 'urn:customerservice:api' 
            THEN CASE WHEN lv1_endpoint = '/accounts' THEN '/{account_id}'
                      WHEN lv1_endpoint = '/external-reader' THEN '/{account_id}'
                      WHEN lv1_endpoint = '/users' THEN '/{user_id}'
                      WHEN lv1_endpoint = '/redirects' THEN '/uri::account::{account_id}'
                      ELSE lower(lv2_endpoint) END 
            WHEN lower(lv2_endpoint) LIKE '/drn:consumer.content.originid.%' THEN '/drn:consumer.content.originid.{id}'
            WHEN lower(lv2_endpoint) LIKE '/drn:consumer.contentcollection.originid.%' THEN '/drn:consumer.contentcollection.originid.{id}'
            WHEN lv1_endpoint = '/risk-entity-screening-cases' AND lv3_endpoint = '/matches' THEN '/{id}'
            WHEN lv1_endpoint = '/risk-entity-screening-cases' AND lv3_endpoint = '/risk-entity-screening-associations' THEN '/{id}'
            ELSE lower(lv2_endpoint) END AS lv2_endpoint,
       CASE WHEN lv2_endpoint LIKE '%-list%' THEN NULL 
            WHEN lv2_endpoint = '/factiva-industries' AND lv3_endpoint LIKE '/i%' THEN '/{industry_code}'
            WHEN lv2_endpoint = '/factiva-newssubjects' 
                AND (lv3_endpoint LIKE '/C%' OR lv3_endpoint LIKE '/E%' OR lv3_endpoint LIKE '/M%')
            THEN '{newssubject_code}'
            WHEN lv1_endpoint = '/factiva-entity' AND lv2_endpoint = '/profiles' THEN '/{id}'
            WHEN lv1_endpoint = '/riskentities' AND lv2_endpoint IN ('/assets','/images')
                AND lower(lv3_endpoint) LIKE '/rnc%' 
            THEN '/{RNC_id}'
            WHEN lv1_endpoint = '/risk-entity-screening-cases' AND lv2_endpoint = '/matches' 
            THEN '/{screening_id}'
            WHEN lv1_endpoint = '/risk-entity-screening-cases' AND lv2_endpoint = '/risk-entity-screening-associations'
                AND lv3_endpoint LIKE '%temporary%'
            THEN '/temporary-{id}'
            WHEN lv1_endpoint = '/risk-entity-screening-cases' AND lv2_endpoint = '/risk-entity-screening-associations'
                AND lv3_endpoint NOT LIKE '%temporary%' AND lv3_endpoint <<>> '/delete'
            THEN '/{id}'
            WHEN lv1_endpoint = '/risk-entity-screening-cases' AND lv2_endpoint = '/transactions' THEN NULL 
            WHEN lv1_endpoint = '/riskentities' AND lv2_endpoint = '/profiles'
                AND lv3_endpoint IS NOT NULL
            THEN '/{id}'
            ELSE lower(lv3_endpoint) END AS lv3_endpoint,
       SUM(hits) AS transactions
FROM ptm_lvs
LEFT JOIN dimension_external_db.pib_membership_dimension mem 
    ON ptm_lvs.client_user_id = mem.user_id 
    AND ptm_lvs.client_account_id = mem.billing_account_id
WHERE lower(lv1_endpoint) <<>> '/genericproxy'
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14
