WITH base AS (
  SELECT
    DATE(call_start) AS call_date,
    EXTRACT(HOUR FROM call_start) AS hour,
    EXTRACT(DAYOFWEEK FROM call_start) AS weekday,
    abandoned
  FROM `cc_analytics.calls_clean`
),
heatmap AS (
  SELECT
    weekday,
    hour,
    COUNT(*) AS call_volume
  FROM base
  GROUP BY weekday, hour
),
daily_abandonment AS (
  SELECT
    call_date,
    AVG(CAST(abandoned AS INT64)) AS abandonment_rate
  FROM base
  GROUP BY call_date
),
abandonment_ma AS (
  SELECT
    call_date,
    abandonment_rate,
    AVG(abandonment_rate) OVER (
      ORDER BY call_date
      ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS abandonment_rate_7d_ma
  FROM daily_abandonment
)
SELECT
  'heatmap' AS metric_type,
  CAST(NULL AS DATE) AS call_date,
  weekday,
  hour,
  call_volume,
  CAST(NULL AS FLOAT64) AS abandonment_rate,
  CAST(NULL AS FLOAT64) AS abandonment_rate_7d_ma
FROM heatmap
UNION ALL
SELECT
  'abandonment_trend' AS metric_type,
  call_date,
  CAST(NULL AS INT64) AS weekday,
  CAST(NULL AS INT64) AS hour,
  CAST(NULL AS INT64) AS call_volume,
  abandonment_rate,
  abandonment_rate_7d_ma
FROM abandonment_ma
ORDER BY metric_type, call_date, weekday, hour;
