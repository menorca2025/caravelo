
-- fct_subscription_events.sql

-- This model captures the financial impact of each subscription event in a common currency (EUR).
-- It serves as the transactional backbone for financial analysis.

WITH events AS (
    SELECT * FROM {{ ref('stg_subscription_events') }}
),

currency_rates AS (
    SELECT * FROM {{ ref('stg_currency_rates') }}
),

-- Use a window function to fill missing currency rates with the last known rate.
-- This prevents data loss if a rate is not available for a specific event date.
filled_rates AS (
    SELECT
        rate_date,
        currency,
        rate_to_eur,
        LAST_VALUE(rate_to_eur IGNORE NULLS) OVER (
            PARTITION BY currency 
            ORDER BY rate_date 
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS filled_rate_to_eur
    FROM currency_rates
),

final AS (
    SELECT
        -- Keys
        events.event_id,
        events.subscription_id,
        events.plan_id AS dim_plan_fk,
        events.user_id AS dim_user_fk,

        -- Event details
        events.event_type,
        events.event_timestamp_utc,

        -- Financials
        events.amount AS original_amount,
        events.currency AS original_currency,
        
        -- Convert all amounts to EUR for consistent reporting.
        -- If the currency is already EUR, the rate is 1. Otherwise, use the filled rate.
        COALESCE(rates.filled_rate_to_eur, 1) AS exchange_rate_to_eur,
        ROUND(events.amount * COALESCE(rates.filled_rate_to_eur, 1), 2) AS amount_eur

    FROM events
    -- Left join to currency rates on the date of the event.
    LEFT JOIN filled_rates AS rates
        ON CAST(events.event_timestamp_utc AS DATE) = rates.rate_date
        AND events.currency = rates.currency
)

SELECT * FROM final

