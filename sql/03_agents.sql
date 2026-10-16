WITH per_agent AS (
  SELECT
    agent_id,
    queue,
    COUNT(*) AS total_calls,
    AVG(IF(abandoned, NULL, handle_sec)) AS avg_handle_time_sec,
    AVG(wait_sec) AS avg_wait_sec,
    AVG(CAST(abandoned AS INT64)) AS abandonment_rate,
    AVG(IF(abandoned, NULL, CAST(resolved_first_call AS INT64))) AS fcr_rate,
    AVG(csat) AS avg_csat
  FROM `cc_analytics.calls_clean`
  GROUP BY agent_id, queue
),
team_avg AS (
  SELECT AVG(avg_csat) AS team_avg_csat FROM per_agent
)
SELECT
  p.*,
  RANK() OVER (ORDER BY p.avg_csat DESC, p.fcr_rate DESC, p.avg_handle_time_sec ASC) AS csat_rank,
  p.avg_csat < t.team_avg_csat AS below_team_avg_csat
FROM per_agent p
CROSS JOIN team_avg t
ORDER BY csat_rank, agent_id;
