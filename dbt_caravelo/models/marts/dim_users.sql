
WITH users AS (
    SELECT * FROM {{ ref('stg_users') }}
)

SELECT
    user_id AS dim_user_pk,
    full_name,
    email,
    phone_number,
    address,
    created_at
FROM users
