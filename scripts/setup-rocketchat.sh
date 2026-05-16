
#!/bin/bash
# ============================================
# GameMaster TPS - Setup Ultra Complet
# Objectif: Dépasser Discord
# ============================================

RC_URL="http://localhost:3000"
ADMIN_USER="admin"
ADMIN_PASS="Admin456!"
SERVER_IP="54.224.29.219"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; BLUE='\033[0;34m'; PURPLE='\033[0;35m'; NC='\033[0m'
ok()    { echo -e "  ${GREEN}✅ $1${NC}"; }
info()  { echo -e "\n${BLUE}━━━ 🔧 $1 ━━━${NC}"; }
warn()  { echo -e "  ${YELLOW}⚠️  $1${NC}"; }
step()  { echo -e "${PURPLE}▶ $1${NC}"; }

echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════╗"
echo "║   🎮 GameMaster TPS — Configuration Ultime       ║"
echo "║   Objectif: Dépasser Discord                     ║"
echo "╚══════════════════════════════════════════════════╝"
echo -e "${NC}"

sleep 2

# ==========================================
# AUTH
# ==========================================
info "Authentification"
AUTH=$(curl -s -X POST "$RC_URL/api/v1/login" \
  -H "Content-Type: application/json" \
  -d "{\"user\":\"$ADMIN_USER\",\"password\":\"$ADMIN_PASS\"}")
TOKEN=$(echo $AUTH | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['data']['authToken'])" 2>/dev/null)
USER_ID=$(echo $AUTH | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['data']['userId'])" 2>/dev/null)
[ -z "$TOKEN" ] && echo -e "${RED}❌ Auth échouée${NC}" && exit 1
ok "Connecté en tant qu'admin"

# Helpers
set_setting() {
  curl -s -X POST "$RC_URL/api/v1/settings/$1" \
    -H "X-Auth-Token: $TOKEN" -H "X-User-Id: $USER_ID" \
    -H "Content-Type: application/json" -d "{\"value\":$2}" > /dev/null
}

post_api() {
  curl -s -X POST "$RC_URL/api/v1/$1" \
    -H "X-Auth-Token: $TOKEN" -H "X-User-Id: $USER_ID" \
    -H "Content-Type: application/json" -d "$2"
}

send_msg() {
  post_api "chat.postMessage" "{\"channel\":\"#$1\",\"text\":\"$2\",\"alias\":\"GAMEMASTER BOT\",\"emoji\":\":robot:\"}" > /dev/null
}

# ==========================================
# 1. IDENTITÉ & BRANDING
# ==========================================
info "Identité & Branding"
set_setting "Site_Name" '"🎮 GameMaster — L'\''Archive"'
set_setting "Site_Url" "\"http://$SERVER_IP:8080\""
set_setting "Server_Type" '"privateTeam"'
set_setting "Layout_Sidenav_Footer" '"<div style=\"text-align:center;padding:10px 8px;font-family:Cinzel,serif;background:linear-gradient(90deg,transparent,rgba(201,168,76,0.1),transparent);border-top:1px solid rgba(201,168,76,0.2);\"><span style=\"color:#c9a84c;font-size:10px;letter-spacing:3px;\">⚔️ GAMEMASTER TPS ⚔️</span><br><span style=\"color:rgba(232,223,200,0.4);font-size:9px;\">Powered by Rocket.Chat</span></div>"'
set_setting "Layout_Login_Terms" '"Bienvenue dans L'\''Archive — Serveur GameMaster RPG. Connectez-vous pour rejoindre l'\''aventure."'
ok "Branding configuré"

# ==========================================
# 2. THÈME VISUEL ULTRA COMPLET
# ==========================================
info "Thème visuel ultra complet"

set_setting "theme-color-rc-color-primary-action" '"#c9a84c"'
set_setting "theme-color-rc-color-button-primary" '"#c9a84c"'
set_setting "theme-color-rc-color-button-primary-hover" '"#f0d080"'
set_setting "theme-color-rc-color-link" '"#c9a84c"'
set_setting "theme-color-rc-color-success" '"#27ae60"'
set_setting "theme-color-rc-color-danger" '"#c0392b"'
set_setting "theme-color-rc-color-warning" '"#e67e22"'
set_setting "theme-color-rc-color-info" '"#2980b9"'

