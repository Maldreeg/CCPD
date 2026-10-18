# Generate synthetic contact center calls dataset
from datetime import datetime
import random
import pandas as pd

SEED = 42
N_ROWS = 50000


def _sample_call_start() -> datetime:
    month = random.choice([1, 2, 3, 4, 5, 6])
    day = random.randint(1, 28)
    date = datetime(2026, month, day)

    weekday = date.weekday()
    weekday_hours = [9, 10, 11, 14, 15, 16]
    other_hours = [h for h in range(8, 20) if h not in weekday_hours]

    if weekday < 5:
        hour = random.choices([random.choice(weekday_hours), random.choice(other_hours)], weights=[0.7, 0.3], k=1)[0]
    else:
        hour = random.choices([random.choice(weekday_hours), random.choice(other_hours)], weights=[0.45, 0.55], k=1)[0]

    minute = random.randint(0, 59)
    second = random.randint(0, 59)
    return datetime(2026, month, day, hour, minute, second)


def _sample_queue() -> str:
    return random.choices(
        ["Billing", "Tech Support", "Sales", "General"],
        weights=[0.28, 0.31, 0.19, 0.22],
        k=1,
    )[0]


def _sample_wait_sec(is_weekday: bool) -> int:
    scale = 38 if is_weekday else 46
    wait = int(random.lognormvariate(3.2, 0.75) + random.expovariate(1 / scale))
    return max(0, min(wait, 1200))


def _sample_handle_sec(queue: str) -> int:
    if queue == "Tech Support":
        base = random.lognormvariate(6.1, 0.45)
    elif queue == "Billing":
        base = random.lognormvariate(5.75, 0.42)
    elif queue == "Sales":
        base = random.lognormvariate(5.55, 0.4)
    else:
        base = random.lognormvariate(5.65, 0.41)
    return max(60, min(int(base), 3600))


def main() -> None:
    random.seed(SEED)

    records = []
    for i in range(1, N_ROWS + 1):
        call_start = _sample_call_start()
        queue = _sample_queue()
        wait_sec = _sample_wait_sec(call_start.weekday() < 5)

        abandon_prob = 0.03 + (0.11 / (1 + pow(2.71828, -(wait_sec - 110) / 55)))
        abandoned = random.random() < min(0.28, abandon_prob)

        handle_sec = 0 if abandoned else _sample_handle_sec(queue)

        base_fcr = {"Billing": 0.76, "Tech Support": 0.70, "Sales": 0.82, "General": 0.74}[queue]
        wait_penalty = min(0.18, wait_sec / 1200)
        resolved_first_call = (not abandoned) and (random.random() < max(0.25, base_fcr - wait_penalty))

        if abandoned:
            csat = None
        else:
            csat_score = 4.6
            csat_score -= min(1.6, wait_sec / 150)
            csat_score -= 0.25 if not resolved_first_call else 0.0
            csat_score += random.uniform(-0.8, 0.7)
            csat = int(round(max(1, min(5, csat_score))))

        records.append(
            {
                "call_id": f"C{i:06d}",
                "call_start": call_start,
                "queue": queue,
                "agent_id": f"A{random.randint(1, 30):02d}",
                "wait_sec": wait_sec,
                "handle_sec": handle_sec,
                "abandoned": abandoned,
                "resolved_first_call": resolved_first_call,
                "csat": csat,
            }
        )

    df = pd.DataFrame.from_records(records)

    target = "/home/runner/work/CCPD/CCPD/data"
    import os

    os.makedirs(target, exist_ok=True)
    df.to_csv(f"{target}/calls.csv", index=False)


if __name__ == "__main__":
    main()
