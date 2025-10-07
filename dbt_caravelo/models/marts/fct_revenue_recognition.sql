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

-- Calculate the service period for each successful payment
service_periods AS (
    SELECT
        se.event_id,
        se.subscription_id,
        se.dim_plan_fk,
        se.amount_eur,
        p.billing_frequency,
        CAST(se.event_timestamp_utc AS DATE) AS service_start_date,
        -- Calculate the end of the service period based on the billing frequency
        CASE
            WHEN p.billing_frequency = 'monthly' THEN DATE_ADD(CAST(se.event_timestamp_utc AS DATE), INTERVAL 1 MONTH)
            WHEN p.billing_frequency = 'quarterly' THEN DATE_ADD(CAST(se.event_timestamp_utc AS DATE), INTERVAL 3 MONTH)
            WHEN p.billing_frequency = 'annual' THEN DATE_ADD(CAST(se.event_timestamp_utc AS DATE), INTERVAL 1 YEAR)
        END AS service_end_date
    FROM subscription_events se
    JOIN plans p ON se.dim_plan_fk = p.dim_plan_pk
),

-- Generate a row for each month within the service period
-- Using a date spine to correctly allocate revenue across months
date_spine AS (
    SELECT
        event_id,
        DATE_TRUNC(day, MONTH) AS revenue_month
    FROM service_periods,
    UNNEST(GENERATE_DATE_ARRAY(service_start_date, CAST(service_end_date AS DATE) - INTERVAL 1 DAY, INTERVAL 1 DAY)) as day
    GROUP BY 1, 2
),

-- Calculate the number of months in each service period to correctly divide the revenue
months_in_period AS (
    SELECT
        event_id,
        COUNT(DISTINCT revenue_month) as num_months
    FROM date_spine
    GROUP BY 1
),

-- Join back to get the final monthly recognized revenue
final AS (
    SELECT
        ds.revenue_month,
        sp.subscription_id,
        sp.dim_plan_fk,
        sp.amount_eur / mip.num_months AS recognized_revenue_eur
    FROM date_spine ds
    JOIN service_periods sp ON ds.event_id = sp.event_id
    JOIN months_in_period mip ON ds.event_id = mip.event_id
)

SELECT
    revenue_month,
    subscription_id,
    dim_plan_fk,
    SUM(recognized_revenue_eur) AS monthly_recognized_revenue_eur
FROM final
GROUP BY 1, 2, 3
ORDER BY 1, 2
