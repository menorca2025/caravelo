
WITH providers AS (
    SELECT * FROM {{ ref('stg_providers') }}
)
--another dummy change
SELECT
    provider_id AS dim_provider_pk,
    provider_name,
    created_at_utc
FROM providers
