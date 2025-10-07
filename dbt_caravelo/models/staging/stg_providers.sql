
WITH source AS (
    SELECT * FROM {{ source('raw_data', 'providers') }}
),

renamed AS (
    SELECT
        provider_id,
        provider_name,
        api_key,
        -- Cast the timestamp to UTC for standardization
        CAST(created_at AS TIMESTAMP) AS created_at_utc
    FROM source
)

SELECT * FROM renamed
