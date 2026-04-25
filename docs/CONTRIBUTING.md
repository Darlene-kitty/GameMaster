# 🤝 Guide de Contribution - GameMaster

Merci de votre intérêt pour contribuer au projet GameMaster ! Ce guide vous aidera à démarrer.

## 📋 Table des Matières

- [Code de Conduite](#code-de-conduite)
- [Comment Contribuer](#comment-contribuer)
- [Setup Environnement de Développement](#setup-environnement-de-développement)
- [Standards de Code](#standards-de-code)
- [Process de Pull Request](#process-de-pull-request)
- [Reporting Bugs](#reporting-bugs)
- [Proposer des Fonctionnalités](#proposer-des-fonctionnalités)

## 📜 Code de Conduite

Ce projet adhère à un code de conduite. En participant, vous vous engagez à respecter ce code.

### Nos Standards

- Utiliser un langage accueillant et inclusif
- Respecter les points de vue et expériences différents
- Accepter gracieusement les critiques constructives
- Se concentrer sur ce qui est meilleur pour la communauté
- Faire preuve d'empathie envers les autres membres

## 🚀 Comment Contribuer

### Types de Contributions

Nous acceptons plusieurs types de contributions :

1. **🐛 Corrections de bugs** - Corriger des problèmes existants
2. **✨ Nouvelles fonctionnalités** - Ajouter de nouvelles commandes au bot
3. **📚 Documentation** - Améliorer ou traduire la documentation
4. **🎨 Design** - Améliorer le thème visuel
5. **🧪 Tests** - Ajouter des tests unitaires ou d'intégration
6. **⚡ Performance** - Optimiser le code existant

### Workflow de Contribution

1. **Fork** le repository
2. **Clone** votre fork localement
3. **Créer** une branche pour votre contribution
4. **Développer** votre fonctionnalité ou correction
5. **Tester** vos modifications
6. **Commit** avec des messages clairs
7. **Push** vers votre fork
8. **Créer** une Pull Request

## 🛠️ Setup Environnement de Développement

### Prérequis

- **Docker** & **Docker Compose** (pour l'environnement complet)
- **Node.js** 18+ (pour le bot Rocket.Chat)
- **Python** 3.11+ (pour l'app Flask)
- **Git** 2.30+

### Installation

```bash
# 1. Cloner le repository
git clone https://github.com/Darlene-kitty/GameMaster.git
cd GameMaster

# 2. Copier le fichier d'environnement
cp .env.example .env

# 3. Éditer .env avec vos valeurs
nano .env

# 4. Générer les certificats SSL
bash scripts/generate-ssl.sh

# 5. Démarrer l'environnement
docker compose up -d

# 6. Vérifier que tout fonctionne
docker compose ps
```

### Développement du Bot

```bash
cd rocketchat-app

# Installer les dépendances
npm install

# Compiler TypeScript
npm run build

# Packager l'app
npm run package

# Déployer en dev
npm run deploy
```

### Développement Flask

```bash
# Créer un environnement virtuel
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# Installer les dépendances
pip install -r requirements.txt

# Lancer en mode dev
python app.py
```

## 📏 Standards de Code

### Python

Nous suivons **PEP 8** avec quelques ajustements :

```python
# ✅ Bon
def calculate_dice_roll(num_dice: int, num_faces: int, bonus: int = 0) -> int:
    """
    Calculate the result of a dice roll.
    
    Args:
        num_dice: Number of dice to roll
        num_faces: Number of faces per die
        bonus: Bonus to add to the total
        
    Returns:
        Total of the dice roll plus bonus
    """
    total = sum(random.randint(1, num_faces) for _ in range(num_dice))
    return total + bonus

# ❌ Mauvais
def calc(n,f,b=0):
    t=0
    for i in range(n):
        t+=random.randint(1,f)
    return t+b
```

**Outils :**
```bash
# Formatter
black app.py

# Linter
flake8 app.py

# Type checker
mypy app.py
```

### TypeScript

Nous suivons les conventions **Rocket.Chat Apps** :

```typescript
// ✅ Bon
export class GameMasterCommand implements ISlashCommand {
    public command: string;
    public i18nDescription: string = 'Commandes du GameMaster';
    
    constructor(command: string = 'gm') {
        this.command = command;
    }
    
    public async executor(
        context: SlashCommandContext,
        read: IRead,
        modify: IModify
    ): Promise<void> {
        // Implementation
    }
}

// ❌ Mauvais
class cmd {
    c;
    constructor(c='gm'){this.c=c}
    async exec(ctx,r,m){/*...*/}
}
```

**Outils :**
```bash
# Linter
npm run lint

# Formatter
npm run format
```

### CSS

Nous suivons **BEM** pour les noms de classes :

```css
/* ✅ Bon */
.rcx-message__header {
    color: var(--rcx-color-font-default);
}

.rcx-message__header--highlighted {
    color: var(--rcx-color-primary-500);
}

/* ❌ Mauvais */
.msg-hdr {
    color: #e0d8e8;
}
```

### Commits

Nous utilisons **Conventional Commits** :

```bash
# Format
<type>(<scope>): <description>

# Types
feat:     # Nouvelle fonctionnalité
fix:      # Correction de bug
docs:     # Documentation
style:    # Formatage (pas de changement de code)
refactor: # Refactoring
test:     # Ajout de tests
chore:    # Maintenance

# Exemples
feat(bot): add /gm inventory command
fix(theme): correct scrollbar color on Firefox
docs(readme): update installation instructions
test(bot): add unit tests for dice rolling
```

## 🔄 Process de Pull Request

### Avant de Soumettre

- [ ] Le code compile sans erreur
- [ ] Les tests passent (si applicable)
- [ ] La documentation est à jour
- [ ] Le code suit les standards du projet
- [ ] Les commits suivent Conventional Commits
- [ ] Pas de secrets ou credentials dans le code

### Créer une Pull Request

1. **Titre clair** : Résumé en une ligne
   ```
   feat(bot): add inventory management system
   ```

2. **Description détaillée** :
   ```markdown
   ## Description
   Ajoute un système de gestion d'inventaire pour les joueurs.
   
   ## Changements
   - Nouvelle commande `/gm inventory`
   - Stockage persistant des items
   - Interface UI Kit pour afficher l'inventaire
   
   ## Tests
   - [x] Testé manuellement
   - [x] Tests unitaires ajoutés
   - [x] Documentation mise à jour
   
   ## Screenshots
   [Insérer captures d'écran si applicable]
   
   ## Breaking Changes
   Aucun
   ```

3. **Lier les Issues** :
   ```markdown
   Closes #42
   Fixes #38
   ```

### Review Process

1. Un mainteneur reviewera votre PR
2. Des changements peuvent être demandés
3. Une fois approuvée, la PR sera mergée
4. Votre contribution sera ajoutée au CHANGELOG

## 🐛 Reporting Bugs

### Avant de Reporter

- Vérifiez que le bug n'a pas déjà été reporté
- Testez avec la dernière version
- Collectez les informations nécessaires

### Template de Bug Report

```markdown
## Description
[Description claire et concise du bug]

## Steps to Reproduce
1. Aller sur '...'
2. Cliquer sur '...'
3. Exécuter la commande '...'
4. Voir l'erreur

## Expected Behavior
[Ce qui devrait se passer]

## Actual Behavior
[Ce qui se passe réellement]

## Environment
- OS: [e.g., Ubuntu 22.04]
- Docker version: [e.g., 24.0.5]
- Rocket.Chat version: [e.g., 6.5.0]
- Browser: [e.g., Chrome 120]

## Logs
```
[Coller les logs pertinents]
```

## Screenshots
[Si applicable]

## Additional Context
[Toute autre information utile]
```

## ✨ Proposer des Fonctionnalités

### Template de Feature Request

```markdown
## Feature Description
[Description claire de la fonctionnalité]

## Use Case
[Pourquoi cette fonctionnalité est utile]

## Proposed Solution
[Comment vous imaginez l'implémentation]

## Alternatives Considered
[Autres approches envisagées]

## Additional Context
[Mockups, exemples, références]
```

## 🧪 Tests

### Exécuter les Tests

```bash
# Tests Python
pytest tests/

# Tests TypeScript (à venir)
npm test

# Tests d'intégration
docker compose -f docker-compose.test.yml up --abort-on-container-exit
```

### Écrire des Tests

```python
# tests/test_bot.py
def test_dice_roll_basic():
    """Test basic dice rolling"""
    result = roll_dice(1, 20, 0)
    assert 1 <= result <= 20

def test_dice_roll_with_bonus():
    """Test dice rolling with bonus"""
    result = roll_dice(2, 6, 3)
    assert 5 <= result <= 15  # 2-12 + 3
```

## 📚 Documentation

### Où Documenter

- **README.md** : Vue d'ensemble et quick start
- **docs/** : Guides détaillés
- **Code comments** : Explications complexes
- **Docstrings** : API documentation

### Style de Documentation

```markdown
# Titre Principal

## Section

### Sous-section

**Gras** pour l'emphase
*Italique* pour les termes techniques

`code inline` pour les commandes

```bash
# Bloc de code avec syntaxe highlighting
docker compose up -d
```

> Note importante

⚠️ Avertissement
✅ Succès
❌ Erreur
🔴 Critique
```

## 🏆 Reconnaissance

Les contributeurs sont listés dans :
- Le fichier CONTRIBUTORS.md
- Les release notes
- Le README.md (contributeurs majeurs)

## 📞 Besoin d'Aide ?

- **Issues** : Pour les bugs et features
- **Discussions** : Pour les questions générales
- **Email** : [votre-email@example.com]

## 📄 Licence

En contribuant, vous acceptez que vos contributions soient sous la même licence que le projet.

---

**Merci de contribuer à GameMaster ! 🎮**
