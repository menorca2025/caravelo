-- models/marts/fct_revenue_recognition.sql

WITH subscription_events AS (
    SELECT
        event_id,
        subscription_id,
        dim_plan_fk,
        event_timestamp_utc,
        amount_eur
    FROM {{ ref('fct_subscription_events') }}
    WHERE event_type IN ('subscription_created', 'renewal_successful') AND amount_eur > 0
),

plans AS (
    SELECT
        dim_plan_pk,
        billing_frequency
    FROM {{ ref('dim_plans') }}
),

-- Calculate the service period for each successful payment and report the revenue event.
-- The revenue is recognized on the date of the event.
final AS (
    SELECT
        CAST(se.event_timestamp_utc AS DATE) AS revenue_date,
        se.subscription_id,
        se.dim_plan_fk,
        se.amount_eur AS recognized_revenue_eur,
        p.billing_frequency,
        -- Calculate the start and end of the service period for context
        CAST(se.event_timestamp_utc AS DATE) AS service_start_date,
        CASE
            WHEN p.billing_frequency = 'monthly' THEN DATE_ADD(CAST(se.event_timestamp_utc AS DATE), INTERVAL 1 MONTH)
            WHEN p.billing_frequency = 'quarterly' THEN DATE_ADD(CAST(se.event_timestamp_utc AS DATE), INTERVAL 3 MONTH)
            WHEN p.billing_frequency = 'annual' THEN DATE_ADD(CAST(se.event_timestamp_utc AS DATE), INTERVAL 1 YEAR)
        END AS service_end_date
    FROM subscription_events se
    JOIN plans p ON se.dim_plan_fk = p.dim_plan_pk
)

SELECT
    revenue_date,
    subscription_id,
    dim_plan_fk,
    billing_frequency,
    service_start_date,
    service_end_date,
    recognized_revenue_eur AS monthly_recognized_revenue_eur -- Alias maintained for downstream compatibility
FROM final
ORDER BY 1, 2
