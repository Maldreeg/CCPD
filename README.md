# Contact Center Dashboard

Portfolio project for SQL KPI analysis of contact center operations in BigQuery, powering a Looker Studio dashboard.

## Data note
The dataset is synthetic and generated locally by `generate_data.py`.

## Schema (`cc_analytics.calls`)
- `call_id` STRING
- `call_start` TIMESTAMP
- `queue` STRING (`Billing`, `Tech Support`, `Sales`, `General`)
- `agent_id` STRING (`A01`-`A30`)
- `wait_sec` INT64
- `handle_sec` INT64
- `abandoned` BOOL
- `resolved_first_call` BOOL
- `csat` INT64 (1-5, null when abandoned)

## KPI definitions
- **Total calls**: count of call records.
- **Abandonment rate**: average of `abandoned` as 0/1.
- **Avg handle time**: average `handle_sec` for non-abandoned calls.
- **Avg wait**: average `wait_sec`.
- **Service level (20s)**: share of non-abandoned calls with `wait_sec <= 20`.
- **FCR rate**: average `resolved_first_call` for non-abandoned calls.
- **Avg CSAT**: average `csat` for answered calls.

## Run
1. Generate synthetic CSV:
   - `python /home/runner/work/CCPD/CCPD/generate_data.py`
2. In BigQuery sandbox, create dataset `cc_analytics`.
3. Load `/home/runner/work/CCPD/CCPD/data/calls.csv` into table `cc_analytics.calls`.
4. Run SQL files in order:
   - `/home/runner/work/CCPD/CCPD/sql/01_clean.sql`
   - `/home/runner/work/CCPD/CCPD/sql/02_kpis.sql`
   - `/home/runner/work/CCPD/CCPD/sql/03_agents.sql`
   - `/home/runner/work/CCPD/CCPD/sql/04_trends.sql`
5. Connect Looker Studio to BigQuery outputs and build charts.

## Key findings
- [Placeholder] Peak demand windows and staffing implication.
- [Placeholder] Queue-level service and abandonment variance.
- [Placeholder] Agent performance opportunities.
- [Placeholder] CSAT relationship to wait and FCR.

## Screenshot
![Dashboard Screenshot Placeholder](./dashboard-screenshot-placeholder.png)
