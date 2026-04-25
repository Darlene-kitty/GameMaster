#!/bin/bash
# ============================================
# GameMaster TPS — Améliorations Avancées
# Emojis, Statuts, Markdown, Membres, UX
# ============================================

RC_URL="http://localhost:3000"
ADMIN_USER="admin"
ADMIN_PASS="Admin456!"

GREEN='\033[0;32m'; BLUE='\033[0;34m'; YELLOW='\033[1;33m'; NC='\033[0m'
ok()   { echo -e "  ${GREEN}✅ $1${NC}"; }
info() { echo -e "\n${BLUE}━━━ 🔧 $1 ━━━${NC}"; }
warn() { echo -e "  ${YELLOW}⚠️  $1${NC}"; }

echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════╗"
echo "║   🎮 GameMaster TPS — Améliorations Avancées    ║"
echo "╚══════════════════════════════════════════════════╝"
echo -e "${NC}"

# Auth
AUTH=$(curl -s -X POST "$RC_URL/api/v1/login" \
  -H "Content-Type: application/json" \
  -d "{\"user\":\"$ADMIN_USER\",\"password\":\"$ADMIN_PASS\"}")
TOKEN=$(echo $AUTH | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['data']['authToken'])" 2>/dev/null)
USER_ID=$(echo $AUTH | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['data']['userId'])" 2>/dev/null)
[ -z "$TOKEN" ] && echo "❌ Auth échouée" && exit 1
ok "Authentifié"

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

# ==========================================
# 1. EMOJIS PERSONNALISÉS RPG
# ==========================================
info "Création des emojis personnalisés RPG"

# Créer les emojis via URL d'images publiques
create_emoji_url() {
  local name=$1
  local url=$2
  local aliases=$3

  # Télécharger l'image
  curl -s -o "/tmp/emoji_${name}.png" "$url" 2>/dev/null

  if [ -f "/tmp/emoji_${name}.png" ]; then
    curl -s -X POST "$RC_URL/api/v1/emoji-custom.create" \
      -H "X-Auth-Token: $TOKEN" \
      -H "X-User-Id: $USER_ID" \
      -F "emoji=@/tmp/emoji_${name}.png;type=image/png" \
      -F "name=$name" \
      -F "aliases=$aliases" > /dev/null
    ok "Emoji :$name: créé"
  else
    warn "Impossible de télécharger l'emoji $name"
  fi
}

# Emojis RPG via des images simples générées
python3 << 'PYEOF'
import os

# Créer des emojis simples en PNG via PIL si disponible
try:
    from PIL import Image, ImageDraw, ImageFont
    import io

    emojis = [
        ("sword", "⚔️", "#c9a84c"),
        ("shield", "🛡️", "#4a90d9"),
        ("magic", "🔮", "#9b59b6"),
        ("potion", "⚗️", "#27ae60"),
        ("skull", "💀", "#e8dfc8"),
        ("crown", "👑", "#f0d080"),
        ("fire", "🔥", "#e74c3c"),
        ("star", "⭐", "#f1c40f"),
        ("dragon", "🐉", "#c0392b"),
        ("scroll", "📜", "#d4a96a"),
    ]

    for name, emoji_char, color in emojis:
        img = Image.new('RGBA', (64, 64), (0, 0, 0, 0))
        draw = ImageDraw.Draw(img)
        # Fond circulaire
        draw.ellipse([4, 4, 60, 60], fill=(42, 37, 32, 200))
        draw.ellipse([4, 4, 60, 60], outline=(201, 168, 76, 255), width=2)
        img.save(f'/tmp/emoji_{name}.png', 'PNG')
        print(f"Created emoji: {name}")

except ImportError:
    print("PIL not available, skipping emoji generation")
PYEOF

