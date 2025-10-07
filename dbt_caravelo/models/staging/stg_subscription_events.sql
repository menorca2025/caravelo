
WITH source AS (
    SELECT * FROM {{ ref('subscription_events') }}
),

renamed AS (
    SELECT
        event_id,
        subscription_id,
        plan_id,
        user_id,
        event_type,
        -- Cast the timestamp to UTC for standardization
        CAST(event_timestamp AS TIMESTAMP) AS event_timestamp_utc,
        amount,
        currency
    FROM source
)

SELECT * FROM renamed
