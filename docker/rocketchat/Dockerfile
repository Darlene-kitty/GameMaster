# ============================================
# DOCKERFILE - ROCKET.CHAT AVEC GAMEMASTER APP
# ============================================

# Étape 1 : Builder l'app GameMaster
FROM node:20-alpine AS app-builder

WORKDIR /app-builder

# Copier les fichiers de l'app
COPY rocketchat-app/package*.json ./
COPY rocketchat-app/tsconfig.json ./
COPY rocketchat-app/tslint.json ./
COPY rocketchat-app/GameMasterApp.ts ./

# Installer les dépendances et builder
RUN npm ci && npm run build || npx tsc GameMasterApp.ts --outDir dist --target ES2017 --module commonjs

# Étape 2 : Image finale Rocket.Chat
FROM rocket.chat:6.13.0

LABEL maintainer="TPS-ISI"
LABEL description="Rocket.Chat avec GameMaster App"

# Créer l'utilisateur non-root (exigence sécurité)
RUN addgroup -g 1001 -S rocketchat 2>/dev/null || true && \
    adduser -S -u 1001 -G rocketchat rocketchat 2>/dev/null || true

# Créer les dossiers avec les bons droits
RUN mkdir -p /app/uploads /app/apps/gamemaster \
    && chown -R rocketchat:rocketchat /app

# Copier l'app buildée depuis l'étape 1
COPY --from=app-builder --chown=rocketchat:rocketchat /app-builder/dist /app/apps/gamemaster/
COPY --from=app-builder --chown=rocketchat:rocketchat /app-builder/app.json /app/apps/gamemaster/
COPY --from=app-builder --chown=rocketchat:rocketchat /app-builder/package.json /app/apps/gamemaster/
COPY --from=app-builder --chown=rocketchat:rocketchat /app-builder/icon.png /app/apps/gamemaster/ 2>/dev/null || true
COPY --from=app-builder --chown=rocketchat:rocketchat /app-builder/.rcappsconfig /app/apps/gamemaster/ 2>/dev/null || true

# Variables d'environnement
ENV ROOT_URL=http://localhost:3000 \
    MONGO_URL=mongodb://localhost:27017/rocketchat \
    PORT=3000 \
    NODE_ENV=production

# Healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD node -e "const http = require('http'); http.get('http://localhost:3000/api/info', (r) => { process.exit(r.statusCode === 200 ? 0 : 1); }).on('error', () => process.exit(1));"

# Utilisateur non-root
USER rocketchat

EXPOSE 3000

CMD ["node", "main.js"]