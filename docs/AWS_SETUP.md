# Configuration AWS pour GameMaster

## 📋 Étapes pour obtenir les credentials AWS

### 1. Connexion à AWS Console
1. Allez sur https://console.aws.amazon.com/
2. Connectez-vous avec votre compte AWS

### 2. Créer un utilisateur IAM

1. **Accéder à IAM** :
   - Dans la barre de recherche AWS, tapez "IAM"
   - Cliquez sur "IAM" (Identity and Access Management)

2. **Créer un utilisateur** :
   - Dans le menu de gauche, cliquez sur "Users" (Utilisateurs)
   - Cliquez sur "Create user" (Créer un utilisateur)
   - Nom d'utilisateur : `rocketchat-backup-user`
   - Cochez "Provide user access to the AWS Management Console" si vous voulez un accès console (optionnel)
   - Cliquez sur "Next"

3. **Définir les permissions** :
   - Sélectionnez "Attach policies directly"
   - Recherchez et cochez : **AmazonS3FullAccess** (ou créez une politique personnalisée plus restrictive)
   - Cliquez sur "Next"

4. **Créer l'utilisateur** :
   - Vérifiez les informations
   - Cliquez sur "Create user"

### 3. Créer les Access Keys

1. **Accéder aux Security Credentials** :
   - Cliquez sur l'utilisateur que vous venez de créer
   - Allez dans l'onglet "Security credentials"

2. **Créer une Access Key** :
   - Descendez jusqu'à "Access keys"
   - Cliquez sur "Create access key"
   - Sélectionnez "Command Line Interface (CLI)"
   - Cochez "I understand the above recommendation"
   - Cliquez sur "Next"
   - (Optionnel) Ajoutez une description : "Backup Rocket.Chat"
   - Cliquez sur "Create access key"

3. **⚠️ IMPORTANT - Sauvegarder les credentials** :
   - **Access key ID** : Commence par `AKIA...`
   - **Secret access key** : Longue chaîne de caractères
   - ⚠️ **Copiez-les immédiatement** - vous ne pourrez plus voir le secret après !
   - Cliquez sur "Download .csv file" pour les sauvegarder

### 4. Créer un bucket S3

1. **Accéder à S3** :
   - Dans la barre de recherche AWS, tapez "S3"
   - Cliquez sur "S3"

2. **Créer un bucket** :
   - Cliquez sur "Create bucket"
   - **Nom du bucket** : `rocketchat-backup-votrenom` (doit être unique globalement)
   - **Région** : Choisissez `eu-west-1` (Irlande) ou votre région préférée
   - **Block Public Access** : Laissez tout coché (sécurité)
   - Cliquez sur "Create bucket"

### 5. Obtenir votre Account ID

1. **Méthode 1 - Via le menu utilisateur** :
   - Cliquez sur votre nom en haut à droite
   - Votre Account ID est affiché (12 chiffres)

2. **Méthode 2 - Via IAM** :
   - Allez dans IAM Dashboard
   - L'Account ID est affiché en haut

## 🔧 Configuration dans le projet

### Mettre à jour le fichier .env

```bash
# AWS
AWS_ACCESS_KEY_ID=AKIAXXXXXXXXXXXXXXXX
AWS_SECRET_ACCESS_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
AWS_ACCOUNT_ID=123456789012
S3_BUCKET_NAME=rocketchat-backup-votrenom
AWS_DEFAULT_REGION=eu-west-1
AWS_REGION=eu-west-1
```

⚠️ **Remplacez les X par vos vraies valeurs AWS**

### Tester la configuration

```bash
# Redémarrer le service de backup
docker compose restart s3-backup

# Vérifier les logs
docker compose logs s3-backup

# Tester une sauvegarde manuelle
docker compose exec s3-backup bash /backup.sh
```

## 🔒 Politique IAM personnalisée (recommandée)

Pour plus de sécurité, créez une politique IAM restrictive :

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::rocketchat-backup-votrenom",
        "arn:aws:s3:::rocketchat-backup-votrenom/*"
      ]
    }
  ]
}
```

### Appliquer la politique personnalisée :

1. Dans IAM, allez dans "Policies"
2. Cliquez sur "Create policy"
3. Collez le JSON ci-dessus (en remplaçant le nom du bucket)
4. Nommez-la : `RocketChatBackupPolicy`
5. Attachez cette politique à votre utilisateur au lieu de `AmazonS3FullAccess`

## 🔐 Configuration pour GitHub Actions (CI/CD)

Si vous utilisez le pipeline CI/CD, ajoutez les secrets dans GitHub :

1. Allez dans votre repo GitHub
2. Settings → Secrets and variables → Actions
3. Cliquez sur "New repository secret"
4. Ajoutez chaque secret :
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_REGION`
   - `AWS_ACCOUNT_ID`
   - `S3_BUCKET_NAME`

## ✅ Vérification

Une fois configuré, vérifiez que tout fonctionne :

```bash
# Vérifier que le bucket existe
docker compose exec s3-backup aws s3 ls s3://rocketchat-backup-votrenom

# Lancer une sauvegarde test
docker compose exec s3-backup bash /backup.sh

# Vérifier que le fichier est dans S3
docker compose exec s3-backup aws s3 ls s3://rocketchat-backup-votrenom/rocketchat/daily/
```

## 🆘 Dépannage

### Erreur "Access Denied"
- Vérifiez que les credentials sont corrects
- Vérifiez que l'utilisateur IAM a les bonnes permissions
- Vérifiez que le nom du bucket est correct

### Erreur "Bucket does not exist"
- Vérifiez que le bucket existe dans la bonne région
- Vérifiez l'orthographe du nom du bucket

### Les credentials ne fonctionnent pas
- Vérifiez qu'il n'y a pas d'espaces avant/après dans le fichier .env
- Recréez les Access Keys si nécessaire
