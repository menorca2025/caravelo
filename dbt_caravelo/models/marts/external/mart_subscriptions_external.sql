
{{
  config(
    materialized='view',
    description='External-facing data mart with anonymized user data.'
  )
}}

WITH fct_subscription_events AS (
    SELECT * FROM {{ ref('fct_subscription_events') }}
),

dim_plans AS (
    SELECT * FROM {{ ref('dim_plans') }}
)

SELECT
    s.event_id,
    s.subscription_id,
    pl.plan_name,
    pl.price,
    pl.currency,
    pl.billing_frequency,
    s.event_type,
    s.event_timestamp_utc,
    s.original_amount,
    s.amount_eur
FROM fct_subscription_events s
LEFT JOIN dim_plans pl ON s.dim_plan_fk = pl.dim_plan_pk
