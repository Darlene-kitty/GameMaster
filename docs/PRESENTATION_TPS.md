# 🎮 Rocket.Chat GameMaster - Soutenance TPS

## 📋 Informations
- **Candidat** : KOUANG
- **Date** : 12/04/2026
- **Thème TPS** : 7 - Service de messagerie interne (Rocket.Chat)

## 🏗 Architecture déployée

```
                        ┌─────────────────────────────────────────────┐
                        │              GITHUB ACTIONS CI/CD            │
                        │  push → build → push ECR → deploy EC2 SSH   │
                        └─────────────────┬───────────────────────────┘
                                          │
                        ┌─────────────────▼───────────────────────────┐
                        │              AWS ECR Registry                │
                        │         rocketchat-tps:latest                │
                        └─────────────────┬───────────────────────────┘
                                          │ docker pull
                        ┌─────────────────▼───────────────────────────┐
                        │                AWS EC2                       │
                        │                                              │
                        │   Internet                                   │
                        │      │                                       │
                        │   ┌──▼──────────────────────────────────┐   │
                        │   │  NGINX (Reverse Proxy + WAF)         │   │
                        │   │  :80 → redirect HTTPS                │   │
                        │   │  :443 → SSL/TLS (Let's Encrypt)      │   │
                        │   │  ModSecurity (WAF)                   │   │
                        │   └──┬──────────────────┬───────────────┘   │
                        │      │   ip_hash LB      │                   │
                        │   ┌──▼──────────┐  ┌────▼────────┐         │
                        │   │ rocketchat-1│  │ rocketchat-2│         │
                        │   │  :3000      │  │  :3000      │         │
                        │   │  UID 1001   │  │  UID 1001   │         │
                        │   └──┬──────────┘  └────┬────────┘         │
                        │      └────────┬──────────┘                  │
                        │           ┌───▼──────────┐                  │
                        │           │  MongoDB 6.0  │                  │
                        │           │  :27017       │                  │
                        │           │  Volume:      │                  │
                        │           │  mongo-data   │                  │
                        │           └───────────────┘                  │
                        │                                              │
                        │   ┌──────────────────────────────────────┐  │
                        │   │  s3-backup (cron 03:00 daily)        │  │
                        │   │  mongodump → gzip → AWS S3           │  │
                        │   └──────────────────────────────────────┘  │
                        └─────────────────────────────────────────────┘
                                          │
                        ┌─────────────────▼───────────────────────────┐
                        │              AWS S3 Bucket                   │
                        │     rocketchat/daily/backup_YYYYMMDD.gz     │
                        └─────────────────────────────────────────────┘

Réseau interne : bridge "internal" (app ↔ DB isolés)
Volumes        : mongo-data, uploads-1, uploads-2
```

## ✅ Checklist des exigences TPS

| Exigence | Statut | Preuve |
|----------|--------|--------|
| Docker + Docker Compose | ✅ | docker-compose.yml |
| Volumes persistants | ✅ | mongo-data, uploads-1, uploads-2 |
| Reverse proxy Nginx | ✅ | nginx.conf |
| HTTPS | ✅ | Let's Encrypt + certs auto-signés |
| CI/CD Pipeline | ✅ | .github/workflows/deploy.yml |
| Build → Push → Deploy | ✅ | GitHub Actions + ECR |
| Monitoring / Logs | ✅ | Dozzle :9999 + healthchecks |
| Variables d'environnement | ✅ | .env (gitignored) + GitHub Secrets |
| Conteneurs non-root | ✅ | UID 1001 |
| 2 instances applicatives | ✅ | rocketchat-1, rocketchat-2 |
| Load balancer | ✅ | Nginx upstream ip_hash |
| Séparation app/DB | ✅ | Services distincts réseau internal |
| Architecture documentée | ✅ | Schéma ASCII RESUME.md |
| Backup automatisé S3 | ✅ | backup.sh + cron 03:00 daily |
| WAF ModSecurity | ✅ | owasp/modsecurity-crs:nginx-alpine |

## 🎯 Démonstration

### 1. Démarrage
```bash
# Générer les certificats SSL locaux
bash scripts/generate-ssl.sh

# Démarrer la stack complète
docker compose up -d

# Vérifier l'état des containers
docker compose ps
```

### 2. Accès
- Rocket.Chat : https://localhost:8443
- Grafana : http://localhost:3001
- Dozzle (logs) : http://localhost:9999

### 3. Pipeline CI/CD
```bash
git add .
git commit -m "feat: nouvelle version"
git push origin main
# → GitHub Actions build → push ECR → deploy EC2 automatiquement
```

### 4. Commandes GameMaster Bot
```
/gm help
/gm roll 2d20+4
/gm poll Question ? | Option A | Option B
/gm remind 10m Réunion équipe
/gm mod warn @user Comportement inapproprié
```