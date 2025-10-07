
WITH source AS (
    SELECT * FROM {{ source('raw_data', 'users') }}
),

renamed AS (
    SELECT
        user_id,
        full_name,
        email,
        phone_number,
        city,
        country,
        -- Cast the timestamp to UTC for standardization
        CAST(created_at AS TIMESTAMP) AS created_at_utc
    FROM source
)

SELECT * FROM renamed
