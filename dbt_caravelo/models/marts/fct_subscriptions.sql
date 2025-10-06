
WITH subscriptions AS (
    SELECT * FROM {{ ref('stg_subscriptions') }}
),

plans AS (
    SELECT * FROM {{ ref('dim_plans') }}
),

final AS (
    SELECT
        subscriptions.subscription_id,
        subscriptions.plan_id AS dim_plan_fk,
        subscriptions.user_id AS dim_user_fk,
        subscriptions.provider_id AS dim_provider_fk,
        subscriptions.start_date,
        subscriptions.end_date,
        subscriptions.status,
        plans.price,
        plans.currency,
        plans.billing_frequency,
        CASE
            WHEN plans.billing_frequency = 'monthly' THEN plans.price
            WHEN plans.billing_frequency = 'quarterly' THEN plans.price / 3
            WHEN plans.billing_frequency = 'annual' THEN plans.price / 12
        END AS mrr
    FROM subscriptions
    LEFT JOIN plans ON subscriptions.plan_id = plans.dim_plan_pk
)

SELECT * FROM final
