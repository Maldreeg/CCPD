CREATE OR REPLACE VIEW `cc_analytics.calls_clean` AS
WITH src AS (
  SELECT
    call_id,
    TIMESTAMP(call_start) AS call_start,
    queue,
    agent_id,
    COALESCE(wait_sec, 0) AS wait_sec,
    COALESCE(handle_sec, 0) AS handle_sec,
    COALESCE(abandoned, FALSE) AS abandoned,
    COALESCE(resolved_first_call, FALSE) AS resolved_first_call,
    csat,
    ROW_NUMBER() OVER (PARTITION BY call_id ORDER BY TIMESTAMP(call_start) DESC) AS rn
  FROM `cc_analytics.calls`
)
SELECT
  call_id,
  call_start,
  queue,
  agent_id,
  wait_sec,
  handle_sec,
  abandoned,
  resolved_first_call,
  csat,
  EXTRACT(HOUR FROM call_start) AS hour,
  EXTRACT(DAYOFWEEK FROM call_start) AS weekday,
  EXTRACT(MONTH FROM call_start) AS month,
  (NOT abandoned AND wait_sec <= 20) AS answered_within_20s
FROM src
WHERE rn = 1;