CSS='@import url(\"https://fonts.googleapis.com/css2?family=Cinzel:wght@400;700;900\&family=Crimson+Text:ital,wght@0,400;0,600;1,400\&family=JetBrains+Mono:wght@400;600\&display=swap\");
:root{--gold:#c9a84c;--gold-light:#f0d080;--parchment:#e8dfc8;--ink:#1a1510;--stone:#2a2520;--stone-light:#3a342e;}
body{background:#1a1510!important;}
.rcx-sidebar--main{background:linear-gradient(180deg,#1a1510 0%,#2a2520 60%,#1a1510 100%)!important;border-right:1px solid rgba(201,168,76,0.2)!important;}
.rcx-sidebar-item__title,.rcx-sidebar-item__subtitle{font-family:\"Crimson Text\",serif!important;}
.rcx-sidebar-item__title{color:#e8dfc8!important;font-size:15px!important;}
.rcx-sidebar-item__subtitle{color:rgba(232,223,200,0.5)!important;}
.rcx-sidebar-item--selected,.rcx-sidebar-item:hover{background:rgba(201,168,76,0.12)!important;border-left:3px solid #c9a84c!important;}
.rcx-sidebar-item--selected .rcx-sidebar-item__title{color:#f0d080!important;}
.rcx-room-header{background:linear-gradient(90deg,#1a1510,#2a2520,#1a1510)!important;border-bottom:1px solid rgba(201,168,76,0.3)!important;padding:12px 16px!important;}
.rcx-room-header__name{font-family:\"Cinzel\",serif!important;color:#f0d080!important;letter-spacing:2px!important;font-size:16px!important;}
.rcx-room-header__topic{color:rgba(232,223,200,0.6)!important;font-family:\"Crimson Text\",serif!important;font-style:italic!important;}
.rcx-message{border-left:2px solid transparent!important;transition:all 0.2s!important;padding:8px 16px!important;}
.rcx-message:hover{border-left-color:#c9a84c!important;background:rgba(201,168,76,0.04)!important;}
.rcx-message__name{color:#c9a84c!important;font-weight:700!important;font-family:\"Cinzel\",serif!important;font-size:13px!important;letter-spacing:1px!important;}
.rcx-message__time{color:rgba(232,223,200,0.3)!important;font-family:\"JetBrains Mono\",monospace!important;font-size:10px!important;}
.rcx-message__body{color:#e8dfc8!important;font-family:\"Crimson Text\",serif!important;font-size:15px!important;line-height:1.6!important;}
.rcx-input-box{background:rgba(26,21,16,0.9)!important;border:1px solid rgba(201,168,76,0.3)!important;color:#e8dfc8!important;font-family:\"Crimson Text\",serif!important;font-size:15px!important;border-radius:4px!important;}
.rcx-input-box:focus{border-color:#c9a84c!important;box-shadow:0 0 0 2px rgba(201,168,76,0.15)!important;}
.rcx-input-box::placeholder{color:rgba(232,223,200,0.3)!important;font-style:italic!important;}
.rcx-button--primary{background:linear-gradient(135deg,#c9a84c,#f0d080)!important;color:#1a1510!important;font-weight:700!important;font-family:\"Cinzel\",serif!important;letter-spacing:1px!important;border:none!important;}
.rcx-button--primary:hover{background:linear-gradient(135deg,#f0d080,#c9a84c)!important;transform:translateY(-1px)!important;box-shadow:0 4px 12px rgba(201,168,76,0.3)!important;}
.rcx-tag{background:rgba(201,168,76,0.15)!important;color:#f0d080!important;border:1px solid rgba(201,168,76,0.3)!important;font-family:\"JetBrains Mono\",monospace!important;font-size:11px!important;}
.rcx-message__block{background:rgba(0,0,0,0.4)!important;border-left:3px solid #c9a84c!important;border-radius:0 4px 4px 0!important;}
.rcx-attachment__title{color:#c9a84c!important;font-family:\"Cinzel\",serif!important;}
.rcx-attachment__text{color:#e8dfc8!important;font-family:\"Crimson Text\",serif!important;}
.rcx-badge{background:#c9a84c!important;color:#1a1510!important;font-weight:700!important;}
.rcx-sidebar-section__title{font-family:\"Cinzel\",serif!important;color:rgba(201,168,76,0.7)!important;font-size:11px!important;letter-spacing:3px!important;text-transform:uppercase!important;}
code,pre{background:rgba(0,0,0,0.5)!important;color:#c9a84c!important;border:1px solid rgba(201,168,76,0.2)!important;font-family:\"JetBrains Mono\",monospace!important;}
.rcx-modal{background:#2a2520!important;border:1px solid rgba(201,168,76,0.3)!important;}
.rcx-modal__title{font-family:\"Cinzel\",serif!important;color:#f0d080!important;}
::-webkit-scrollbar{width:5px;height:5px;}
::-webkit-scrollbar-track{background:#1a1510;}
::-webkit-scrollbar-thumb{background:linear-gradient(180deg,#c9a84c,#8b6914);border-radius:3px;}
::-webkit-scrollbar-thumb:hover{background:#f0d080;}
.rcx-message-toolbar{background:rgba(26,21,16,0.95)!important;border:1px solid rgba(201,168,76,0.2)!important;border-radius:4px!important;}
.rcx-option__title{color:#e8dfc8!important;font-family:\"Crimson Text\",serif!important;}
.rcx-option:hover{background:rgba(201,168,76,0.1)!important;}
.rcx-avatar{border:2px solid rgba(201,168,76,0.3)!important;}
.rcx-avatar:hover{border-color:#c9a84c!important;}'

set_setting "theme-custom-css" "\"$CSS\""
ok "Thème ultra complet appliqué"

# ==========================================
# 3. PARAMÈTRES AVANCÉS
# ==========================================
info "Paramètres avancés"

# Messages
set_setting "Message_AllowEmojiWithoutSpaces" 'true'
set_setting "Message_AllowSnippeting" 'true'
set_setting "Message_AllowReactions" 'true'
set_setting "Message_MaxAllowedSize" '10000'
set_setting "Message_ShowEditedStatus" 'true'
set_setting "Message_AllowPinning" 'true'
set_setting "Message_AllowStarring" 'true'
set_setting "Message_GroupingPeriod" '300'
set_setting "Message_TimeFormat" '"HH:mm"'
set_setting "Message_DateFormat" '"DD/MM/YYYY"'
ok "Paramètres messages configurés"

# Fichiers
set_setting "FileUpload_Enabled" 'true'
set_setting "FileUpload_MaxFileSize" '104857600'
set_setting "FileUpload_MediaTypeWhiteList" '"image/*,audio/*,video/*,application/pdf,text/*"'
ok "Upload fichiers: 100MB max"

# Notifications
set_setting "Accounts_Default_User_Preferences_desktopNotifications" '"default"'
set_setting "Accounts_Default_User_Preferences_pushNotifications" '"default"'
set_setting "Accounts_Default_User_Preferences_emailNotificationMode" '"mentions"'
set_setting "Accounts_Default_User_Preferences_highlights" '"[]"'
ok "Notifications configurées"

# Sécurité
set_setting "Accounts_RegistrationForm" '"Disabled"'
set_setting "Accounts_ManuallyApproveNewUsers" 'false'
set_setting "Accounts_TwoFactorAuthentication_Enabled" 'true'
set_setting "Accounts_LoginExpiration" '90'
set_setting "Accounts_Password_Policy_Enabled" 'true'
set_setting "Accounts_Password_Policy_MinLength" '8'
ok "Sécurité renforcée"

# UX
set_setting "UI_Use_Real_Name" 'true'
set_setting "UI_Allow_Room_Names_With_Special_Chars" 'true'
set_setting "Accounts_Default_User_Preferences_sidebarViewMode" '"medium"'
set_setting "Accounts_Default_User_Preferences_sidebarDisplayAvatar" 'true'
set_setting "Accounts_Default_User_Preferences_sidebarShowUnread" 'true'
set_setting "Accounts_Default_User_Preferences_sidebarSortby" '"activity"'
set_setting "Accounts_Default_User_Preferences_useEmojis" 'true'
set_setting "Accounts_Default_User_Preferences_convertAsciiEmoji" 'true'
ok "UX optimisée"

# Apps
set_setting "Apps_Framework_Development_Mode" 'true'
set_setting "Apps_Framework_enabled" 'true'
ok "Framework Apps activé"

# ==========================================
# 4. CHANNELS COMPLETS
# ==========================================
info "Création des channels"

create_channel() {
  local name=$1 desc=$2 topic=$3 readonly=${4:-false} type=${5:-"c"}
  RESULT=$(post_api "channels.create" "{\"name\":\"$name\",\"readOnly\":$readonly,\"type\":\"$type\"}")
  ROOM_ID=$(echo $RESULT | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('channel',{}).get('_id',''))" 2>/dev/null)
  if [ -n "$ROOM_ID" ]; then
    post_api "channels.setDescription" "{\"roomId\":\"$ROOM_ID\",\"description\":\"$desc\"}" > /dev/null
    post_api "channels.setTopic" "{\"roomId\":\"$ROOM_ID\",\"topic\":\"$topic\"}" > /dev/null
    ok "#$name"
  else
    warn "#$name existe déjà"
  fi
  echo $ROOM_ID
}

# Catégorie: INFORMATION
create_channel "annonces"       "📢 Annonces officielles" "Annonces importantes du serveur GameMaster" "true"
create_channel "regles"         "📋 Règles du serveur" "Lisez les règles avant de participer" "true"
create_channel "changelog"      "📝 Mises à jour" "Historique des changements et nouveautés" "true"
create_channel "bienvenue"      "👋 Présentations" "Présentez-vous à la communauté !" "false"

# Catégorie: JEU DE RÔLE
create_channel "combat"         "⚔️ Combat & Batailles" "Scènes de combat épiques. /gm roll 1d20+5" "false"
create_channel "lancer-des"     "🎲 Lancers de dés" "Testez vos compétences. /gm roll 2d6+3" "false"
create_channel "roleplay"       "🎭 Roleplay & Narration" "Incarnez votre personnage" "false"
create_channel "quetes"         "📜 Quêtes & Missions" "Consultez et formez vos groupes" "false"
create_channel "lore"           "📚 Lore & Histoire" "Explorez la mythologie du monde" "false"
create_channel "personnages"    "🧙 Fiches Personnages" "Partagez vos fiches de personnage" "false"
create_channel "carte-du-monde" "🗺️ Carte du Monde" "Explorez les territoires connus" "false"

# Catégorie: COMMUNAUTÉ
create_channel "taverne"        "🍺 La Taverne" "Discussion libre entre aventuriers" "false"
create_channel "off-topic"      "💬 Hors-Sujet" "Discussions générales" "false"
create_channel "media"          "🎨 Médias & Art" "Partagez vos créations artistiques" "false"
create_channel "musique"        "🎵 Musique & Ambiance" "Partagez vos playlists RPG" "false"
create_channel "humour"         "😄 Humour & Mèmes" "Détendez-vous avec humour" "false"

# Catégorie: TECHNIQUE
create_channel "bot-commands"   "🤖 Commandes Bot" "Testez les commandes GameMaster" "false"
create_channel "support"        "🆘 Support & Aide" "Besoin d'aide ? Posez vos questions" "false"
create_channel "suggestions"    "💡 Suggestions" "Proposez des améliorations" "false"

ok "18 channels créés"

# ==========================================
# 5. MESSAGES DE BIENVENUE RICHES
# ==========================================
info "Messages de bienvenue"

send_msg "annonces" "🏰 **BIENVENUE DANS L'ARCHIVE !**\n\n*L'Archive est un serveur de messagerie dédié aux aventures RPG, propulsé par GameMaster TPS.*\n\n📌 **Liens rapides :**\n• 📋 Règles → #regles\n• 👋 Présentations → #bienvenue\n• 🤖 Commandes bot → #bot-commands\n• 🆘 Support → #support\n\n*Que l'aventure commence !* ⚔️🎲"

send_msg "regles" "📋 **RÈGLES DE L'ARCHIVE**\n\n**1. Respect mutuel**\nTraitez tous les membres avec respect. Aucune discrimination, harcèlement ou insulte ne sera tolérée.\n\n**2. Restez dans le thème**\nChaque channel a un sujet précis. Respectez-le.\n\n**3. Pas de spam**\nÉvitez les messages répétitifs ou les mentions abusives.\n\n**4. Contenu approprié**\nPas de contenu NSFW, illégal ou offensant.\n\n**5. Utilisez le bot correctement**\nLes commandes \`/gm\` sont réservées aux channels appropriés.\n\n*Toute violation peut entraîner un avertissement, un kick ou un ban.*\n\n✅ En rejoignant ce serveur, vous acceptez ces règles."

send_msg "bienvenue" "👋 **PRÉSENTEZ-VOUS !**\n\nBienvenue dans L'Archive ! Présentez-vous en utilisant ce modèle :\n\n\`\`\`\n🧙 Nom/Pseudo    : \n⚔️ Classe RPG    : (Guerrier, Mage, Rôdeur...)\n🌍 Origine       : \n🎮 Jeux favoris  : \n📖 Style de jeu  : (Combat, Roleplay, Exploration)\n💬 Anecdote      : \n\`\`\`"

send_msg "combat" "⚔️ **BIENVENUE DANS L'ARÈNE !**\n\nIci se déroulent les combats épiques. Commandes disponibles :\n\n\`\`\`\n/gm roll 1d20+5   → Jet d'attaque\n/gm roll 2d6+3    → Dégâts\n/gm roll 1d20     → Jet de sauvegarde\n/gm roll 4d6      → Caractéristique\n\`\`\`\n\n*Que le meilleur guerrier gagne !* 🏆"

send_msg "taverne" "🍺 **BIENVENUE À LA TAVERNE DU DRAGON D'OR !**\n\nInstallez-vous, commandez une boisson et discutez librement.\n\n*Menu du jour :*\n🍺 Bière des Nains — 2 pièces d'or\n🍷 Vin Elfique — 5 pièces d'or\n🍖 Rôti de Sanglier — 3 pièces d'or\n☕ Thé des Sages — 1 pièce d'or\n\n*Bonne soirée, aventuriers !* 🐉"

send_msg "bot-commands" "🤖 **GRIMOIRE DES COMMANDES GAMEMASTER**\n\n**🎲 Dés :**\n\`/gm roll 2d20\` — Lancer 2d20\n\`/gm roll 1d20+5\` — Avec bonus\n\`/gm roll 4d6\` — Caractéristique\n\n**📊 Sondages :**\n\`/gm poll Question ? | Option A | Option B\`\n\n**⏰ Rappels :**\n\`/gm remind 10m Message\`\n\`/gm remind 1h Session ce soir !\`\n\n**🛡️ Modération :**\n\`/gm mod warn @user Raison\`\n\`/gm mod kick @user Raison\`\n\n**❓ Aide :**\n\`/gm help\`"

send_msg "quetes" "📜 **TABLEAU DES QUÊTES**\n\n**🔴 URGENTES :**\n• *La Forêt Maudite* — Niveau 5+ — Récompense: 500 PO\n• *Le Dragon de Fer* — Niveau 10+ — Récompense: 2000 PO\n\n**🟡 NORMALES :**\n• *Escorte du Marchand* — Niveau 2+ — Récompense: 100 PO\n• *Exploration des Ruines* — Niveau 3+ — Récompense: 200 PO\n\n**🟢 DÉBUTANTS :**\n• *Rats dans la Cave* — Niveau 1+ — Récompense: 25 PO\n• *Livraison de Potions* — Niveau 1+ — Récompense: 30 PO\n\n*Utilisez /gm poll pour former votre groupe !*"

send_msg "lore" "📚 **BIENVENUE DANS LES ARCHIVES DU MONDE**\n\n*Ici sont consignées les grandes vérités du monde...*\n\n🌍 **Le Monde :** Aethoria — Un continent vaste et mystérieux\n\n🏰 **Les Grandes Cités :**\n• *Valdris* — Capitale du Royaume de l'Est\n• *Sylvara* — Cité elfique dans les bois anciens\n• *Ironhold* — Forteresse naine dans les montagnes\n\n⚔️ **Les Factions :**\n• *L'Ordre du Soleil* — Paladins et guerriers de lumière\n• *La Guilde des Ombres* — Voleurs et assassins\n• *Le Cercle Arcanique* — Mages et sorciers\n\n*Explorez, découvrez, créez l'histoire !*"

ok "Messages de bienvenue envoyés"

# ==========================================
# 6. UTILISATEURS AVEC AVATARS ET BIOS
# ==========================================
info "Création des utilisateurs"

create_user() {
  local name=$1 username=$2 email=$3 pass=$4 role=$5 bio=$6
  RESULT=$(post_api "users.create" "{
    \"name\": \"$name\",
    \"email\": \"$email\",
    \"password\": \"$pass\",
    \"username\": \"$username\",
    \"roles\": [\"$role\"],
    \"verified\": true,
    \"joinDefaultChannels\": true,
    \"customFields\": {\"bio\": \"$bio\"}
  }")
  ok "$username ($pass) — $role"
}

create_user "Aragorn le Rôdeur"   "aragorn"    "aragorn@gamemaster.local"    "Aragorn123!"    "user"      "Rôdeur du Nord, héritier d'Isildur"
create_user "Gandalf le Gris"     "gandalf"    "gandalf@gamemaster.local"    "Gandalf123!"    "user"      "Mage de l'Ordre des Istari"
create_user "Legolas Vertefeuille" "legolas"   "legolas@gamemaster.local"    "Legolas123!"    "user"      "Archer elfe du Bois Vert"
create_user "Gimli fils de Gloin" "gimli"      "gimli@gamemaster.local"      "Gimli123!"      "user"      "Guerrier nain des Mines de la Moria"
create_user "Hermione Granger"    "hermione"   "hermione@gamemaster.local"   "Hermione123!"   "user"      "Mage experte en sorts et potions"
create_user "Modérateur"          "moderator"  "mod@gamemaster.local"        "Mod123!"        "moderator" "Gardien de l'ordre dans L'Archive"
create_user "Game Master"         "gamemaster" "gm@gamemaster.local"         "GameMaster123!" "admin"     "Maître du jeu et narrateur suprême"

ok "7 utilisateurs créés"

# ==========================================
# 7. HOME PAGE ULTRA
# ==========================================
info "Configuration Home Page"

HOME_HTML=$(cat /opt/rocket-chat-tps/rocketchat-app/home-page.html 2>/dev/null | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))" 2>/dev/null)
if [ -n "$HOME_HTML" ]; then
  curl -s -X POST "$RC_URL/api/v1/settings/Layout_Home_Body" \
    -H "X-Auth-Token: $TOKEN" -H "X-User-Id: $USER_ID" \
    -H "Content-Type: application/json" \
    -d "{\"value\":$HOME_HTML}" > /dev/null
  ok "Home Page configurée"
fi

# ==========================================
# 8. INTÉGRATIONS WEBHOOK
# ==========================================
info "Configuration des intégrations"

# Webhook entrant pour les alertes
WEBHOOK=$(post_api "integrations.create" '{
  "type": "webhook-incoming",
  "name": "GameMaster Alerts",
  "enabled": true,
  "username": "gamemaster",
  "channel": "#annonces",
  "scriptEnabled": false
}')
WEBHOOK_TOKEN=$(echo $WEBHOOK | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('integration',{}).get('token',''))" 2>/dev/null)
[ -n "$WEBHOOK_TOKEN" ] && ok "Webhook créé: /hooks/$WEBHOOK_TOKEN"

# ==========================================
# 9. PERMISSIONS ET RÔLES
# ==========================================
info "Configuration des rôles"

# Créer un rôle Game Master
post_api "roles.create" '{
  "name": "game-master",
  "description": "Maître du Jeu — Contrôle total sur les sessions RPG",
  "scope": "Subscriptions",
  "mandatory2fa": false
}' > /dev/null
ok "Rôle Game Master créé"

# ==========================================
# 10. CONFIGURATION EMAIL (si SMTP disponible)
# ==========================================
info "Configuration email"
set_setting "SMTP_Host" '"smtp.gmail.com"'
set_setting "SMTP_Port" '"587"'
set_setting "From_Email" '"gamemaster@localhost.local"'
set_setting "Email_Header" '"<div style=\"background:#1a1510;padding:20px;text-align:center;\"><h1 style=\"color:#c9a84c;font-family:serif;\">🎮 GameMaster TPS</h1></div>"'
set_setting "Email_Footer" '"<div style=\"background:#1a1510;padding:10px;text-align:center;color:#666;\">© 2026 GameMaster TPS — L'\''Archive</div>"'
ok "Template email configuré"

# ==========================================
# 11. CHANNELS PRIVÉS (ÉQUIPES)
# ==========================================
info "Création des équipes privées"

create_team() {
  local name=$1 desc=$2
  RESULT=$(post_api "teams.create" "{\"name\":\"$name\",\"type\":1,\"members\":[]}")
  ok "Équipe: $name"
}

create_team "ordre-du-soleil"   "⚔️ L'Ordre du Soleil — Paladins et guerriers"
create_team "guilde-des-ombres" "🗡️ La Guilde des Ombres — Voleurs et assassins"
create_team "cercle-arcanique"  "🔮 Le Cercle Arcanique — Mages et sorciers"

# ==========================================
# 12. MESSAGES ÉPINGLÉS IMPORTANTS
# ==========================================
info "Messages épinglés"

# Épingler le message de règles dans #regles
RULES_MSG=$(post_api "chat.postMessage" "{
  \"channel\": \"#regles\",
  \"text\": \"📌 **RÈGLES ÉPINGLÉES** — Lisez avant de participer !\",
  \"alias\": \"GAMEMASTER BOT\",
  \"emoji\": \":robot:\"
}")
MSG_ID=$(echo $RULES_MSG | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('message',{}).get('_id',''))" 2>/dev/null)
[ -n "$MSG_ID" ] && post_api "chat.pinMessage" "{\"messageId\":\"$MSG_ID\"}" > /dev/null && ok "Message épinglé dans #regles"

# ==========================================
# RÉSUMÉ FINAL
# ==========================================
echo ""
echo -e "${GREEN}"
echo "╔══════════════════════════════════════════════════════════╗"
echo "║   🎉 CONFIGURATION ULTRA COMPLÈTE TERMINÉE !            ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${BLUE}🌐 Accès :${NC}"
echo "  Rocket.Chat → http://$SERVER_IP:8080"
echo "  Grafana     → http://$SERVER_IP:3001"
echo "  Dozzle      → http://$SERVER_IP:9999"

echo -e "\n${BLUE}👤 Utilisateurs :${NC}"
echo "  admin       → Admin456!       (super admin)"
echo "  gamemaster  → GameMaster123!  (admin)"
echo "  moderator   → Mod123!         (modérateur)"
echo "  aragorn     → Aragorn123!     (user)"
echo "  gandalf     → Gandalf123!     (user)"
echo "  legolas     → Legolas123!     (user)"
echo "  gimli       → Gimli123!       (user)"
echo "  hermione    → Hermione123!    (user)"

echo -e "\n${BLUE}💬 Channels (18) :${NC}"
echo "  📢 annonces  📋 regles  📝 changelog  👋 bienvenue"
echo "  ⚔️ combat    🎲 lancer-des  🎭 roleplay  📜 quetes"
echo "  📚 lore      🧙 personnages  🗺️ carte-du-monde"
echo "  🍺 taverne   💬 off-topic  🎨 media  🎵 musique"
echo "  🤖 bot-commands  🆘 support  💡 suggestions"

echo -e "\n${BLUE}🏰 Équipes privées :${NC}"
echo "  ⚔️ ordre-du-soleil"
echo "  🗡️ guilde-des-ombres"
echo "  🔮 cercle-arcanique"

echo -e "\n${BLUE}🤖 Installer le bot GameMaster (sur Windows) :${NC}"
echo "  cd rocketchat-app"
echo "  npm install"
echo "  npx rc-apps deploy --url http://$SERVER_IP:8080 --username admin --password Admin456!"
echo ""

# ==========================================
# BONUS: JITSI VOICE/VIDEO
# ==========================================
info "Configuration Voice/Video (Jitsi Meet)"
set_setting "Jitsi_Enabled" 'true'
set_setting "Jitsi_Domain" '"meet.jit.si"'
set_setting "Jitsi_URL_Room_Prefix" '"GameMasterTPS"'
set_setting "Jitsi_Open_New_Window" 'true'
set_setting "Jitsi_Enable_Channels" 'true'
set_setting "Jitsi_Enable_Teams" 'true'
set_setting "Jitsi_SSL" 'true'
ok "Jitsi Meet activé (appels voix/vidéo)"

# ==========================================
# BONUS: MESSAGERIE DIRECTE
# ==========================================
info "Configuration messagerie directe"
set_setting "DirectMessagesShowStatus" 'true'
set_setting "Accounts_Default_User_Preferences_dontAskAgainList" '[]'
set_setting "Message_Read_Receipt_Enabled" 'true'
set_setting "Message_Read_Receipt_Store_Users" 'true'
ok "Accusés de lecture activés"

# ==========================================
# BONUS: MENU PERSONNALISÉ
# ==========================================
info "Configuration du menu"
set_setting "Accounts_Default_User_Preferences_sidebarViewMode" '"medium"'
set_setting "Accounts_Default_User_Preferences_sidebarDisplayAvatar" 'true'
set_setting "Accounts_Default_User_Preferences_sidebarShowUnread" 'true'
set_setting "Accounts_Default_User_Preferences_sidebarSortby" '"activity"'
set_setting "Accounts_Default_User_Preferences_showMessageInMainThread" 'true'
set_setting "Accounts_Default_User_Preferences_alsoSendThreadToChannel" '"default"'
ok "Menu sidebar configuré"

# ==========================================
# BONUS: ENVOI DE MESSAGES ENRICHIS
# ==========================================
info "Configuration messages enrichis"
set_setting "Message_AllowEmojiWithoutSpaces" 'true'
set_setting "Message_AllowSnippeting" 'true'
set_setting "Message_AllowReactions" 'true'
set_setting "Message_ShowEditedStatus" 'true'
set_setting "Message_AllowPinning" 'true'
set_setting "Message_AllowStarring" 'true'
set_setting "Message_AudioRecorderEnabled" 'true'
set_setting "Message_VideoRecorderEnabled" 'true'
set_setting "FileUpload_Enabled" 'true'
set_setting "FileUpload_MaxFileSize" '104857600'
ok "Messages audio/vidéo/fichiers activés"

# ==========================================
# BONUS: THREADS ET DISCUSSIONS
# ==========================================
info "Configuration threads"
set_setting "Threads_enabled" 'true'
set_setting "Discussion_enabled" 'true'
ok "Threads et discussions activés"

# ==========================================
# BONUS: CSS ULTRA COMPLET LOGIN + MESSAGERIE
# ==========================================
info "Application CSS ultra complet"

CSS_FILE="/opt/rocket-chat-tps/docker/rocketchat/custom.css"
if [ -f "$CSS_FILE" ]; then
  CSS_CONTENT=$(cat "$CSS_FILE" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))" 2>/dev/null)
  curl -s -X POST "$RC_URL/api/v1/settings/theme-custom-css" \
    -H "X-Auth-Token: $TOKEN" -H "X-User-Id: $USER_ID" \
    -H "Content-Type: application/json" \
    -d "{\"value\":$CSS_CONTENT}" > /dev/null
  ok "CSS ultra complet appliqué (login + messagerie)"
else
  warn "Fichier CSS non trouvé: $CSS_FILE"
fi