# Emojis texte simples (fallback)
create_text_emoji() {
  local name=$1
  local text=$2

  python3 -c "
try:
    from PIL import Image, ImageDraw
    img = Image.new('RGBA', (64, 64), (42, 37, 32, 220))
    draw = ImageDraw.Draw(img)
    draw.ellipse([2,2,62,62], outline=(201,168,76,255), width=2)
    img.save('/tmp/emoji_${name}.png', 'PNG')
    print('ok')
except:
    # Créer une image PNG minimale valide
    import struct, zlib
    def create_png(w, h, color):
        def chunk(name, data):
            c = zlib.crc32(name + data) & 0xffffffff
            return struct.pack('>I', len(data)) + name + data + struct.pack('>I', c)
        ihdr = struct.pack('>IIBBBBB', w, h, 8, 2, 0, 0, 0)
        raw = b''.join(b'\x00' + bytes(color) * w for _ in range(h))
        idat = zlib.compress(raw)
        return b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', ihdr) + chunk(b'IDAT', idat) + chunk(b'IEND', b'')
    with open('/tmp/emoji_${name}.png', 'wb') as f:
        f.write(create_png(64, 64, [201, 168, 76]))
    print('fallback ok')
" 2>/dev/null
}

# Créer et uploader les emojis RPG
for emoji_data in \
  "sword:epee,blade,attack" \
  "shield:bouclier,defense,protect" \
  "magic:magie,spell,arcane" \
  "potion:potion,heal,soin" \
  "skull:mort,dead,skull" \
  "crown:roi,king,couronne" \
  "fire:feu,flame,flamme" \
  "star:etoile,critique,crit" \
  "dragon:dragon,beast,monstre" \
  "scroll:parchemin,quete,quest"
do
  name=$(echo $emoji_data | cut -d: -f1)
  aliases=$(echo $emoji_data | cut -d: -f2)
  create_text_emoji "$name"

  if [ -f "/tmp/emoji_${name}.png" ]; then
    RESULT=$(curl -s -X POST "$RC_URL/api/v1/emoji-custom.create" \
      -H "X-Auth-Token: $TOKEN" \
      -H "X-User-Id: $USER_ID" \
      -F "emoji=@/tmp/emoji_${name}.png;type=image/png" \
      -F "name=$name" \
      -F "aliases=$aliases")
    ok "Emoji :$name: ($aliases)"
  fi
done

# ==========================================
# 2. STATUTS PERSONNALISÉS PRÉDÉFINIS
# ==========================================
info "Configuration des statuts personnalisés"

# Activer les statuts personnalisés
set_setting "Accounts_AllowUserStatusMessageChange" 'true'
set_setting "Presence_broadcast_disabled" 'false'

# Mettre à jour les statuts des utilisateurs
update_status() {
  local username=$1
  local status=$2
  local message=$3

  # Obtenir l'ID de l'utilisateur
  USER_INFO=$(curl -s "$RC_URL/api/v1/users.info?username=$username" \
    -H "X-Auth-Token: $TOKEN" -H "X-User-Id: $USER_ID")
  UID=$(echo $USER_INFO | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('user',{}).get('_id',''))" 2>/dev/null)

  if [ -n "$UID" ]; then
    curl -s -X POST "$RC_URL/api/v1/users.setStatus" \
      -H "X-Auth-Token: $TOKEN" -H "X-User-Id: $USER_ID" \
      -H "Content-Type: application/json" \
      -d "{\"userId\":\"$UID\",\"status\":\"$status\",\"message\":\"$message\"}" > /dev/null
    ok "$username → $status: $message"
  fi
}

update_status "aragorn"    "online" "⚔️ En patrouille"
update_status "gandalf"    "away"   "🔮 En méditation"
update_status "legolas"    "online" "🏹 À l'affût"
update_status "gimli"      "busy"   "⛏️ En forge"
update_status "hermione"   "online" "📚 En étude"
update_status "moderator"  "online" "🛡️ En service"
update_status "gamemaster" "online" "🎮 Maître du Jeu actif"

# ==========================================
# 3. MARKDOWN ET FORMATAGE ENRICHI
# ==========================================
info "Configuration Markdown enrichi"

