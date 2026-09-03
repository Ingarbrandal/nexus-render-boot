#!/bin/sh
set -eu
echo "nexus-render-boot: cloning Ingarbrandal/nexus-fish"
rm -rf /opt/nexus-fish
git clone --depth 1 "https://x-access-token:${GITHUB_TOKEN}@github.com/Ingarbrandal/nexus-fish.git" /opt/nexus-fish
cd /opt/nexus-fish/backend
# Render starter is 512 MiB. playwright (~48 MB wheel) plus pytest/aiosqlite
# OOM pip (exit 137). Filter them into a temp file; do not edit nexus-fish.
# Keep paho-mqtt, asyncua, numpy, pyarrow, and the rest of the API runtime.
grep -vE '^(playwright|pytest-asyncio|pytest|aiosqlite)([=<>!~]|$)' \
  requirements.txt > /tmp/requirements.render.txt
PIP_DISABLE_PIP_VERSION_CHECK=1 pip install --no-cache-dir -r /tmp/requirements.render.txt
if [ "${AIS_LIVE_STREAMS:-0}" = "1" ]; then
  echo "starting AIS worker"
  exec python -m pipeline.ais_live
fi
echo "starting API on PORT=${PORT:-10000}"
exec uvicorn app.main:app --host 0.0.0.0 --port "${PORT:-10000}"
