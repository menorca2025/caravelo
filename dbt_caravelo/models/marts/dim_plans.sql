
WITH plans AS (
    SELECT * FROM {{ ref('stg_plans') }}
)
-- dummy comment to test git changes
-- IGNORE ---

SELECT
    plan_id AS dim_plan_pk,
    provider_id,
    plan_name,
    price,
    currency,
    billing_frequency,
    features,
    created_at
FROM plans
