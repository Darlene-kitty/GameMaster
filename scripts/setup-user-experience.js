const fs = require('fs');
const path = require('path');
const http = require('http');
const https = require('https');

// Configuration de l'expérience utilisateur
const USER_EXPERIENCE_CONFIG = {
    // Canaux à créer
    channels: [
        { name: 'general', description: '💬 Discussion générale' },
        { name: 'annonces', description: '📢 Annonces importantes' },
        { name: 'combat', description: '⚔️ Scènes de combat' },
        { name: 'lancer-des', description: '🎲 Lancers de dés et tests' },
        { name: 'roleplay', description: '🎭 Roleplay et interactions' },
        { name: 'hors-jeu', description: '🍿 Discussions hors-jeu' },
        { name: 'aide', description: '❓ Questions et aide' }
    ],
    
    // Rôles à créer
    roles: [
        { name: 'MJ', description: 'Maître du Jeu' },
        { name: 'Guerrier', description: 'Classe Guerrier' },
        { name: 'Archer', description: 'Classe Archer' },
        { name: 'Mage', description: 'Classe Mage' },
        { name: 'Clerc', description: 'Classe Clerc' },
        { name: 'Voleur', description: 'Classe Voleur' },
        { name: 'Joueur', description: 'Joueur standard' }
    ],
    
    // Messages de bienvenue
    welcomeMessages: {
        general: `# 🎮 Bienvenue sur le serveur GameMaster !

Ce serveur utilise le bot GameMaster pour faciliter vos parties de jeu de rôle.

## 📚 Commandes Disponibles

\`\`\`
/gm help              # Afficher l'aide complète
/gm roll 2d20+4       # Lancer des dés
/gm poll Question ?   # Créer un sondage
/gm remind 10m Pause  # Programmer un rappel
/gm mod warn @user    # Modération
\`\`\`

## 📖 Canaux

- **#general** : Discussion générale
- **#annonces** : Annonces importantes (MJ uniquement)
- **#combat** : Scènes de combat et actions
- **#lancer-des** : Lancers de dés et tests de compétences
- **#roleplay** : Interactions et roleplay
- **#hors-jeu** : Discussions hors-jeu
- **#aide** : Questions et support

## 🎭 Rôles

Demandez au MJ de vous attribuer un rôle correspondant à votre classe !

Bon jeu ! 🎲`,
        
        combat: `⚔️ **Canal de Combat**

Utilisez ce canal pour :
- Déclarer vos actions de combat
- Lancer vos jets d'attaque : \`/gm roll 1d20+5\`
- Calculer les dégâts : \`/gm roll 2d6+3\`

**Exemple :**
\`\`\`
@Guerrier attaque le gobelin !
/gm roll 1d20+5
\`\`\``,
        
        'lancer-des': `🎲 **Canal de Lancers de Dés**

Testez vos compétences ici !

**Exemples :**
\`\`\`
/gm roll 1d20        # Test simple
/gm roll 2d6+3       # Dégâts d'arme
/gm roll 3d10        # Sorts puissants
/gm roll 1d100       # Pourcentage
\`\`\``
    }
};

// Read .env file
const envPath = path.resolve(__dirname, '../.env');
let envStr = '';
try {
    envStr = fs.readFileSync(envPath, 'utf8');
} catch (e) {
    console.error('Erreur lors de la lecture du fichier .env:', e.message);
    process.exit(1);
}

