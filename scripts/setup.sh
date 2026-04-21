#!/bin/sh

echo "======================================"
echo " RPG Bot & Theme Automator"
echo "======================================"

echo "[1/4] Waiting for Rocket.Chat to be healthy..."
until curl -sf http://rocketchat-1:3000/api/info > /dev/null; do
  echo "  Still waiting..."
  sleep 5
done
echo "  Rocket.Chat is UP."

echo "[2/4] Installing dependencies..."
cd /workspace/rocketchat-app
npm install --silent

echo "[3/4] Applying RPG Theme & creating channels/roles..."
cd /workspace
node scripts/apply-discord-theme.js

echo "[4/4] Packaging & deploying GameMaster App..."
cd /workspace/rocketchat-app

# Package the app into a zip
npx --yes @rocket.chat/apps-cli package

APP_ZIP=$(ls *.zip 2>/dev/null | head -n 1)

if [ -z "$APP_ZIP" ]; then
  echo "  WARNING: No zip found, skipping app deploy."
else
  echo "  Logging in to get auth token..."

  # Single login call — parse both fields from one response
  LOGIN_RESPONSE=$(curl -sf \
    -H "Content-Type: application/json" \
    -d "{\"user\":\"${ADMIN_USERNAME:-admin}\",\"password\":\"${ADMIN_PASS:-Admin456!}\"}" \
    http://rocketchat-1:3000/api/v1/login)

  AUTH_TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"authToken":"[^"]*"' | cut -d'"' -f4)
  USER_ID=$(echo "$LOGIN_RESPONSE" | grep -o '"userId":"[^"]*"' | cut -d'"' -f4)

  if [ -z "$AUTH_TOKEN" ] || [ -z "$USER_ID" ]; then
    echo "  ERROR: Login failed, skipping app deploy."
  else
    echo "  Deploying $APP_ZIP..."
    curl -sf \
      -F "app=@${APP_ZIP}" \
      -H "X-Auth-Token: ${AUTH_TOKEN}" \
      -H "X-User-Id: ${USER_ID}" \
      http://rocketchat-1:3000/api/apps \
      && echo "  App deployed successfully." \
      || echo "  App deploy failed (may already be installed)."
  fi
fi

echo "======================================"
echo " SETUP COMPLETE! RPG SERVER READY."
echo "======================================"
