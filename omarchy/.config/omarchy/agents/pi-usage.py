#!/usr/bin/env python3
"""Generate the pi usage record for the omarchy agents panel.

Scans every pi session (.jsonl) under ~/.pi/agent/sessions/ and aggregates
assistant-message token usage into the same display-ready JSON record shape
that the built-in collectors (claude/codex/fireworks) write. The omarchy
agents panel picks up any *.json record that lands in the usage directory, so
this produces ~/.local/state/omarchy/agents/usage/pi.json.

Usage:
    python3 pi-usage.py            # print the record to stdout
    python3 pi-usage.py --write    # write it to the usage directory
"""

import argparse
import json
import os
import sys
from datetime import datetime, timedelta, timezone
from pathlib import Path

AGENT_ID = "pi"
AGENT_NAME = "Pi"

HOME = Path.home()
SESSIONS_ROOTS = [
    HOME / ".pi" / "agent" / "sessions",
    HOME / ".omp" / "agent" / "sessions",
]
USAGE_DIR = Path(
    os.environ.get("XDG_STATE_HOME", HOME / ".local" / "state")
) / "omarchy" / "agents" / "usage"


def number(value):
    try:
        return int(value or 0)
    except Exception:
        return 0


def local_day(value):
    """Normalize a timestamp (ms epoch, s epoch, or ISO string) to YYYY-MM-DD."""
    if value is None:
        return datetime.now().strftime("%Y-%m-%d")
    if isinstance(value, (int, float)):
        if value > 10_000_000_000:
            value = value / 1000
        return datetime.fromtimestamp(value).strftime("%Y-%m-%d")
    text = str(value)
    try:
        if text.endswith("Z"):
            dt = datetime.fromisoformat(text[:-1] + "+00:00")
        else:
            dt = datetime.fromisoformat(text)
        if dt.tzinfo is not None:
            dt = dt.astimezone()
        return dt.strftime("%Y-%m-%d")
    except Exception:
        return datetime.now().strftime("%Y-%m-%d")


def model_name(raw):
    value = str(raw or "pi")
    return value if value else "pi"


def build_record():
    now = datetime.now()
    today = now.strftime("%Y-%m-%d")
    recent_dates = [
        (now - timedelta(days=offset)).strftime("%Y-%m-%d")
        for offset in range(6, -1, -1)
    ]
    recent = {day: {"date": day, "messageCount": 0} for day in recent_dates}

    today_prompts = 0
    today_total_tokens = 0
    today_tokens_by_model = {}
    today_sessions = set()
    total_prompts = 0
    total_sessions = set()
    active_days = set()
    model_usage = {}

    def add_usage(day, session_key, model, input_tokens, output_tokens,
                  cache_read, cache_write):
        nonlocal today_prompts, today_total_tokens, total_prompts
        total = input_tokens + output_tokens + cache_read + cache_write
        total_prompts += 1
        total_sessions.add(session_key)
        active_days.add(day)

        bucket = model_usage.setdefault(model, {
            "inputTokens": 0,
            "outputTokens": 0,
            "cacheReadInputTokens": 0,
            "cacheCreationInputTokens": 0,
        })
        bucket["inputTokens"] += input_tokens
        bucket["outputTokens"] += output_tokens
        bucket["cacheReadInputTokens"] += cache_read
        bucket["cacheCreationInputTokens"] += cache_write

        if day in recent:
            recent[day]["messageCount"] += total

        if day == today:
            today_prompts += 1
            today_sessions.add(session_key)
            today_total_tokens += total
            today_tokens_by_model[model] = (
                today_tokens_by_model.get(model, 0) + total
            )

    seen = set()
    for root in SESSIONS_ROOTS:
        if not root.exists():
            continue
        for path in sorted(root.rglob("*.jsonl")):
            try:
                with open(path, "r", encoding="utf-8", errors="replace") as fh:
                    for line in fh:
                        line = line.strip()
                        if not line:
                            continue
                        try:
                            entry = json.loads(line)
                        except Exception:
                            continue
                        if entry.get("type") != "message":
                            continue
                        message_key = str(path) + ":" + str(entry.get("id") or "")
                        if message_key in seen:
                            continue
                        seen.add(message_key)
                        message = entry.get("message") or {}
                        if message.get("role") != "assistant":
                            continue
                        usage = message.get("usage") or {}
                        if not usage:
                            continue
                        total = number(usage.get("totalTokens"))
                        input_tokens = number(usage.get("input"))
                        output_tokens = number(usage.get("output"))
                        cache_read = number(usage.get("cacheRead"))
                        cache_write = number(usage.get("cacheWrite"))
                        if total and not (input_tokens or output_tokens
                                          or cache_read or cache_write):
                            input_tokens = total
                        if not (input_tokens or output_tokens
                                or cache_read or cache_write):
                            continue
                        day = local_day(entry.get("timestamp")
                                        or message.get("timestamp"))
                        add_usage(day, str(path),
                                  model_name(message.get("model")),
                                  input_tokens, output_tokens,
                                  cache_read, cache_write)
            except OSError:
                continue

    record = {
        "schemaVersion": 1,
        "id": AGENT_ID,
        "name": AGENT_NAME,
        "updatedAt": now.astimezone().isoformat(),
        "ready": True,
        "hasLocalStats": True,
        "hasPromptStats": True,
        "tierLabel": "",
        "usageStatusText": "",
        "authHelpText": "",
        "limits": [],
        "todayPrompts": today_prompts,
        "todaySessions": len(today_sessions),
        "todayTotalTokens": today_total_tokens,
        "todayTokensByModel": today_tokens_by_model,
        "recentDays": [recent[d] for d in recent_dates],
        "totalPrompts": total_prompts,
        "totalSessions": len(total_sessions),
        "activeDays": len(active_days),
        "activeDates": sorted(active_days),
        "modelUsage": model_usage,
    }
    return record


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--write", action="store_true",
                        help="write the record to the usage directory")
    args = parser.parse_args()

    record = build_record()
    if args.write:
        USAGE_DIR.mkdir(parents=True, exist_ok=True)
        tmp = USAGE_DIR / (".pi.XXXXXX")
        # atomic-ish write
        out = USAGE_DIR / "pi.json"
        out.write_text(json.dumps(record) + "\n", encoding="utf-8")
        print(f"wrote {out}", file=sys.stderr)
    else:
        print(json.dumps(record))


if __name__ == "__main__":
    main()
