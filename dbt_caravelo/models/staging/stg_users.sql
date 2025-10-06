
WITH source AS (
    SELECT * FROM {{ source('raw_data', 'users') }}
),

renamed AS (
    SELECT
        user_id,
        full_name,
        email,
        phone_number,
        address,
        created_at
    FROM source
)

SELECT * FROM renamed
