
{{
  config(
    materialized='view',
    description='External-facing data mart with anonymized user data.'
  )
}}

WITH fct_subscriptions AS (
    SELECT * FROM {{ ref('fct_subscriptions') }}
),

dim_providers AS (
    SELECT * FROM {{ ref('dim_providers') }}
),

dim_plans AS (
    SELECT * FROM {{ ref('dim_plans') }}
)

SELECT
    s.subscription_id,
    p.provider_name,
    pl.plan_name,
    pl.price,
    pl.currency,
    pl.billing_frequency,
    s.start_date,
    s.end_date,
    s.status,
    s.mrr
FROM fct_subscriptions s
LEFT JOIN dim_providers p ON s.dim_provider_fk = p.dim_provider_pk
LEFT JOIN dim_plans pl ON s.dim_plan_fk = pl.dim_plan_pk
