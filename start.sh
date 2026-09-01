#!/bin/sh
set -eu
echo "nexus-render-boot: cloning Ingarbrandal/nexus-fish"
rm -rf /opt/nexus-fish
git clone --depth 1 "https://x-access-token:${GITHUB_TOKEN}@github.com/Ingarbrandal/nexus-fish.git" /opt/nexus-fish
cd /opt/nexus-fish/backend
pip install --no-cache-dir -r requirements.txt
if [ "${AIS_LIVE_STREAMS:-0}" = "1" ]; then
  echo "starting AIS worker"
  exec python -m pipeline.ais_live
fi
echo "starting API on PORT=${PORT:-10000}"
exec uvicorn app.main:app --host 0.0.0.0 --port "${PORT:-10000}"
