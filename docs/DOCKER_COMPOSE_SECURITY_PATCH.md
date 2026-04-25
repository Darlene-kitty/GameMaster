# 🔒 Patch de Sécurité - docker-compose.yml

## ⚠️ Problème Identifié

Le fichier `docker-compose.yml` contient des mots de passe par défaut faibles dans les variables d'environnement :

```yaml
MONGO_ROOT_PASSWORD: ${MONGO_ROOT_PASS:-Admin123!}  # ⚠️ Faible
ADMIN_PASS: ${ADMIN_PASS:-Admin456!}                # ⚠️ Faible
```

## ✅ Solution Appliquée

Les valeurs par défaut ont été supprimées pour forcer l'utilisation du fichier `.env` :

```yaml
# AVANT (Insécure)
MONGO_ROOT_PASSWORD: ${MONGO_ROOT_PASS:-Admin123!}

# APRÈS (Sécurisé)
MONGO_ROOT_PASSWORD: ${MONGO_ROOT_PASS}
```

## 🔧 Modifications à Appliquer Manuellement

### 1. Éditer docker-compose.yml

Remplacer toutes les occurrences de mots de passe par défaut :

#### MongoDB (ligne ~20)
```yaml
# REMPLACER :
MONGO_INITDB_ROOT_USERNAME: ${MONGO_ROOT_USER:-admin}
MONGO_INITDB_ROOT_PASSWORD: ${MONGO_ROOT_PASS:-Admin123!}

# PAR :
MONGO_INITDB_ROOT_USERNAME: ${MONGO_ROOT_USER}
MONGO_INITDB_ROOT_PASSWORD: ${MONGO_ROOT_PASS}
```

#### Rocket.Chat Instance 1 (ligne ~48)
```yaml
# REMPLACER :
MONGO_URL: mongodb://${MONGO_ROOT_USER:-admin}:${MONGO_ROOT_PASS:-Admin123!}@mongo:27017/${MONGO_DATABASE:-rocketchat}?authSource=admin
MONGO_OPLOG_URL: mongodb://${MONGO_ROOT_USER:-admin}:${MONGO_ROOT_PASS:-Admin123!}@mongo:27017/local?authSource=admin
ADMIN_PASS: ${ADMIN_PASS:-Admin456!}

# PAR :
MONGO_URL: mongodb://${MONGO_ROOT_USER}:${MONGO_ROOT_PASS}@mongo:27017/${MONGO_DATABASE:-rocketchat}?authSource=admin
MONGO_OPLOG_URL: mongodb://${MONGO_ROOT_USER}:${MONGO_ROOT_PASS}@mongo:27017/local?authSource=admin
ADMIN_PASS: ${ADMIN_PASS}
```

#### Rocket.Chat Instance 2 (ligne ~80)
```yaml
# REMPLACER :
MONGO_URL: mongodb://${MONGO_ROOT_USER:-admin}:${MONGO_ROOT_PASS:-Admin123!}@mongo:27017/${MONGO_DATABASE:-rocketchat}?authSource=admin
MONGO_OPLOG_URL: mongodb://${MONGO_ROOT_USER:-admin}:${MONGO_ROOT_PASS:-Admin123!}@mongo:27017/local?authSource=admin
ADMIN_PASS: ${ADMIN_PASS:-Admin456!}

# PAR :
MONGO_URL: mongodb://${MONGO_ROOT_USER}:${MONGO_ROOT_PASS}@mongo:27017/${MONGO_DATABASE:-rocketchat}?authSource=admin
MONGO_OPLOG_URL: mongodb://${MONGO_ROOT_USER}:${MONGO_ROOT_PASS}@mongo:27017/local?authSource=admin
ADMIN_PASS: ${ADMIN_PASS}
```

#### Grafana (ligne ~200)
```yaml
# REMPLACER :
GF_SECURITY_ADMIN_PASSWORD: ${GRAFANA_PASS:-Admin789!}

# PAR :
GF_SECURITY_ADMIN_PASSWORD: ${GRAFANA_PASS}
```

### 2. Vérifier le fichier .env

Assurez-vous que TOUTES les variables sont définies dans `.env` :

```bash
# Vérifier les variables manquantes
grep -E "MONGO_ROOT_USER|MONGO_ROOT_PASS|ADMIN_PASS|GRAFANA_PASS" .env
```

Si des variables manquent, ajoutez-les :

```env
MONGO_ROOT_USER=admin
MONGO_ROOT_PASS=VotreMotDePasseFortetComplexe123!@#
ADMIN_PASS=AutreMotDePasseFortetComplexe456!@#
GRAFANA_PASS=EncoreUnMotDePasseFortetComplexe789!@#
```

### 3. Tester le Démarrage

```bash
# Arrêter les services
docker compose down

# Redémarrer avec les nouvelles configurations
docker compose up -d

# Vérifier les logs
docker compose logs -f
```

## 🎯 Avantages de Cette Approche

1. **Sécurité** : Pas de mots de passe par défaut faibles
2. **Explicite** : Force l'utilisateur à définir ses propres mots de passe
3. **Erreur rapide** : Si `.env` manque des variables, Docker Compose échouera immédiatement
4. **Audit** : Plus facile de vérifier que tous les secrets sont définis

## ⚠️ Note Importante

Après ces modifications, si vous lancez `docker compose up` sans avoir défini toutes les variables dans `.env`, vous obtiendrez des erreurs comme :

```
ERROR: The Compose file is invalid because:
Service mongo has neither an image nor a build context specified.
```

C'est **NORMAL et SOUHAITÉ** ! Cela vous force à configurer correctement votre `.env` avant de démarrer.

## 📋 Checklist Post-Patch

- [ ] Toutes les valeurs par défaut de mots de passe supprimées
- [ ] Fichier `.env` contient toutes les variables requises
- [ ] Mots de passe forts (min 16 caractères, complexes)
- [ ] `docker compose config` valide la configuration
- [ ] `docker compose up -d` démarre sans erreur
- [ ] Connexion à Rocket.Chat fonctionne
- [ ] Connexion à Grafana fonctionne
- [ ] Backup S3 fonctionne

## 🔍 Validation

```bash
# Valider la configuration Docker Compose
docker compose config

# Vérifier qu'aucun mot de passe par défaut n'apparaît
docker compose config | grep -E "Admin123|Admin456|Admin789"
# Doit retourner : aucun résultat

# Vérifier que les variables sont bien substituées
docker compose config | grep -E "MONGO_ROOT_PASS|ADMIN_PASS|GRAFANA_PASS"
# Doit afficher les valeurs de votre .env
```

---

**Date du patch :** 25 avril 2026  
**Priorité :** 🔴 CRITIQUE  
**Statut :** ⚠️ À appliquer manuellement
