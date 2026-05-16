# 🎮 Guide de Démonstration - GameMaster TPS

## 📋 Informations de connexion

| Service | URL | Credentials |
|---------|-----|-------------|
| **Rocket.Chat** | http://54.224.29.219:8080 | admin / Admin456! |
| **Grafana** | http://54.224.29.219:3001 | admin / Admin789! |
| **Dozzle (logs)** | http://54.224.29.219:9999 | aucun |
| **EC2 SSH** | `ssh -i rocketchat-key.pem ubuntu@54.224.29.219` | - |

---

## 🚀 Étape 1 - Démarrer la démo

### Vérifier que tout tourne sur EC2
```bash
ssh -i C:\Users\surface\gamemaster\rocketchat-key.pem ubuntu@54.224.29.219
cd /opt/rocket-chat-tps
docker compose ps
```

Tous les containers doivent être **Up** ou **healthy**.

---

## 👥 Étape 2 - Créer un utilisateur test

1. Connectez-vous sur http://54.224.29.219:8080 avec `admin` / `Admin456!`
2. **☰ Menu** → **Administration** → **Users** → **New User**
3. Remplissez :
   - **Name** : `TestUser`
   - **Username** : `testuser`
   - **Email** : `test@localhost.local`
   - **Password** : `Test123!`
   - **Role** : `user`
4. Cliquez sur **Save**

---

## 💬 Étape 3 - Tester la communication

### Ouvrir deux navigateurs
| Navigateur | Utilisateur | URL |
|------------|-------------|-----|
| Chrome | `admin` / `Admin456!` | http://54.224.29.219:8080 |
| Edge (ou onglet privé) | `testuser` / `Test123!` | http://54.224.29.219:8080 |

### Test channel public (#general)
1. Admin envoie un message dans **#general**
2. TestUser le voit en **temps réel** ✅

### Test message direct (DM)
1. Cliquez sur **✏️** (icône crayon) → New Direct Message
2. Cherchez `testuser`
3. Envoyez un message privé ✅

---

## 🎲 Étape 4 - Tester le bot GameMaster

Dans le channel **#general**, tapez ces commandes :

```
/gm help
```
→ Affiche l'aide du bot

```
/gm roll 2d20+4
```
→ Lance 2 dés à 20 faces + 4

```
/gm poll Meilleur RPG ? | Donjons | Cyberpunk | Fantasy
```
→ Crée un sondage interactif

```
/gm remind 1m Test de rappel !
```
→ Envoie un rappel dans 1 minute

```
/gm mod warn @testuser Comportement inapproprié
```
→ Avertit un utilisateur (modération)

---

## 📊 Étape 5 - Montrer le monitoring

### Grafana
1. Ouvrez http://54.224.29.219:3001
2. Connectez-vous : `admin` / `Admin789!`
3. Montrez les métriques CPU/RAM des containers

### Dozzle (logs en temps réel)
1. Ouvrez http://54.224.29.219:9999
2. Cliquez sur `rocket-app-1` pour voir les logs en temps réel
3. Envoyez un message dans Rocket.Chat → les logs apparaissent

---

## 🔄 Étape 6 - Démontrer le CI/CD

```bash
# Sur votre machine locale
cd C:\Users\surface\gamemaster\GameMaster

# Faire un changement
echo "# Demo CI/CD" >> README.md

# Commit et push
git add .
git commit -m "demo: test pipeline CI/CD"
git push origin main
```

Puis montrez sur **GitHub → Actions** le pipeline qui :
1. ✅ Build l'image Docker
2. ✅ Push vers AWS ECR
3. ✅ Déploie sur EC2 via SSH

---

## 🏗️ Étape 7 - Montrer l'architecture

```
Internet
    │
    ▼
Nginx (Load Balancer + Reverse Proxy)
:8080 → rocketchat-1:3000
      → rocketchat-2:3000 (ip_hash)
    │
    ▼
MongoDB (Replica Set rs0)
    │
    ▼
S3 Backup (cron 03:00 daily)
```

### Prouver le load balancing
```bash
# Sur EC2, voir les logs des deux instances
docker compose logs rocketchat-1 | grep "connection"
docker compose logs rocketchat-2 | grep "connection"
```

---

## 🔒 Étape 8 - Sécurité

### Containers non-root
```bash
docker compose exec rocketchat-1 whoami
# Doit afficher: rocketchat (UID 1001)
```

### Variables d'environnement sécurisées
```bash
# Les secrets sont dans .env (jamais commité)
cat .env | grep AWS
```

---

## 💾 Étape 9 - Tester la sauvegarde S3

```bash
# Sur EC2
cd /opt/rocket-chat-tps

# Lancer une sauvegarde manuelle
docker compose exec s3-backup bash /backup.sh

# Vérifier dans S3
docker compose exec s3-backup aws s3 ls s3://rocketchat-backup-kouang/
```

---

## 🆘 Commandes utiles en cas de problème

```bash
# Redémarrer tous les services
docker compose restart

# Voir l'état des containers
docker compose ps

# Voir les logs d'un service
docker compose logs -f rocketchat-1

# Redémarrer un service spécifique
docker compose restart rocketchat-1

# Arrêter et relancer tout
docker compose down && docker compose up -d
```

---

## ✅ Checklist de démonstration

- [ ] Tous les containers sont **Up**
- [ ] Rocket.Chat accessible sur :8080
- [ ] Connexion admin réussie
- [ ] Utilisateur test créé
- [ ] Communication entre 2 users testée
- [ ] Bot GameMaster répond aux commandes
- [ ] Grafana affiche les métriques
- [ ] Dozzle affiche les logs
- [ ] Pipeline CI/CD déclenché
- [ ] Sauvegarde S3 fonctionnelle
