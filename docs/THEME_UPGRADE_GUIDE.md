# 🎨 Guide de Migration - Thème Amélioré

## Vue d'Ensemble

Le nouveau thème `discord-theme-enhanced.css` apporte des améliorations visuelles significatives tout en conservant l'identité "Eldritch Forge".

## 🆕 Nouvelles Fonctionnalités

### 1. **Scrollbar Personnalisée**
- Style Discord authentique
- Couleurs cohérentes avec le thème
- Effet hover subtil

### 2. **Indicateurs de Statut**
- Points colorés pour online/away/busy
- Effet lumineux sur le statut online
- Visibilité améliorée

### 3. **Messages du Bot Améliorés**
- Fond dégradé subtil
- Bordure gauche orange
- Animation de pulsation lumineuse
- Avatar avec effet glow

### 4. **Rôles Plus Visibles**
- Couleurs plus contrastées
- Text-shadow pour le rôle MJ
- Font-weight différencié par rôle

### 5. **Animations Fluides**
- Slide-in pour les nouveaux messages
- Hover effects sur les boutons
- Transitions douces partout

### 6. **Responsive Design**
- Optimisé pour mobile
- Scrollbar adaptée
- Padding réduit sur petits écrans

## 📊 Comparaison

| Fonctionnalité | Thème Original | Thème Amélioré |
|----------------|----------------|----------------|
| Scrollbar | Défaut navigateur | ✅ Personnalisée Discord |
| Statut utilisateur | Texte seul | ✅ Points colorés + glow |
| Messages bot | Standard | ✅ Fond dégradé + animation |
| Rôles | Couleurs basiques | ✅ Contraste amélioré + shadows |
| Animations | Basiques | ✅ Slide-in + hover effects |
| Responsive | Partiel | ✅ Complet |
| Code blocks | Standard | ✅ Style Discord |
| Tooltips | Standard | ✅ Style sombre |
| Modals | Standard | ✅ Style cohérent |

## 🚀 Migration

### Option 1 : Remplacement Direct (Recommandé)

```bash
# Sauvegarder l'ancien thème
cp rocketchat-app/discord-theme.css rocketchat-app/discord-theme.backup.css

# Remplacer par le nouveau
cp rocketchat-app/discord-theme-enhanced.css rocketchat-app/discord-theme.css

# Réappliquer le thème
docker compose restart rpg-setup

# Ou manuellement :
cd rocketchat-app && node ../scripts/apply-discord-theme.js
```

### Option 2 : Test Côte à Côte

```bash
# Modifier le script pour utiliser le thème amélioré
nano scripts/apply-discord-theme.js
```

Changer la ligne :
```javascript
const cssPath = path.resolve(__dirname, '../rocketchat-app/discord-theme.css');
```

En :
```javascript
const cssPath = path.resolve(__dirname, '../rocketchat-app/discord-theme-enhanced.css');
```

Puis :
```bash
cd rocketchat-app && node ../scripts/apply-discord-theme.js
```

### Option 3 : Fusion Manuelle

Si vous avez des personnalisations, fusionnez manuellement :

```bash
# Ouvrir les deux fichiers
code rocketchat-app/discord-theme.css rocketchat-app/discord-theme-enhanced.css
```

Copiez les sections que vous souhaitez du thème amélioré.

## 🧪 Tests Après Migration

### 1. Vérification Visuelle
- [ ] Scrollbar personnalisée visible
- [ ] Indicateurs de statut affichés
- [ ] Messages du bot avec fond dégradé
- [ ] Couleurs de rôles plus vives
- [ ] Animations fluides

### 2. Tests Fonctionnels
```bash
# Dans Rocket.Chat, tester :
/gm help
/gm roll 2d20+4
/gm poll Test | Oui | Non
```

Vérifier que :
- [ ] Les messages du bot ont l'effet glow
- [ ] Les attachments sont bien stylés
- [ ] Les code blocks sont lisibles
- [ ] Les mentions fonctionnent

### 3. Tests Responsive
- [ ] Ouvrir sur mobile (ou DevTools responsive mode)
- [ ] Vérifier que la scrollbar est adaptée
- [ ] Vérifier que les messages sont lisibles
- [ ] Tester les interactions tactiles