const envVars = {};
envStr.split(/\r?\n/).forEach(line => {
    const match = line.match(/^\s*([^#]+?)\s*=\s*(.*)\s*$/);
    if (match) {
        envVars[match[1]] = match[2];
    }
});

const ROOT_URL = envVars.ROOT_URL || 'http://localhost';
let API_URL = `${ROOT_URL}/api/v1`;

if (process.env.RC_URL) {
    API_URL = `${process.env.RC_URL}/api/v1`;
} else if (API_URL.includes('localhost') && envVars.HTTP_PORT !== '80') {
    API_URL = `http://localhost:${envVars.HTTP_PORT}/api/v1`;
} else if (API_URL.includes('localhost')) {
    API_URL = 'http://rocketchat-1:3000/api/v1'; 
}

const ADMIN_USERNAME = process.env.ADMIN_USERNAME || envVars.ADMIN_USERNAME || 'admin';
const ADMIN_PASS = process.env.ADMIN_PASS || envVars.ADMIN_PASS;

console.log('========================================');
console.log('🎮 GameMaster User Experience Setup');
console.log('========================================');
console.log(`API URL: ${API_URL}`);
console.log('');

async function request(method, endpoint, body = null, headers = {}) {
    return new Promise((resolve, reject) => {
        const url = new URL(`${API_URL}${endpoint}`);
        const isHttps = url.protocol === 'https:';
        const transport = isHttps ? https : http;
        const options = {
            hostname: url.hostname,
            port: url.port || (isHttps ? 443 : 80),
            path: url.pathname + url.search,
            method: method,
            rejectUnauthorized: false,
            headers: {
                'Content-Type': 'application/json',
                ...headers
            }
        };

        const req = transport.request(options, res => {
            let data = '';
            res.on('data', chunk => data += chunk);
            res.on('end', () => {
                try {
                    resolve({ status: res.statusCode, data: JSON.parse(data) });
                } catch (e) {
                    resolve({ status: res.statusCode, data: data });
                }
            });
        });

        req.on('error', e => reject(e));

        if (body) {
            req.write(JSON.stringify(body));
        }
        req.end();
    });
}

async function setupUserExperience() {
    try {
        // 1. Login
        console.log(`[1/5] Authenticating as ${ADMIN_USERNAME}...`);
        const loginRes = await request('POST', '/login', {
            user: ADMIN_USERNAME,
            password: ADMIN_PASS
        });

        if (loginRes.status !== 200) {
            console.error('❌ Authentication failed:', loginRes.data);
            process.exit(1);
        }

        const authHeaders = {
            'X-Auth-Token': loginRes.data.data.authToken,
            'X-User-Id': loginRes.data.data.userId
        };
        console.log('✅ Authentication successful\n');

        // 2. Create Roles
        console.log('[2/5] Creating RPG Roles...');
        for (const role of USER_EXPERIENCE_CONFIG.roles) {
            try {
                const roleRes = await request('POST', '/roles.create', { 
                    name: role.name,
                    description: role.description
                }, authHeaders);
                
                if (roleRes.status === 200) {
                    console.log(`  ✅ Role "${role.name}" created`);
                } else {
                    console.log(`  ℹ️  Role "${role.name}" already exists`);
                }
            } catch (err) {
                console.log(`  ℹ️  Role "${role.name}" already exists`);
            }
        }
        console.log('');

        // 3. Create Channels
        console.log('[3/5] Creating Channels...');
        const createdChannels = {};
        
        for (const channel of USER_EXPERIENCE_CONFIG.channels) {
            const chanRes = await request('POST', '/channels.create', { 
                name: channel.name 
            }, authHeaders);
            
            if (chanRes.status === 200) {
                console.log(`  ✅ Channel #${channel.name} created`);
                createdChannels[channel.name] = chanRes.data.channel._id;
                
                // Set channel description/topic
                if (channel.description) {
                    await request('POST', '/channels.setTopic', {
                        roomId: chanRes.data.channel._id,
                        topic: channel.description
                    }, authHeaders);
                }
            } else {
                console.log(`  ℹ️  Channel #${channel.name} already exists`);
            }
        }
        console.log('');

        // 4. Post Welcome Messages
        console.log('[4/5] Posting Welcome Messages...');
        for (const [channelName, message] of Object.entries(USER_EXPERIENCE_CONFIG.welcomeMessages)) {
            try {
                await request('POST', '/chat.postMessage', {
                    channel: `#${channelName}`,
                    text: message
                }, authHeaders);
                console.log(`  ✅ Welcome message posted to #${channelName}`);
            } catch (err) {
                console.log(`  ⚠️  Could not post to #${channelName}`);
            }
        }
        console.log('');

        // 5. Configure Settings
        console.log('[5/5] Configuring Settings...');
        
        // Allow user profile changes
        await request('POST', '/settings/Accounts_AllowUserProfileChange', {
            value: true
        }, authHeaders);
        console.log('  ✅ User profile changes enabled');
        
        // Allow user avatar changes
        await request('POST', '/settings/Accounts_AllowUserAvatarChange', {
            value: true
        }, authHeaders);
        console.log('  ✅ User avatar changes enabled');
        
        // Enable reactions
        await request('POST', '/settings/Message_AllowReactions', {
            value: true
        }, authHeaders);
        console.log('  ✅ Message reactions enabled');
        
        // Enable threads
        await request('POST', '/settings/Threads_enabled', {
            value: true
        }, authHeaders);
        console.log('  ✅ Threads enabled');
        
        console.log('');
        console.log('========================================');
        console.log('✅ User Experience Setup Complete!');
        console.log('========================================');
        console.log('');
        console.log('📋 Summary:');
        console.log(`  - ${USER_EXPERIENCE_CONFIG.roles.length} roles created`);
        console.log(`  - ${USER_EXPERIENCE_CONFIG.channels.length} channels created`);
        console.log(`  - Welcome messages posted`);
        console.log(`  - Settings configured`);
        console.log('');
        console.log('🎮 Your GameMaster server is ready!');
        console.log('');
        
    } catch (e) {
        console.error('❌ An error occurred:', e.message);
        process.exit(1);
    }
}

setupUserExperience();
