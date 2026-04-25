# 🎮 GameMaster Bot - Rocket.Chat App

Bot RPG pour Rocket.Chat avec commandes de jeu de rôle, modération et gestion de groupe.

## 📋 Description

GameMaster est une application Rocket.Chat qui ajoute des fonctionnalités de jeu de rôle et de modération inspirées de Discord. Le bot permet aux joueurs de lancer des dés, créer des sondages, programmer des rappels et gérer la modération.

## ✨ Fonctionnalités

### 🎲 Commandes de Jeu

#### `/gm roll [dice]`
Lance des dés avec notation standard RPG.

**Exemples :**
```
/gm roll 1d20          # Lance 1 dé à 20 faces
/gm roll 2d6+3         # Lance 2 dés à 6 faces et ajoute 3
/gm roll 3d10          # Lance 3 dés à 10 faces
```

**Résultat :**
- Affiche les résultats individuels
- Calcule le total
- Détecte les critiques (tous les dés au maximum)

#### `/gm poll [question] | [option1] | [option2] | ...`
Crée un sondage de groupe.

**Exemples :**
```
/gm poll Partir en quête ? | Oui | Non
/gm poll Quelle direction ? | Nord | Sud | Est | Ouest
/gm poll Pause ? 
```

**Résultat :**
- Affiche la question et les options
- Si pas d'options : invite à réagir avec 👍/👎

#### `/gm remind [temps] [message]`
Programme un rappel (affichage uniquement).

**Exemples :**
```
/gm remind 10m Pause café
/gm remind 1h Réunion équipe
```

**Note :** Cette commande affiche le rappel mais ne déclenche pas de notification automatique. Pour des rappels réels, utilisez un scheduler externe.

### 🛡️ Commandes de Modération

#### `/gm mod [action] [user] [raison]`
Commandes de modération style MEE6/Discord.

**Actions disponibles :**
- `warn` : Avertir un utilisateur
- `kick` : Expulser un utilisateur
- `ban` : Bannir un utilisateur

**Exemples :**
```
/gm mod warn @user Spam
/gm mod kick @user Comportement inapproprié
/gm mod ban @user Violation des règles
```

### ℹ️ Aide

#### `/gm help`
Affiche la liste complète des commandes avec exemples.

## 🚀 Installation

### Prérequis
- Rocket.Chat Server (version 6.0+)
- Node.js 18+
- npm ou yarn

### Installation Automatique (Docker)

Le bot est déployé automatiquement via le service `rpg-setup` dans `docker-compose.yml` :

```bash
# Le bot s'installe automatiquement au démarrage
docker compose up -d
```

### Installation Manuelle

```bash
# 1. Installer les dépendances
cd rocketchat-app
npm install

# 2. Packager l'application
npx @rocket.chat/apps-cli package

# 3. Se connecter à Rocket.Chat
npx @rocket.chat/apps-cli login

# 4. Déployer
npx @rocket.chat/apps-cli deploy
```

## 🛠️ Développement

### Structure du Projet

```
rocketchat-app/
├── GameMasterApp.ts       # Code principal du bot
├── app.json               # Métadonnées de l'app
├── icon.png               # Icône du bot
├── discord-theme.css      # Thème visuel
├── package.json           # Dépendances
└── tsconfig.json          # Configuration TypeScript
```

### Développement Local

```bash
# Installer les dépendances
npm install

# Compiler TypeScript
npm run build

# Packager
npm run package

# Déployer en dev
npm run deploy
```

### Tester les Commandes

Une fois déployé, testez dans Rocket.Chat :

```
/gm help
/gm roll 2d20+4
/gm poll Test ? | Option A | Option B
/gm remind 5m Test
/gm mod warn @testuser Test
```

## 🎨 Personnalisation

### Modifier les Commandes

Éditez `GameMasterApp.ts` et ajoutez de nouveaux `case` dans le `switch` :

```typescript
case 'nouvelle-commande':
    attachmentTitle = 'TITRE';
    attachmentText = 'Contenu de la commande';
    break;
```

### Modifier le Thème

Le thème visuel est dans `discord-theme.css`. Modifiez les variables CSS :

```css
:root {
    --rcx-color-primary-500: #e67e22; /* Couleur d'accent */
    --rcx-color-surface: #111214;     /* Fond principal */
}
```

### Ajouter des Alias