### 4. Tests de Performance
```bash
# Ouvrir DevTools > Performance
# Enregistrer pendant 5 secondes
# Vérifier qu'il n'y a pas de lag
```

- [ ] Animations fluides (60 FPS)
- [ ] Pas de repaint excessif
- [ ] Temps de chargement < 1s

## 🔧 Personnalisation

### Modifier les Couleurs

Éditez les variables CSS au début du fichier :

```css
:root {
    /* Changer la couleur d'accent */
    --rcx-color-primary-500: #e67e22; /* Orange par défaut */
    
    /* Exemples d'alternatives :
    --rcx-color-primary-500: #5865f2; /* Blurple Discord */
    --rcx-color-primary-500: #9b59b6; /* Violet */
    --rcx-color-primary-500: #e74c3c; /* Rouge */
    */
}
```

### Désactiver les Animations

Si les animations causent des problèmes de performance :

```css
/* Ajouter à la fin du fichier */
* {
    animation: none !important;
    transition: none !important;
}
```

### Modifier l'Intensité du Glow

```css
/* Réduire l'effet lumineux du bot */
@keyframes glow-pulse {
    0%, 100% { box-shadow: 0 0 2px rgba(230, 126, 34, 0.2); }
    50% { box-shadow: 0 0 5px rgba(230, 126, 34, 0.4); }
}
```

## 🐛 Dépannage

### Problème : Le thème ne s'applique pas

**Solution :**
```bash
# Vider le cache du navigateur
Ctrl + Shift + Delete (Chrome/Firefox)

# Ou forcer le rechargement
Ctrl + F5

# Vérifier que le CSS est bien injecté
docker compose logs rpg-setup | grep "Custom CSS"
```

### Problème : Animations saccadées

**Solution :**
```css
/* Désactiver les animations coûteuses */
.rcx-message {
    animation: none !important;
}

@keyframes glow-pulse {
    /* Réduire la fréquence */
    0%, 100% { box-shadow: none; }
}
```

### Problème : Scrollbar non visible

**Solution :**
```css
/* Forcer l'affichage de la scrollbar */
::-webkit-scrollbar {
    width: 16px !important;
    display: block !important;
}
```

### Problème : Couleurs de rôles non appliquées

**Cause :** Les sélecteurs CSS utilisent l'attribut `title` qui doit correspondre exactement au nom du rôle.

**Solution :**
```bash
# Vérifier les noms de rôles dans Rocket.Chat
# Administration > Permissions > Roles

# Ajuster les sélecteurs CSS si nécessaire
.rcx-message-header__name[title="VotreNomDeRole"] {
    color: #ff6b6b !important;
}
```

## 📈 Améliorations Futures

### Roadmap
- [ ] Mode clair (light theme)
- [ ] Thèmes alternatifs (cyberpunk, fantasy, sci-fi)
- [ ] Personnalisation par utilisateur
- [ ] Effets sonores (optionnel)
- [ ] Particules animées (background)
- [ ] Thème saisonnier (Halloween, Noël, etc.)

### Contributions

Pour proposer des améliorations :
1. Créer une branche : `git checkout -b theme/nouvelle-feature`
2. Modifier `discord-theme-enhanced.css`
3. Tester localement
4. Créer une pull request

## 📚 Ressources

- [Rocket.Chat Theming Guide](https://docs.rocket.chat/use-rocket.chat/workspace-administration/settings/layout)
- [Discord Design Guidelines](https://discord.com/branding)
- [CSS Variables MDN](https://developer.mozilla.org/en-US/docs/Web/CSS/Using_CSS_custom_properties)
- [WCAG Contrast Checker](https://webaim.org/resources/contrastchecker/)

## ✅ Checklist de Migration

- [ ] Sauvegarder l'ancien thème
- [ ] Copier le nouveau thème
- [ ] Réappliquer via script
- [ ] Vider le cache navigateur
- [ ] Tester visuellement
- [ ] Tester fonctionnellement
- [ ] Tester sur mobile
- [ ] Vérifier les performances
- [ ] Documenter les personnalisations

---

**Note :** Le thème amélioré est rétrocompatible. Vous pouvez revenir à l'ancien thème à tout moment en restaurant le backup.
