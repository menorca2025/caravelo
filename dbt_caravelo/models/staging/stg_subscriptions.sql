
WITH source AS (
    SELECT * FROM {{ source('raw_data', 'subscriptions') }}
),

renamed AS (
    SELECT
        subscription_id,
        plan_id,
        user_id,
        provider_id,
        start_date,
        end_date,
        status,
        created_at
    FROM source
)

SELECT * FROM renamed
