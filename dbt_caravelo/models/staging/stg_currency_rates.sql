WITH source AS (
    SELECT * FROM {{ source('raw_data', 'currency_rates') }}
),

renamed AS (
    SELECT
        CAST(date AS DATE) AS rate_date,
        currency,
        rate_to_eur
    FROM source
)

SELECT * FROM renamed
