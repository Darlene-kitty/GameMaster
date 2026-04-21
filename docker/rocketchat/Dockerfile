FROM rocketchat/rocket.chat:6.13.0

LABEL maintainer="TPS-ISI"
LABEL description="Rocket.Chat avec GameMaster App"

# Créer utilisateur non-root (image Debian-based, utiliser adduser/groupadd)
USER root
RUN groupadd -g 1001 rocketchat 2>/dev/null || true && \
    useradd -u 1001 -g rocketchat -s /bin/false -M rocketchat 2>/dev/null || true

# Créer dossiers
RUN mkdir -p /app/uploads /app/apps/gamemaster \
    && chown -R rocketchat:rocketchat /app

# Copier les fichiers de l'app
COPY --chown=rocketchat:rocketchat rocketchat-app/*.ts /app/apps/gamemaster/
COPY --chown=rocketchat:rocketchat rocketchat-app/*.json /app/apps/gamemaster/
COPY --chown=rocketchat:rocketchat rocketchat-app/icon.png /app/apps/gamemaster/

ENV ROOT_URL=http://localhost:3000 \
    MONGO_URL=mongodb://localhost:27017/rocketchat \
    PORT=3000

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3000/api/info', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)}).on('error', () => process.exit(1))"

USER rocketchat
EXPOSE 3000
# Pas de CMD override — on utilise l'entrypoint natif de l'image rocketchat/rocket.chat