Dans `GameMasterApp.ts`, ajoutez des alias de commandes :

```typescript
public async initialize(configuration: IConfigurationExtend): Promise<void> {
    await configuration.slashCommands.provideSlashCommand(new GameMasterCommand('gm'));
    await configuration.slashCommands.provideSlashCommand(new GameMasterCommand('gamemaster'));
    await configuration.slashCommands.provideSlashCommand(new GameMasterCommand('dm')); // Nouveau
}
```

## 📚 API Rocket.Chat Apps

### Interfaces Principales

- `ISlashCommand` : Définir des commandes slash
- `IModify` : Modifier des messages
- `IRead` : Lire des données
- `IPersistence` : Stocker des données

### Exemple : Stocker des Données

```typescript
// Sauvegarder
await persis.createWithAssociation(
    { score: 100 },
    new RocketChatAssociationRecord(RocketChatAssociationModel.USER, userId)
);

// Récupérer
const data = await read.getPersistenceReader().readByAssociation(
    new RocketChatAssociationRecord(RocketChatAssociationModel.USER, userId)
);
```

## 🧪 Tests

### Tests Manuels

Checklist de tests :

- [ ] `/gm help` affiche l'aide
- [ ] `/gm roll 1d20` lance un dé
- [ ] `/gm roll 2d6+3` calcule correctement
- [ ] `/gm poll Question ? | A | B` crée un sondage
- [ ] `/gm remind 10m Test` affiche le rappel
- [ ] `/gm mod warn @user Test` affiche l'action
- [ ] Le bot répond avec l'alias `/gamemaster`
- [ ] Les messages du bot ont le style orange
- [ ] L'avatar du bot s'affiche (🤖)

### Tests Automatisés

TODO : Ajouter des tests unitaires avec Jest.

## 🐛 Dépannage

### Le bot ne répond pas

**Vérifier :**
```bash
# Logs du container
docker compose logs rpg-setup

# Vérifier que l'app est installée
# Dans Rocket.Chat : Administration > Apps > Installed Apps
```

### Erreur "Command not found"

**Solution :**
1. Vérifier que l'app est activée dans Administration > Apps
2. Redémarrer Rocket.Chat : `docker compose restart rocketchat-1`

### Le thème ne s'applique pas

**Solution :**
```bash
# Réappliquer le thème
cd rocketchat-app
node ../scripts/apply-discord-theme.js

# Vider le cache du navigateur
Ctrl + Shift + Delete
```

### Erreur de compilation TypeScript

**Solution :**
```bash
# Nettoyer et réinstaller
rm -rf node_modules package-lock.json
npm install
npm run build
```

## 📖 Ressources

### Documentation Officielle
- [Rocket.Chat Apps Engine](https://rocketchat.github.io/Rocket.Chat.Apps-engine/)
- [Apps TypeScript Definitions](https://github.com/RocketChat/Rocket.Chat.Apps-engine)
- [Example Apps](https://github.com/graywolf336/RocketChatApps)

### Communauté
- [Forum Apps Requests](https://forums.rocket.chat/c/rocket-chat-apps/requests)
- [Forum Apps Guides](https://forums.rocket.chat/c/rocket-chat-apps/guides)
- [#rocketchat-apps sur Open.Rocket.Chat](https://open.rocket.chat/channel/rocketchat-apps)

### Tutoriels
- [Creating Your First App](https://developer.rocket.chat/apps-engine/getting-started)
- [Slash Commands Guide](https://developer.rocket.chat/apps-engine/slash-commands)
- [UI Kit Components](https://developer.rocket.chat/apps-engine/uikit)

## 🤝 Contribution

Pour contribuer au bot GameMaster :

1. Fork le repository
2. Créer une branche : `git checkout -b feature/nouvelle-commande`
3. Commit : `git commit -m "feat: ajout commande XYZ"`
4. Push : `git push origin feature/nouvelle-commande`
5. Créer une Pull Request

## 📝 Licence

Ce projet fait partie du TPS Cloud, Virtualisation & Datacenter.

## 👤 Auteur

**KOUANG**  
- GitHub: [@Darlene-kitty](https://github.com/Darlene-kitty)
- Repository: [GameMaster](https://github.com/Darlene-kitty/GameMaster.git)

---

**Version :** 0.0.1  
**Dernière mise à jour :** Avril 2026
