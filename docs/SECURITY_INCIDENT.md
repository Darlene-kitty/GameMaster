# 🚨 INCIDENT DE SÉCURITÉ - ACTION IMMÉDIATE REQUISE

## ⚠️ Credentials AWS exposés

Des credentials AWS ont été détectés dans le commit `59ad0fee9b795506920a9cfc0f66311b141c376d`.

### 🔴 Actions URGENTES à faire MAINTENANT

#### 1. Révoquer les Access Keys exposées

1. **Allez sur AWS Console** : https://console.aws.amazon.com/iam/
2. **IAM** → **Users** → Sélectionnez votre utilisateur
3. **Security credentials** → **Access keys**
4. Trouvez la clé : `AKIAY2LQWSQLUXNVSO7M`
5. Cliquez sur **Actions** → **Deactivate** (désactiver)
6. Puis **Actions** → **Delete** (supprimer)

#### 2. Créer de nouvelles Access Keys

1. Dans la même page **Security credentials**
2. Cliquez sur **Create access key**
3. Sélectionnez **Command Line Interface (CLI)**
4. **Téléchargez le CSV** avec les nouvelles clés
5. ⚠️ **NE LES METTEZ JAMAIS dans un fichier qui sera commité !**

#### 3. Mettre à jour votre fichier .env LOCAL

```bash
# Ouvrez votre fichier .env LOCAL (pas dans Git !)
nano .env

# Mettez à jour avec les NOUVELLES clés
AWS_ACCESS_KEY_ID=AKIA_NOUVELLE_CLE
AWS_SECRET_ACCESS_KEY=nouvelle_secret_key
```

#### 4. Mettre à jour les GitHub Secrets

1. **GitHub** → **Votre Repo** → **Settings**
2. **Secrets and variables** → **Actions**
3. Cliquez sur `AWS_ACCESS_KEY_ID` → **Update**
4. Collez la NOUVELLE valeur
5. Répétez pour `AWS_SECRET_ACCESS_KEY`

#### 5. Nettoyer l'historique Git

```bash
# Annuler le dernier commit (AVANT de push)
git reset --soft HEAD~1

# Vérifier que les fichiers sont corrects
cat docs/AWS_SETUP.md | grep AWS_ACCESS_KEY_ID
# Doit afficher : AWS_ACCESS_KEY_ID=AKIAXXXXXXXXXXXXXXXX

# Re-commiter avec les placeholders
git add docs/
git commit -m "docs: add AWS and Git setup guides with placeholders"

# Pusher
git push origin main
```

## ✅ Vérification

Une fois les clés révoquées et l'historique nettoyé :

- [ ] Anciennes Access Keys supprimées sur AWS
- [ ] Nouvelles Access Keys créées
- [ ] Fichier `.env` local mis à jour (JAMAIS commité)
- [ ] GitHub Secrets mis à jour
- [ ] Fichiers de documentation ne contiennent que des placeholders (XXXX)
- [ ] Push réussi sur GitHub

## 🛡️ Prévention future

### Règles à suivre :

1. ✅ **JAMAIS** mettre de vraies credentials dans les fichiers de documentation
2. ✅ Toujours utiliser des placeholders : `AKIAXXXXXXXXXXXXXXXX`
3. ✅ Les vraies credentials vont UNIQUEMENT dans :
   - `.env` (qui est dans `.gitignore`)
   - GitHub Secrets (pour CI/CD)
4. ✅ Vérifier avec `git status` avant chaque commit
5. ✅ Utiliser `git diff` pour voir ce qui sera commité

### Outils de protection :

```bash
# Installer git-secrets pour détecter les secrets
git clone https://github.com/awslabs/git-secrets.git
cd git-secrets
sudo make install

# Configurer dans votre repo
cd /path/to/GameMaster
git secrets --install
git secrets --register-aws
```

## 📚 Ressources

- [AWS - What to do if you expose credentials](https://aws.amazon.com/premiumsupport/knowledge-center/delete-access-key/)
- [GitHub Secret Scanning](https://docs.github.com/en/code-security/secret-scanning)
- [Git Secrets Tool](https://github.com/awslabs/git-secrets)