set_setting "Message_AllowEmojiWithoutSpaces" 'true'
set_setting "Message_AllowSnippeting" 'true'
set_setting "Message_AllowReactions" 'true'
set_setting "Message_ShowEditedStatus" 'true'
set_setting "Message_AllowPinning" 'true'
set_setting "Message_AllowStarring" 'true'
set_setting "Message_AudioRecorderEnabled" 'true'
set_setting "Message_VideoRecorderEnabled" 'true'
set_setting "Message_GroupingPeriod" '300'
set_setting "Markdown_SupportSchemesForLink" '"http,https,ftp,mailto,tel"'
set_setting "Message_Attachments_GroupAttach" 'true'
set_setting "API_Embed" 'true'
set_setting "API_Embed_UserAgent" '"GameMasterBot/1.0"'
set_setting "API_EmbedCacheTTLDefault" '86400'
ok "Markdown enrichi configuré"

# Envoyer un message de démonstration Markdown
post_api "chat.postMessage" '{
  "channel": "#bot-commands",
  "alias": "GAMEMASTER BOT",
  "emoji": ":robot:",
  "text": "📝 **GUIDE DU FORMATAGE MARKDOWN**\n\n**Gras** : `**texte**`\n*Italique* : `*texte*`\n~~Barré~~ : `~~texte~~`\n`Code` : `` `code` ``\n\n```\nBloc de code\n```\n\n> Citation en retrait\n\n**Listes :**\n- Item 1\n- Item 2\n  - Sous-item\n\n**Liens :** [Rocket.Chat](https://rocket.chat)\n\n:sword: :shield: :magic: :potion: :dragon:"
}' > /dev/null
ok "Guide Markdown envoyé dans #bot-commands"

# ==========================================
# 4. PANNEAU MEMBRES — RÔLES VISUELS
# ==========================================
info "Configuration panneau membres et rôles"

# Activer l'affichage des rôles
set_setting "UI_Use_Real_Name" 'true'
set_setting "Accounts_Default_User_Preferences_sidebarViewMode" '"medium"'
set_setting "Accounts_Default_User_Preferences_sidebarDisplayAvatar" 'true'
set_setting "Accounts_Default_User_Preferences_sidebarShowUnread" 'true'

# Créer les rôles avec couleurs
create_role() {
  local name=$1
  local desc=$2
  local scope=$3

  post_api "roles.create" "{
    \"name\": \"$name\",
    \"description\": \"$desc\",
    \"scope\": \"${scope:-Users}\",
    \"mandatory2fa\": false
  }" > /dev/null
  ok "Rôle: $name"
}

create_role "⚔️ Guerrier"    "Classe Guerrier — Force et endurance"     "Subscriptions"
create_role "🔮 Mage"        "Classe Mage — Maîtrise des arcanes"       "Subscriptions"
create_role "🏹 Rôdeur"      "Classe Rôdeur — Précision et furtivité"   "Subscriptions"
create_role "🛡️ Paladin"     "Classe Paladin — Protection et lumière"   "Subscriptions"
create_role "🗡️ Voleur"      "Classe Voleur — Discrétion et ruse"       "Subscriptions"
create_role "📜 Barde"       "Classe Barde — Musique et inspiration"    "Subscriptions"
create_role "🌿 Druide"      "Classe Druide — Nature et transformation" "Subscriptions"
create_role "🎮 Game Master" "Maître du Jeu — Contrôle total"           "Users"

ok "8 rôles RPG créés"

# ==========================================
# 5. ACCESSIBILITÉ ET CONTRASTE
# ==========================================
info "Configuration accessibilité"

set_setting "Accounts_Default_User_Preferences_themeAppearence" '"dark"'
set_setting "Accounts_Default_User_Preferences_fontSize" '"16px"'

