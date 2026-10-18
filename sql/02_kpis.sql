WITH base AS (
  SELECT
    DATE_TRUNC(DATE(call_start), MONTH) AS month,
    queue,
    abandoned,
    wait_sec,
    handle_sec,
    answered_within_20s,
    resolved_first_call,
    csat
  FROM `cc_analytics.calls_clean`
),
monthly AS (
  SELECT
    month,
    'ALL' AS queue,
    COUNT(*) AS total_calls,
    AVG(CAST(abandoned AS INT64)) AS abandonment_rate,
    AVG(IF(abandoned, NULL, handle_sec)) AS avg_handle_time_sec,
    AVG(wait_sec) AS avg_wait_sec,
    AVG(CAST(answered_within_20s AS INT64)) AS service_level_20s,
    AVG(IF(abandoned, NULL, CAST(resolved_first_call AS INT64))) AS fcr_rate,
    AVG(csat) AS avg_csat
  FROM base
  GROUP BY month
),
per_queue AS (
  SELECT
    month,
    queue,
    COUNT(*) AS total_calls,
    AVG(CAST(abandoned AS INT64)) AS abandonment_rate,
    AVG(IF(abandoned, NULL, handle_sec)) AS avg_handle_time_sec,
    AVG(wait_sec) AS avg_wait_sec,
    AVG(CAST(answered_within_20s AS INT64)) AS service_level_20s,
    AVG(IF(abandoned, NULL, CAST(resolved_first_call AS INT64))) AS fcr_rate,
    AVG(csat) AS avg_csat
  FROM base
  GROUP BY month, queue
)
SELECT * FROM monthly
UNION ALL
SELECT * FROM per_queue
ORDER BY month, queue;
