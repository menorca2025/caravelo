
WITH source AS (
    SELECT * FROM {{ source('raw_data', 'plans') }}
),

renamed AS (
    SELECT
        plan_id,
        provider_id,
        plan_name,
        price,
        currency,
        billing_frequency,
        features,
        -- Cast the timestamp to UTC for standardization
        CAST(created_at AS TIMESTAMP) AS created_at_utc
    FROM source
)

SELECT * FROM renamed
