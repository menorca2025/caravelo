
WITH source AS (
    SELECT * FROM {{ source('raw_data', 'providers') }}
),

renamed AS (
    SELECT
        provider_id,
        provider_name,
        api_key,
        created_at
    FROM source
)

SELECT * FROM renamed
