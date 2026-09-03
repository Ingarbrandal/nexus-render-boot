#!/bin/sh
set -eu
echo "nexus-render-boot: cloning Ingarbrandal/nexus-fish"
rm -rf /opt/nexus-fish
git clone --depth 1 "https://x-access-token:${GITHUB_TOKEN}@github.com/Ingarbrandal/nexus-fish.git" /opt/nexus-fish
cd /opt/nexus-fish/backend
# Skip test deps and fat unused wheels. Do not edit nexus-fish.
# Hosted ENC + IAS do not need numpy/pyarrow (NeruScope parquet) or
# pdfplumber (document ingest). Keep the playwright Python wheel so
# acquisition routers can import playwright.async_api — do not run
# `playwright install` (no browsers). Keep boto3, paho-mqtt, asyncua,
# and the fastapi/uvicorn/sqlalchemy stack.
grep -vE '^(pytest-asyncio|pytest|aiosqlite|numpy|pyarrow|pdfplumber)([=<>!~]|$)' \
  requirements.txt > /tmp/requirements.render.txt
PIP_DISABLE_PIP_VERSION_CHECK=1 pip install --no-cache-dir -r /tmp/requirements.render.txt
if [ "${AIS_LIVE_STREAMS:-0}" = "1" ]; then
  echo "starting AIS worker"
  exec python -m pipeline.ais_live
fi
echo "starting API on PORT=${PORT:-10000}"
exec uvicorn app.main:app --host 0.0.0.0 --port "${PORT:-10000}"
