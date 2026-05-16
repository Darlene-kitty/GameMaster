# Configuration Git & GitHub pour GameMaster

## 🔒 1. Vérifier la sécurité locale

### ✅ Vérifier que .env est ignoré

```bash
# Vérifier que .env est dans .gitignore
cat .gitignore | grep .env

# Vérifier que .env n'est PAS tracké par git
git status

# Si .env apparaît, le retirer immédiatement :
git rm --cached .env
git commit -m "chore: remove .env from git tracking"
```

### ⚠️ Si vous avez déjà commité .env par erreur

```bash
# Supprimer .env de l'historique Git (DANGEREUX - change l'historique)
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch .env" \
  --prune-empty --tag-name-filter cat -- --all

# Forcer le push (si déjà pushé)
git push origin --force --all
```

## 🔐 2. Configurer les GitHub Secrets

Les secrets GitHub permettent au pipeline CI/CD d'accéder à AWS et à votre serveur EC2 sans exposer les credentials.

### Accéder aux Secrets GitHub

1. Allez sur votre repository GitHub
2. Cliquez sur **Settings** (Paramètres)
3. Dans le menu de gauche : **Secrets and variables** → **Actions**
4. Cliquez sur **New repository secret**

### Secrets à configurer

#### 🔑 **AWS Credentials** (pour ECR - Docker Registry)

| Nom du secret | Valeur | Description |
|---------------|--------|-------------|
| `AWS_ACCESS_KEY_ID` | `AKIAXXXXXXXXXXXXXXXX` | Votre Access Key IAM |
| `AWS_SECRET_ACCESS_KEY` | `xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx` | Votre Secret Key IAM |
| `AWS_REGION` | `eu-west-1` | Région AWS |
| `AWS_ACCOUNT_ID` | `123456789012` | Votre Account ID (12 chiffres) |

#### 🖥️ **SSH Credentials** (pour déployer sur EC2)

