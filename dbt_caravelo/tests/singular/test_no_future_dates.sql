-- tests/singular/test_no_future_dates.sql
SELECT *
FROM {{ model }}
WHERE CAST({{ column_name }} AS DATETIME) > CURRENT_DATETIME()
