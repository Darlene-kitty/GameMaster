#!/bin/bash
# ============================================
# Configuration Jitsi Meet pour Rocket.Chat
# Voix, Vidéo, Partage d'écran
# ============================================

RC_URL="http://localhost:3000"
ADMIN_USER="admin"
ADMIN_PASS="Admin456!"

AUTH=$(curl -s -X POST "$RC_URL/api/v1/login" \
  -H "Content-Type: application/json" \
  -d "{\"user\":\"$ADMIN_USER\",\"password\":\"$ADMIN_PASS\"}")
TOKEN=$(echo $AUTH | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['data']['authToken'])" 2>/dev/null)
USER_ID=$(echo $AUTH | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['data']['userId'])" 2>/dev/null)

set_setting() {
  curl -s -X POST "$RC_URL/api/v1/settings/$1" \
    -H "X-Auth-Token: $TOKEN" -H "X-User-Id: $USER_ID" \
    -H "Content-Type: application/json" -d "{\"value\":$2}" > /dev/null
  echo "  ✅ $1"
}

echo "🎙️ Configuration Jitsi Meet (Voice/Video)..."

# Activer Jitsi
set_setting "Jitsi_Enabled" 'true'
set_setting "Jitsi_Domain" '"meet.jit.si"'
set_setting "Jitsi_URL_Room_Prefix" '"GameMasterTPS"'
set_setting "Jitsi_Open_New_Window" 'true'
set_setting "Jitsi_Enable_Channels" 'true'
set_setting "Jitsi_Enable_Teams" 'true'
set_setting "Jitsi_SSL" 'true'
set_setting "Jitsi_URL_Room_Hash" 'true'

echo "✅ Jitsi Meet configuré !"
echo ""
echo "📞 Les utilisateurs peuvent maintenant :"
echo "  - Cliquer sur l'icône 📞 dans n'importe quel channel"
echo "  - Lancer un appel vidéo/audio"
echo "  - Partager leur écran"
echo "  - Rejoindre depuis le navigateur (sans installation)"
