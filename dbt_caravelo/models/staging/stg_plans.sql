
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
        created_at
    FROM source
)

SELECT * FROM renamed
