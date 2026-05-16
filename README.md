# 🎮 GameMaster - Rocket.Chat TPS

Plateforme Rocket.Chat avec bot RPG, monitoring, et déploiement AWS.

## 🚀 Démarrage Rapide

### 1️⃣ Configuration Initiale

```bash
# Copier le fichier d'environnement
cp .env.example .env

# ⚠️ IMPORTANT : Éditer .env et changer TOUS les mots de passe
nano .env
```

**Variables critiques à modifier :**
- `MONGO_ROOT_PASS` - Mot de passe MongoDB
- `ADMIN_PASS` - Mot de passe admin Rocket.Chat
- `GRAFANA_PASS` - Mot de passe Grafana
- `ROOT_URL` - Votre domaine (ex: https://chat.example.com)
- Credentials AWS (si backup S3 activé)

### 2️⃣ Générer les Certificats SSL

```bash
# Pour développement local (auto-signé)
bash scripts/generate-ssl.sh

# Pour production (Let's Encrypt)
# Les certificats seront générés automatiquement par Certbot
```

### 3️⃣ Lancer l'Application

**Développement :**
```bash
docker compose up -d
```

**Production :**
```bash
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

### 4️⃣ Accès aux Services

| Service | URL | Credentials |
|---------|-----|-------------|
| **Rocket.Chat** | http://localhost:8080 | Voir `.env` (ADMIN_USERNAME/ADMIN_PASS) |
| **Grafana** | http://localhost:3001 | Voir `.env` (GRAFANA_USER/GRAFANA_PASS) |
| **Dozzle (Logs)** | http://localhost:9999 | Aucun |

## 🎲 Commandes du Bot GameMaster

Une fois connecté à Rocket.Chat :

```
/gm help                          # Afficher l'aide
/gm roll 2d20+4                   # Lancer des dés
/gm poll Question ? | Oui | Non   # Créer un sondage
/gm remind 10m Pause !            # Rappel (affichage uniquement)
/gm mod warn @user Raison         # Modération (warn/kick/ban)
```

## 📺 Canaux Créés Automatiquement

Le système crée automatiquement les canaux suivants :

- **#general** - Discussion générale
- **#annonces** - Annonces importantes
- **#combat** - Scènes de combat
- **#lancer-des** - Lancers de dés et tests
- **#roleplay** - Roleplay et interactions
- **#hors-jeu** - Discussions hors-jeu
- **#aide** - Questions et support

## 🎭 Rôles Disponibles

- **MJ** - Maître du Jeu (jaune doré)
- **Guerrier** - Classe Guerrier (rouge)
- **Archer** - Classe Archer (bleu)
- **Mage** - Classe Mage
- **Clerc** - Classe Clerc
- **Voleur** - Classe Voleur
- **Joueur** - Joueur standard (gris)

## 📦 Architecture

```
┌─────────────────────────────────────────┐
│           NGINX + ModSecurity WAF       │
│         (Load Balancer + HTTPS)         │
└──────────────┬──────────────────────────┘
               │
       ┌───────┴────────┐
       │                │
┌──────▼──────┐  ┌──────▼──────┐
│ RocketChat-1│  │ RocketChat-2│
└──────┬──────┘  └──────┬──────┘
       │                │
       └───────┬────────┘
               │
        ┌──────▼──────┐
        │   MongoDB   │
        └─────────────┘
```

**Services additionnels :**
- **Prometheus** : Collecte des métriques
- **Grafana** : Dashboards de monitoring
- **cAdvisor** : Métriques containers
- **Dozzle** : Logs en temps réel
- **Certbot** : Renouvellement SSL automatique
- **S3 Backup** : Sauvegarde quotidienne à 3h du matin

## 🔒 Sécurité

✅ **Implémenté :**
- WAF ModSecurity (OWASP CRS)
- Headers de sécurité (HSTS, X-Frame-Options, etc.)
- HTTPS forcé (redirect HTTP → HTTPS)
- Healthchecks sur tous les services
- Secrets dans `.env` (exclu de Git)
- Backups chiffrés S3

⚠️ **À faire avant production :**
1. Changer TOUS les mots de passe dans `.env`
2. Configurer un vrai domaine dans `ROOT_URL`
3. Obtenir des certificats Let's Encrypt valides
4. Configurer les credentials AWS pour les backups
5. Restreindre les ports exposés (fermer 9999, 3001 si non nécessaire)

## 🛠️ Maintenance

### Lancer les tests
```bash
# Tests unitaires
pytest tests/ -v

# Tests avec couverture
pytest tests/ --cov=app --cov-report=html

# Linting
flake8 app.py
black --check app.py
```

### Voir les logs
```bash
# Tous les services
docker compose logs -f

# Service spécifique
docker compose logs -f rocketchat-1

# Ou via l'interface web Dozzle : http://localhost:9999
```

### Backup manuel
```bash
docker compose exec s3-backup bash /backup.sh
```

### Restaurer un backup
```bash
# Télécharger depuis S3
aws s3 cp s3://VOTRE_BUCKET/rocketchat/daily/rocketchat_backup_YYYYMMDD_HHMMSS.archive.gz ./backup.archive.gz

# Restaurer
docker compose exec mongo mongorestore \
  --uri="mongodb://admin:VOTRE_PASS@localhost:27017/rocketchat?authSource=admin" \
  --archive=/backup.archive.gz \
  --gzip
```

### Mettre à jour
```bash
docker compose pull
docker compose up -d
```

## 📊 Monitoring

**Grafana** (http://localhost:3001) :
1. Ajouter Prometheus comme source de données : `http://prometheus:9090`
2. Importer des dashboards :
   - Docker Monitoring : ID `893`
   - Node Exporter : ID `1860`

## 🐛 Dépannage

### Rocket.Chat ne démarre pas
```bash
# Vérifier les logs
docker compose logs rocketchat-1

# Vérifier que MongoDB est healthy
docker compose ps
```

### Certificats SSL invalides
```bash
# Régénérer les certificats locaux
bash scripts/generate-ssl.sh

# Redémarrer nginx
docker compose restart nginx
```

### Bot GameMaster absent
```bash
# Redéployer le bot
docker compose restart rpg-setup
docker compose logs rpg-setup
```

## 📚 Documentation

- [Rocket.Chat Docs](https://docs.rocket.chat)
- [Docker Compose](https://docs.docker.com/compose/)
- [ModSecurity](https://github.com/SpiderLabs/ModSecurity)
- [AWS Setup](./docs/AWS_SETUP.md)

## 📝 Licence

Projet TPS - Cloud, Virtualisation & Datacenter

---

**⚠️ RAPPEL SÉCURITÉ :** Ne JAMAIS commiter le fichier `.env` dans Git !
