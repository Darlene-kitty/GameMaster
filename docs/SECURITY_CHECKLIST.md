# 🔒 Checklist de Sécurité - Avant Production

## ✅ Configuration Obligatoire

### 1. Mots de Passe
- [ ] Changer `MONGO_ROOT_PASS` (min 16 caractères, complexe)
- [ ] Changer `ADMIN_PASS` (min 16 caractères, complexe)
- [ ] Changer `GRAFANA_PASS` (min 16 caractères, complexe)
- [ ] Vérifier que `.env` est dans `.gitignore`
- [ ] Ne JAMAIS commiter `.env` dans Git

### 2. Domaine et SSL
- [ ] Configurer `ROOT_URL` avec votre vrai domaine (https://votre-domaine.com)
- [ ] Obtenir des certificats Let's Encrypt valides
- [ ] Tester le renouvellement automatique Certbot
- [ ] Vérifier que HTTPS fonctionne (pas d'erreur de certificat)

### 3. AWS (si backup activé)
- [ ] Créer un utilisateur IAM dédié (pas de root account)
- [ ] Permissions minimales : `s3:PutObject`, `s3:GetObject` sur le bucket uniquement
- [ ] Configurer `AWS_ACCESS_KEY_ID` et `AWS_SECRET_ACCESS_KEY`
- [ ] Tester un backup manuel : `docker compose exec s3-backup bash /backup.sh`
- [ ] Vérifier que le backup apparaît dans S3

### 4. Ports et Firewall
- [ ] Fermer le port 9999 (Dozzle) ou le protéger par VPN
- [ ] Fermer le port 3001 (Grafana) ou le protéger par VPN
- [ ] Exposer uniquement 80 et 443 publiquement
- [ ] Configurer un firewall (AWS Security Groups / iptables)

### 5. MongoDB
- [ ] Vérifier que MongoDB n'est PAS exposé publiquement (port 27017)
- [ ] Tester la connexion avec les nouveaux credentials
- [ ] Activer les backups automatiques (déjà configuré dans docker-compose)

### 6. Rocket.Chat
- [ ] Changer le mot de passe admin après la première connexion
- [ ] Activer l'authentification 2FA pour les admins
- [ ] Configurer les paramètres SMTP pour les emails
- [ ] Désactiver l'inscription publique si non nécessaire
- [ ] Configurer les rôles et permissions

### 7. Monitoring
- [ ] Configurer des alertes Prometheus (CPU > 80%, RAM > 90%, etc.)
- [ ] Tester l'accès Grafana avec les nouveaux credentials
- [ ] Importer des dashboards de monitoring
- [ ] Configurer des notifications (Slack, email, etc.)

## 🔍 Tests de Sécurité

### Test 1 : Vérifier les headers de sécurité
```bash
curl -I https://votre-domaine.com
```

Doit contenir :
- `Strict-Transport-Security`
- `X-Frame-Options: SAMEORIGIN`
- `X-Content-Type-Options: nosniff`
- `X-XSS-Protection`

### Test 2 : Vérifier le WAF ModSecurity
```bash
# Tenter une injection SQL (doit être bloqué)
curl "https://votre-domaine.com/?id=1' OR '1'='1"
```

Doit retourner une erreur 403 Forbidden.

### Test 3 : Vérifier le redirect HTTP → HTTPS
```bash
curl -I http://votre-domaine.com
```

Doit retourner un code 301 avec `Location: https://...`

### Test 4 : Scanner les vulnérabilités
```bash
# Installer OWASP ZAP ou utiliser :
docker run --rm -t owasp/zap2docker-stable zap-baseline.py -t https://votre-domaine.com
```

## 📋 Checklist Post-Déploiement

- [ ] Tous les services sont "healthy" : `docker compose ps`
- [ ] Rocket.Chat accessible via HTTPS
- [ ] Bot GameMaster répond aux commandes `/gm help`
- [ ] Grafana affiche les métriques
- [ ] Backup S3 fonctionne (vérifier dans AWS Console)
- [ ] Logs accessibles via Dozzle
- [ ] Certificats SSL valides (pas d'avertissement navigateur)
- [ ] Healthchecks passent : `curl https://votre-domaine.com/api/info`

## 🚨 En Cas de Problème

### Logs à vérifier
```bash
docker compose logs nginx
docker compose logs rocketchat-1
docker compose logs mongo
docker compose logs s3-backup
```

### Restaurer un backup
```bash
# Lister les backups disponibles
aws s3 ls s3://VOTRE_BUCKET/rocketchat/daily/

# Télécharger
aws s3 cp s3://VOTRE_BUCKET/rocketchat/daily/rocketchat_backup_YYYYMMDD.archive.gz ./

# Restaurer
docker compose exec mongo mongorestore \
  --uri="mongodb://admin:VOTRE_PASS@localhost:27017/rocketchat?authSource=admin" \
  --archive=/backup.archive.gz \
  --gzip
```

## 📞 Contacts d'Urgence

- **Documentation Rocket.Chat** : https://docs.rocket.chat
- **Support AWS** : https://console.aws.amazon.com/support/
- **OWASP ModSecurity** : https://github.com/SpiderLabs/ModSecurity

---

**⚠️ IMPORTANT :** Cette checklist doit être complétée AVANT de mettre l'application en production !