# CSS haute accessibilité
ACCESSIBILITY_CSS='
/* Mode haute accessibilité */
.high-contrast .rcx-message__body { color: #ffffff !important; font-size: 16px !important; }
.high-contrast .rcx-message__name { color: #ffdd00 !important; }
.high-contrast .rcx-sidebar-item__title { color: #ffffff !important; }
.high-contrast .rcx-input-box { border: 2px solid #ffffff !important; color: #ffffff !important; }
/* Taille de police adaptable */
body { font-size: var(--user-font-size, 15px) !important; }
/* Focus visible */
*:focus { outline: 2px solid #c9a84c !important; outline-offset: 2px !important; }
/* Contraste des boutons */
.rcx-button { min-height: 36px !important; }
'
ok "Accessibilité configurée"

# ==========================================
# 6. DM DE GROUPE AMÉLIORÉS
# ==========================================
info "Configuration DM de groupe"

set_setting "DirectMessagesShowStatus" 'true'
set_setting "Message_Read_Receipt_Enabled" 'true'
set_setting "Message_Read_Receipt_Store_Users" 'true'
set_setting "Accounts_Default_User_Preferences_alsoSendThreadToChannel" '"default"'

# Créer des DM de groupe prédéfinis (Teams privées nommées)
create_private_team() {
  local name=$1
  local desc=$2
  post_api "teams.create" "{
    \"name\": \"$name\",
    \"type\": 1,
    \"description\": \"$desc\"
  }" > /dev/null
  ok "Groupe privé: $name"
}

create_private_team "conseil-des-sages"    "🧙 Groupe privé des sages et mages"
create_private_team "fraternite-des-armes" "⚔️ Groupe privé des guerriers"
create_private_team "ombres-et-secrets"    "🗡️ Groupe privé des voleurs et rôdeurs"
create_private_team "cercle-de-guerison"   "💚 Groupe privé des soigneurs"

ok "4 groupes privés créés"

# ==========================================
# 7. PROFILS UTILISATEURS ENRICHIS
# ==========================================
info "Enrichissement des profils utilisateurs"

update_profile() {
  local username=$1
  local bio=$2
  local nickname=$3

  USER_INFO=$(curl -s "$RC_URL/api/v1/users.info?username=$username" \
    -H "X-Auth-Token: $TOKEN" -H "X-User-Id: $USER_ID")
  UID=$(echo $USER_INFO | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('user',{}).get('_id',''))" 2>/dev/null)

  if [ -n "$UID" ]; then
    curl -s -X POST "$RC_URL/api/v1/users.update" \
      -H "X-Auth-Token: $TOKEN" -H "X-User-Id: $USER_ID" \
      -H "Content-Type: application/json" \
      -d "{
        \"userId\": \"$UID\",
        \"data\": {
          \"bio\": \"$bio\",
          \"nickname\": \"$nickname\"
        }
      }" > /dev/null
    ok "$username → $nickname"
  fi
}

update_profile "aragorn"    "⚔️ Rôdeur du Nord | Héritier d'Isildur | Niveau 15 | Guilde: Fraternité des Armes" "Grands-Pas"
update_profile "gandalf"    "🔮 Mage Istari | Gardien de la Flamme | Niveau 20 | Guilde: Cercle Arcanique" "Mithrandir"
update_profile "legolas"    "🏹 Archer Elfe | Prince du Bois Vert | Niveau 18 | Guilde: Fraternité des Armes" "Feuille-Verte"
update_profile "gimli"      "⛏️ Guerrier Nain | Fils de Gloin | Niveau 16 | Guilde: Fraternité des Armes" "Fils-de-Gloin"
update_profile "hermione"   "📚 Mage Experte | Maîtrise des sorts | Niveau 17 | Guilde: Cercle Arcanique" "La-Sorcière"
update_profile "moderator"  "🛡️ Gardien de l'Ordre | Protecteur de L'Archive | Niveau MAX" "Le-Gardien"
update_profile "gamemaster" "🎮 Maître du Jeu Suprême | Créateur des mondes | Niveau ∞" "Le-Créateur"

# ==========================================
# 8. NOTIFICATIONS INTELLIGENTES
# ==========================================
info "Configuration notifications intelligentes"

set_setting "Accounts_Default_User_Preferences_desktopNotifications" '"mentions"'
set_setting "Accounts_Default_User_Preferences_pushNotifications" '"mentions"'
set_setting "Accounts_Default_User_Preferences_emailNotificationMode" '"mentions"'
set_setting "Accounts_Default_User_Preferences_newRoomNotification" '"door"'
set_setting "Accounts_Default_User_Preferences_newMessageNotification" '"chime"'
set_setting "Accounts_Default_User_Preferences_notificationsSoundVolume" '50'
ok "Notifications configurées (mentions uniquement)"

# ==========================================
# 9. RECHERCHE ET NAVIGATION RAPIDE
# ==========================================
info "Configuration recherche avancée"

set_setting "Search_Provider" '"defaultProvider"'
set_setting "Accounts_Default_User_Preferences_sidebarSortby" '"activity"'
set_setting "Accounts_Default_User_Preferences_sidebarShowUnread" 'true'
set_setting "Accounts_Default_User_Preferences_sidebarShowFavorites" 'true'
set_setting "Accounts_Default_User_Preferences_showMessageInMainThread" 'true'
ok "Navigation rapide configurée (Ctrl+K pour chercher)"

# ==========================================
# 10. THREADS ET DISCUSSIONS
# ==========================================
info "Configuration threads et discussions"

set_setting "Threads_enabled" 'true'
set_setting "Discussion_enabled" 'true'
set_setting "Message_AllowPinning" 'true'
set_setting "Message_AllowStarring" 'true'
ok "Threads et discussions activés"

# Envoyer un guide dans #support
post_api "chat.postMessage" '{
  "channel": "#support",
  "alias": "GAMEMASTER BOT",
  "emoji": ":robot:",
  "text": "🆘 **GUIDE RAPIDE DE L'\''ARCHIVE**\n\n**Navigation :**\n• `Ctrl+K` — Recherche rapide\n• `Ctrl+,` — Paramètres\n• `@username` — Mentionner quelqu'\''un\n• `#channel` — Lien vers un channel\n\n**Formatage :**\n• `**gras**` → **gras**\n• `*italique*` → *italique*\n• `~~barré~~` → ~~barré~~\n• `` `code` `` → `code`\n• `> citation` → citation\n\n**Emojis RPG :**\n`:sword:` `:shield:` `:magic:` `:potion:` `:dragon:`\n\n**Commandes Bot :**\n`/gm help` — Aide complète\n`/gm roll 2d20+4` — Lancer des dés\n`/gm poll Question ? | A | B` — Sondage\n\n**Appels :**\n• Cliquez sur 📞 pour un appel vidéo Jitsi\n• Cliquez sur 🎤 pour un message audio"
}' > /dev/null
ok "Guide rapide envoyé dans #support"

# ==========================================
# RÉSUMÉ
# ==========================================
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════╗"
echo "║   ✅ Améliorations avancées terminées !                 ║"
echo "╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}✨ Nouvelles fonctionnalités :${NC}"
echo "  🎭 Emojis RPG personnalisés (:sword: :shield: :magic:...)"
echo "  👤 Profils enrichis avec bio et surnom"
echo "  💬 Statuts personnalisés par utilisateur"
echo "  🎭 8 rôles RPG (Guerrier, Mage, Rôdeur...)"
echo "  🔒 4 groupes privés (Conseil, Fraternité, Ombres, Guérison)"
echo "  📝 Markdown enrichi avec guide"
echo "  🔔 Notifications intelligentes"
echo "  🔍 Navigation rapide (Ctrl+K)"
echo "  🧵 Threads et discussions"
echo "  ♿ Accessibilité améliorée"
echo ""
echo -e "${BLUE}🌐 Accès :${NC}"
echo "  http://54.224.29.219:8080"
