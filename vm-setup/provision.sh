#!/bin/bash
set -euo pipefail

APP_SRC="${APP_SRC:-/opt/topic2-src/app}"
APP_DST="/opt/topic2-api"

if [[ ! -f "${APP_SRC}/main.py" || ! -f "${APP_SRC}/requirements.txt" ]]; then
  echo "missing ${APP_SRC}/main.py or requirements.txt" >&2
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y python3 python3-venv python3-pip ca-certificates

install -d -m 0755 "${APP_DST}"
cp "${APP_SRC}/main.py" "${APP_DST}/main.py"
cp "${APP_SRC}/requirements.txt" "${APP_DST}/requirements.txt"

python3 -m venv "${APP_DST}/.venv"
"${APP_DST}/.venv/bin/pip" install --no-cache-dir --upgrade pip
"${APP_DST}/.venv/bin/pip" install --no-cache-dir -r "${APP_DST}/requirements.txt"
chmod -R a+rX "${APP_DST}"

cat > /etc/systemd/system/webapi.service <<'EOF'
[Unit]
Description=SEN421 Topic 2 benchmark API
After=network.target

[Service]
Type=simple
User=nobody
Group=nogroup
WorkingDirectory=/opt/topic2-api
Environment=PYTHONDONTWRITEBYTECODE=1
Environment=PYTHONUNBUFFERED=1
ExecStart=/opt/topic2-api/.venv/bin/uvicorn main:app --host 0.0.0.0 --port 8000 --workers 2 --no-access-log
Restart=on-failure
NoNewPrivileges=true

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable webapi.service
systemctl restart webapi.service