| Nom du secret | Valeur | Description |
|---------------|--------|-------------|
| `SSH_HOST` | `ec2-xx-xx-xx-xx.eu-west-1.compute.amazonaws.com` | IP publique ou DNS de votre EC2 |
| `SSH_USER` | `ubuntu` ou `ec2-user` | Utilisateur SSH (dépend de l'AMI) |
| `SSH_PRIVATE_KEY` | `-----BEGIN RSA PRIVATE KEY-----...` | Clé privée SSH complète |

### 📝 Comment obtenir la clé SSH privée

#### Si vous avez déjà une instance EC2 :

```bash
# La clé privée est le fichier .pem téléchargé lors de la création de l'instance
# Exemple : my-ec2-key.pem

# Afficher le contenu pour le copier
cat ~/.ssh/my-ec2-key.pem

# Copier TOUT le contenu, y compris :
# -----BEGIN RSA PRIVATE KEY-----
# ...
# -----END RSA PRIVATE KEY-----
```

#### Si vous n'avez pas encore d'instance EC2 :

Vous devrez d'abord créer une instance EC2 (voir section suivante).

### 🎯 Ajouter un secret dans GitHub

1. Cliquez sur **New repository secret**
2. **Name** : `AWS_ACCESS_KEY_ID`
3. **Secret** : Collez votre valeur
4. Cliquez sur **Add secret**
5. Répétez pour chaque secret

## 🖥️ 3. Configuration EC2 (optionnel - pour production)

Si vous voulez déployer sur AWS EC2 avec le pipeline CI/CD :

### Créer une instance EC2

1. **AWS Console** → **EC2** → **Launch Instance**

2. **Configuration recommandée** :
   - **Name** : `rocketchat-tps-server`
   - **AMI** : Ubuntu Server 22.04 LTS
   - **Instance type** : `t3.medium` (2 vCPU, 4 GB RAM minimum)
   - **Key pair** : Créer ou sélectionner une paire de clés SSH
   - **Network** : Autoriser SSH (22), HTTP (80), HTTPS (443)
   - **Storage** : 30 GB minimum

3. **Security Group** (Firewall) :
   ```
   Type        Protocol    Port    Source
   SSH         TCP         22      Votre IP
   HTTP        TCP         80      0.0.0.0/0
   HTTPS       TCP         443     0.0.0.0/0
   Custom      TCP         8080    0.0.0.0/0  (Rocket.Chat HTTP)
   Custom      TCP         8443    0.0.0.0/0  (Rocket.Chat HTTPS)
   Custom      TCP         3001    Votre IP   (Grafana)
   Custom      TCP         9999    Votre IP   (Dozzle)
   ```

4. **Lancer l'instance**

### Préparer l'instance EC2

```bash
# Se connecter via SSH
ssh -i ~/.ssh/my-ec2-key.pem ubuntu@ec2-xx-xx-xx-xx.compute.amazonaws.com

# Mettre à jour le système
sudo apt update && sudo apt upgrade -y

# Installer Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker ubuntu

# Installer Docker Compose
sudo apt install docker-compose-plugin -y

# Installer AWS CLI
sudo apt install awscli -y

# Configurer AWS CLI (pour pull depuis ECR)
aws configure
# Entrez vos AWS credentials

# Créer le répertoire de déploiement
sudo mkdir -p /opt/rocket-chat-tps
sudo chown ubuntu:ubuntu /opt/rocket-chat-tps

# Cloner le repository
cd /opt/rocket-chat-tps
git clone https://github.com/votre-username/GameMaster.git .

# Créer le fichier .env sur le serveur
nano .env
# Coller votre configuration (avec les vraies valeurs AWS)

# Se déconnecter et reconnecter pour appliquer les groupes
exit
```

### Tester le déploiement manuel

```bash
# Se reconnecter
ssh -i ~/.ssh/my-ec2-key.pem ubuntu@ec2-xx-xx-xx-xx.compute.amazonaws.com

# Aller dans le répertoire
cd /opt/rocket-chat-tps

# Lancer l'application
docker compose up -d

# Vérifier les logs
docker compose logs -f
```

## 🚀 4. Tester le pipeline CI/CD

Une fois tous les secrets configurés :

```bash
# Faire un changement
echo "# Test CI/CD" >> README.md

# Commit et push
git add .
git commit -m "test: vérification du pipeline CI/CD"
git push origin main
```

### Suivre l'exécution

1. Allez sur GitHub → **Actions**
2. Vous verrez le workflow "Build, Push & Deploy" en cours
3. Cliquez dessus pour voir les logs en temps réel

### Étapes du pipeline

1. ✅ **Build** : Construction de l'image Docker
2. ✅ **Push to ECR** : Upload vers AWS ECR
3. ✅ **Deploy to EC2** : Déploiement via SSH

## 📊 5. Configuration Git locale (bonnes pratiques)

```bash
# Configurer votre identité Git (si pas déjà fait)
git config --global user.name "Votre Nom"
git config --global user.email "votre.email@example.com"

# Configurer la branche par défaut
git config --global init.defaultBranch main

# Activer la coloration
git config --global color.ui auto

# Configurer l'éditeur par défaut
git config --global core.editor "code --wait"  # VS Code
# ou
git config --global core.editor "nano"  # Nano
```

## 🔍 6. Vérification finale

### Checklist de sécurité

- [ ] `.env` est dans `.gitignore`
- [ ] `.env` n'apparaît pas dans `git status`
- [ ] Les certificats SSL sont ignorés (`docker/nginx/certs/*.key`)
- [ ] Tous les secrets GitHub sont configurés
- [ ] La clé SSH privée n'est jamais commitée

### Checklist CI/CD (si vous utilisez EC2)

- [ ] Instance EC2 créée et accessible
- [ ] Docker et Docker Compose installés sur EC2
- [ ] AWS CLI configuré sur EC2
- [ ] Repository cloné dans `/opt/rocket-chat-tps`
- [ ] Fichier `.env` créé sur EC2
- [ ] Secrets GitHub configurés
- [ ] Pipeline GitHub Actions fonctionne

## 🆘 Dépannage

### Erreur "Permission denied (publickey)"
```bash
# Vérifier que la clé SSH a les bonnes permissions
chmod 600 ~/.ssh/my-ec2-key.pem

# Tester la connexion SSH
ssh -i ~/.ssh/my-ec2-key.pem ubuntu@votre-ec2-host -v
```

### Erreur "Unable to locate credentials" (ECR)
```bash
# Sur EC2, reconfigurer AWS CLI
aws configure
```

### Pipeline échoue sur "Build & Push"
- Vérifiez que les secrets AWS sont corrects
- Vérifiez que l'utilisateur IAM a les permissions ECR
- Créez le repository ECR manuellement si nécessaire :
  ```bash
  aws ecr create-repository --repository-name rocket-chat-tps --region eu-west-1
  ```

### Pipeline échoue sur "Deploy"
- Vérifiez que `SSH_HOST`, `SSH_USER`, `SSH_PRIVATE_KEY` sont corrects
- Vérifiez que le Security Group autorise SSH depuis GitHub Actions
- Vérifiez que le répertoire `/opt/rocket-chat-tps` existe sur EC2

## 📚 Ressources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [AWS ECR Documentation](https://docs.aws.amazon.com/ecr/)
- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
