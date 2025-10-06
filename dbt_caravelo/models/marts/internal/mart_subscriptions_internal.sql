
{{
  config(
    materialized='table',
    description='Internal-facing data mart with all available data for in-depth analysis.'
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
),

dim_users AS (
    SELECT * FROM {{ ref('dim_users') }}
)

SELECT
    s.subscription_id,
    p.provider_name,
    pl.plan_name,
    u.full_name AS user_full_name,
    u.email AS user_email,
    pl.price,
    pl.currency,
    pl.billing_frequency,
    s.start_date,
    s.end_date,
    s.status,
    s.mrr,
    p.created_at AS provider_created_at,
    pl.created_at AS plan_created_at,
    u.created_at AS user_created_at
FROM fct_subscriptions s
LEFT JOIN dim_providers p ON s.dim_provider_fk = p.dim_provider_pk
LEFT JOIN dim_plans pl ON s.dim_plan_fk = pl.dim_plan_pk
LEFT JOIN dim_users u ON s.dim_user_fk = u.dim_user_pk
