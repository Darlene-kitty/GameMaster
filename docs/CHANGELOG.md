# Changelog

Toutes les modifications notables de ce projet seront documentées dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/),
et ce projet adhère au [Semantic Versioning](https://semver.org/lang/fr/).

## [Unreleased]

### À Venir
- Tests unitaires pour le bot GameMaster
- Tests d'intégration Docker
- Dashboards Grafana personnalisés
- Alertes Prometheus configurées
- Mode clair (light theme)

## [1.0.0] - 2026-04-25

### Ajouté
- 🎮 Bot GameMaster avec commandes RPG
  - `/gm roll` - Lancer de dés
  - `/gm poll` - Sondages
  - `/gm remind` - Rappels
  - `/gm mod` - Modération
  - `/gm help` - Aide
- 🎨 Thème Discord "Eldritch Forge"
  - Palette de couleurs sombre
  - Police Inter
  - Animations fluides
- 🎨 Thème amélioré `discord-theme-enhanced.css`
  - Scrollbar personnalisée
  - Indicateurs de statut
  - Messages bot stylisés
  - Responsive design
- 🐳 Architecture Docker complète
  - Load balancing (2 instances Rocket.Chat)
  - Reverse proxy Nginx
  - WAF ModSecurity
  - MongoDB avec replica set
- 🔒 Sécurité
  - HTTPS avec Let's Encrypt
  - Headers de sécurité
  - Containers non-root
  - Secrets management
- 📊 Monitoring
  - Prometheus pour les métriques
  - Grafana pour les dashboards
  - cAdvisor pour les containers
  - Dozzle pour les logs
- 💾 Backup automatisé
  - Sauvegarde quotidienne vers S3
  - Compression gzip
  - Rétention configurable
- 🔄 CI/CD
  - Pipeline GitHub Actions
  - Build automatique
  - Push vers AWS ECR
  - Déploiement SSH sur EC2
- 📚 Documentation complète
  - README principal
  - Guide AWS
  - Guide Git/GitHub
  - Checklist de sécurité
  - Guide de contribution
  - Documentation visuelle
  - Guide de migration thème

### Modifié
- ⚡ Flask app avec Gunicorn (production-ready)
- 🔧 Configuration Docker optimisée
- 📝 README rocketchat-app personnalisé

### Corrigé
- 🐛 Ports Dozzle/Grafana restreints à localhost
- 🔒 Suppression des mots de passe par défaut faibles
- 📦 .gitignore étendu (Python, Node, IDE)

### Sécurité
- 🔐 Suppression des credentials exposés
- 🛡️ WAF ModSecurity activé
- 🔒 Certificats SSL configurés

### Supprimé
- ❌ `docs/SECURITY_INCIDENT.md` (obsolète)
- ❌ `docs/VISUAL_TEST_CHECKLIST.md` (doublon)

## [0.1.0] - 2026-04-01

### Ajouté
- 🎯 Setup initial du projet
- 🐳 Configuration Docker de base
- 📝 Documentation initiale

---

## Types de Changements

- `Ajouté` pour les nouvelles fonctionnalités
- `Modifié` pour les changements dans les fonctionnalités existantes
- `Déprécié` pour les fonctionnalités qui seront bientôt supprimées
- `Supprimé` pour les fonctionnalités supprimées
- `Corrigé` pour les corrections de bugs
- `Sécurité` pour les vulnérabilités corrigées

## Emojis Utilisés

- 🎮 Bot/Gaming
- 🎨 Design/UI
- 🐳 Docker
- 🔒 Sécurité
- 📊 Monitoring
- 💾 Backup
- 🔄 CI/CD
- 📚 Documentation
- ⚡ Performance
- 🔧 Configuration
- 🐛 Bug fix
- ❌ Suppression
- ✨ Nouvelle feature
- 🧪 Tests

[Unreleased]: https://github.com/Darlene-kitty/GameMaster/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/Darlene-kitty/GameMaster/releases/tag/v1.0.0
[0.1.0]: https://github.com/Darlene-kitty/GameMaster/releases/tag/v0.1.0
