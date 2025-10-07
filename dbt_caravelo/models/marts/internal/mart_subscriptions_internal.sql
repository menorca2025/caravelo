
{{
  config(
    materialized='table',
    description='Internal-facing data mart with all available data for in-depth analysis.'
  )
}}

WITH fct_subscription_events AS (
    SELECT * FROM {{ ref('fct_subscription_events') }}
),

dim_plans AS (
    SELECT * FROM {{ ref('dim_plans') }}
),

dim_users AS (
    SELECT * FROM {{ ref('dim_users') }}
)

SELECT
    s.event_id,
    s.subscription_id,
    pl.plan_name,
    u.full_name AS user_full_name,
    u.email AS user_email,
    pl.price,
    pl.currency,
    pl.billing_frequency,
    s.event_type,
    s.event_timestamp_utc,
    s.original_amount,
    s.amount_eur,
    pl.created_at_utc AS plan_created_at,
    u.created_at_utc AS user_created_at
FROM fct_subscription_events s
LEFT JOIN dim_plans pl ON s.dim_plan_fk = pl.dim_plan_pk
LEFT JOIN dim_users u ON s.dim_user_fk = u.dim_user_pk
