const fs = require('fs');
const path = require('path');
const http = require('http');
const https = require('https');

// ─── Config ───────────────────────────────────────────────────────────────────

const envPath = path.resolve(__dirname, '../.env');
let envStr = '';
try {
    envStr = fs.readFileSync(envPath, 'utf8');
} catch (e) {
    console.error('Erreur lecture .env:', e.message);
    process.exit(1);
}

const envVars = {};
envStr.split(/\r?\n/).forEach(line => {
    const match = line.match(/^\s*([^#]+?)\s*=\s*(.*)\s*$/);
    if (match) envVars[match[1].trim()] = match[2].trim();
});

let API_URL = process.env.RC_URL
    ? `${process.env.RC_URL}/api/v1`
    : `${envVars.ROOT_URL || 'http://localhost'}/api/v1`;

// URL de base sans /api/v1 pour Grafana
const BASE_URL = API_URL.replace('/api/v1', '');

const ADMIN_USERNAME  = process.env.ADMIN_USERNAME  || envVars.ADMIN_USERNAME  || 'admin';
const ADMIN_PASS      = process.env.ADMIN_PASS      || envVars.ADMIN_PASS      || 'Admin456!';
const GRAFANA_USER    = envVars.GRAFANA_USER    || 'admin';
const GRAFANA_PASS    = envVars.GRAFANA_PASS    || 'Admin789!';
const GRAFANA_PORT    = envVars.GRAFANA_PORT    || '3001';

console.log(`Connecting to Rocket.Chat via API: ${API_URL}`);

// ─── HTTP helper (Rocket.Chat) ────────────────────────────────────────────────

async function request(method, endpoint, body = null, headers = {}) {
    return new Promise((resolve, reject) => {
        const url       = new URL(`${API_URL}${endpoint}`);
        const isHttps   = url.protocol === 'https:';
        const transport = isHttps ? https : http;

        const options = {
            hostname:           url.hostname,
            port:               url.port || (isHttps ? 443 : 80),
            path:               url.pathname + url.search,
            method,
            rejectUnauthorized: false,
            headers: { 'Content-Type': 'application/json', ...headers },
        };

        const req = transport.request(options, res => {
            let data = '';
            res.on('data', chunk => data += chunk);
            res.on('end', () => {
                try { resolve({ status: res.statusCode, data: JSON.parse(data) }); }
                catch (e) { resolve({ status: res.statusCode, data }); }
            });
        });

        req.on('error', reject);
        if (body) req.write(JSON.stringify(body));
        req.end();
    });
}

// ─── HTTP helper (Grafana) ────────────────────────────────────────────────────

async function grafanaRequest(method, endpoint, body = null) {
    return new Promise((resolve, reject) => {
        const hostname = 'localhost';
        const port     = parseInt(GRAFANA_PORT, 10);
        const auth     = Buffer.from(`${GRAFANA_USER}:${GRAFANA_PASS}`).toString('base64');

        const options = {
            hostname,
            port,
            path: `/api${endpoint}`,
            method,
            headers: {
                'Content-Type':  'application/json',
                'Authorization': `Basic ${auth}`,
            },
        };

        const req = http.request(options, res => {
            let data = '';
            res.on('data', chunk => data += chunk);
            res.on('end', () => {
                try { resolve({ status: res.statusCode, data: JSON.parse(data) }); }
                catch (e) { resolve({ status: res.statusCode, data }); }
            });
        });

        req.on('error', reject);
        if (body) req.write(JSON.stringify(body));
        req.end();
    });
}

// ─── Helpers Rocket.Chat ──────────────────────────────────────────────────────

async function setSetting(key, value, auth) {
    const res = await request('POST', `/settings/${key}`, { value }, auth);
    if (res.status === 200 && res.data.success) {
        console.log(`  ✅ ${key} set.`);
    } else {
        console.log(`  ⚠️  ${key} failed:`, JSON.stringify(res.data).slice(0, 120));
    }
}

async function createChannel(name, auth) {
    const res = await request('POST', '/channels.create', { name }, auth);
    if (res.status === 200 && res.data.success) {
        console.log(`  ✅ #${name} created.`);
        return res.data.channel._id;
    } else {
        // Récupérer l'ID si déjà existant
        const info = await request('GET', `/channels.info?roomName=${name}`, null, auth);
        if (info.status === 200 && info.data.channel) {
            console.log(`  ℹ️  #${name} already exists.`);
            return info.data.channel._id;
        }
        return null;
    }
}

async function createRole(name, auth) {
    const res = await request('POST', '/roles.create', { name }, auth);
    if (res.status === 200 && res.data.success) {
        console.log(`  ✅ Role "${name}" created.`);
    } else {
        console.log(`  ℹ️  Role "${name}" already exists.`);
    }
}

async function createUser({ name, username, email, password, roles }, auth) {
    const res = await request('POST', '/users.create', {
        name, username, email, password,
        roles, verified: true, joinDefaultChannels: true,
    }, auth);
    if (res.status === 200 && res.data.success) {
        console.log(`  ✅ User @${username} created.`);
    } else {
        console.log(`  ℹ️  User @${username} already exists or failed.`);
    }
}

async function sendMessage(roomId, text, auth) {
    const res = await request('POST', '/chat.postMessage', { roomId, text }, auth);
    if (res.status === 200 && res.data.success) {
        console.log(`  ✅ Message sent to ${roomId}.`);
    } else {
        console.log(`  ⚠️  Message failed:`, JSON.stringify(res.data).slice(0, 80));
    }
}

// ─── Helpers Grafana ──────────────────────────────────────────────────────────

async function setupGrafana() {
    console.log('\n── Configuring Grafana...');

    // 1. Ajouter Prometheus comme datasource
    const dsRes = await grafanaRequest('POST', '/datasources', {
        name:      'Prometheus',
        type:      'prometheus',
        url:       'http://prometheus:9090',
        access:    'proxy',
        isDefault: true,
    });

    if (dsRes.status === 200 || dsRes.status === 409) {
        console.log('  ✅ Prometheus datasource configured.');
    } else {
        console.log('  ⚠️  Datasource failed:', JSON.stringify(dsRes.data).slice(0, 100));
    }

    // 2. Importer dashboard Docker (ID 193)
    const importRes = await grafanaRequest('POST', '/dashboards/import', {
        dashboardId: 193,
        overwrite:   true,
        inputs: [{
            name:     'DS_PROMETHEUS',
            type:     'datasource',
            pluginId: 'prometheus',
            value:    'Prometheus',
        }],
        folderId: 0,
    });

    if (importRes.status === 200) {
        console.log('  ✅ Dashboard "Docker monitoring" (ID 193) imported.');
    } else {
        console.log('  ⚠️  Dashboard import failed:', JSON.stringify(importRes.data).slice(0, 100));
    }
}

// ─── Messages de démo ─────────────────────────────────────────────────────────

const DEMO_MESSAGES = {
    'annonces': [
        '🏰 **Bienvenue sur GameMaster TPS !**\nCette plateforme est dédiée aux sessions de jeu de rôle en ligne.\n\n> Utilisez `/gm help` pour voir toutes les commandes disponibles.',
        '📋 **Règles du serveur :**\n1. Respectez les autres joueurs\n2. Restez dans le thème de la session\n3. Le MJ a le dernier mot',
    ],
    'combat': [
        '⚔️ *Le dragon Malachar rugit et se prépare à attaquer !*\n\nMJ : "Tous les joueurs, lancez votre initiative !"',
        '🎲 Guerrier Kael lance son initiative : `/gm roll 1d20+3`',
        '🎲 Résultat : **17** — Kael agit en premier !',
        '🗡️ *Kael charge le dragon, son épée flamboyante tranche l\'air !*\n`/gm roll 2d6+5` → **14 dégâts** !',
    ],
    'lancer-des': [
        '🎲 Test de perception : `/gm roll 1d20+2` → **18** — Succès critique !',
        '🎲 Jet de sauvegarde contre la magie : `/gm roll 1d20` → **7** — Échec...',
        '🎲 Dégâts de boule de feu : `/gm roll 8d6` → **31 dégâts** de feu !',
    ],
    'roleplay': [
        '🧙 *Lyra la Mage s\'approche de l\'aubergiste, sa robe étoilée bruissant doucement.*\n"Bonsoir, auriez-vous une chambre pour cette nuit ?"',
        '🍺 *L\'aubergiste, un homme corpulent aux joues rouges, sourit chaleureusement.*\n"Bien sûr, mademoiselle ! 5 pièces d\'or la nuit, petit-déjeuner inclus !"',
        '🧙 *Lyra pose délicatement les pièces sur le comptoir.*\n"Parfait. Et... avez-vous entendu parler de la tour abandonnée au nord ?"',
    ],
    'hors-jeu': [
        '👋 Prochaine session : **Samedi 20h** — Soyez à l\'heure !',
        '📅 `/gm poll Quelle heure pour la prochaine session ? | 18h | 20h | 21h`',
    ],
    'aide': [
        '📖 **Commandes GameMaster Bot :**\n```\n/gm help              → Afficher l\'aide\n/gm roll 2d20+4       → Lancer des dés\n/gm poll Q? | A | B   → Créer un sondage\n/gm remind 10m Pause  → Rappel\n/gm mod warn @user    → Modération\n```',
    ],
};

// ─── Main ─────────────────────────────────────────────────────────────────────

async function setup() {
    try {
        // 1. Login Rocket.Chat
        console.log(`\nAuthenticating user: ${ADMIN_USERNAME}...`);
        const loginRes = await request('POST', '/login', {
            user: ADMIN_USERNAME,
            password: ADMIN_PASS,
        });

        if (loginRes.status !== 200 || !loginRes.data.data) {
            console.error('Authentication failed:', loginRes.data);
            process.exit(1);
        }

        const auth = {
            'X-Auth-Token': loginRes.data.data.authToken,
            'X-User-Id':    loginRes.data.data.userId,
        };
        console.log('Authentication successful.\n');

        // 2. CSS
        console.log('── Applying theme CSS...');
        const cssPath = path.resolve(__dirname, '../rocketchat-app/discord-theme.css');
        const css     = fs.readFileSync(cssPath, 'utf8');
        await setSetting('theme-custom-css', css, auth);

        // 3. Settings visuels
        console.log('\n── Applying visual settings...');
        await setSetting('Site_Name',                       'GameMaster TPS', auth);
        await setSetting('Layout_Home_Title',               'GameMaster TPS', auth);
        await setSetting('Apps_Framework_Development_Mode', true,             auth);

        // 4. Rôles RPG
        console.log('\n── Creating RPG roles...');
        for (const role of ['MJ', 'Guerrier', 'Archer', 'Mage', 'Clerc', 'Voleur', 'Joueur']) {
            await createRole(role, auth);
        }

        // 5. Canaux RPG + messages de démo
        console.log('\n── Creating RPG channels & demo messages...');
        const channelNames = ['general', 'annonces', 'combat', 'lancer-des', 'roleplay', 'hors-jeu', 'aide'];
        for (const ch of channelNames) {
            const roomId = await createChannel(ch, auth);
            if (roomId && DEMO_MESSAGES[ch]) {
                for (const msg of DEMO_MESSAGES[ch]) {
                    await sendMessage(roomId, msg, auth);
                }
            }
        }

        // 6. Utilisateurs de démo
        console.log('\n── Creating demo users...');
        const users = [
            { name: 'Maître du Jeu', username: 'mj',         email: 'mj@gamemaster.local',        password: 'MJ_Pass123!',     roles: ['admin'] },
            { name: 'Professeur',    username: 'professeur',  email: 'prof@gamemaster.local',      password: 'Prof_Demo123!',   roles: ['admin'] },
            { name: 'Guerrier Kael', username: 'guerrier',    email: 'guerrier@gamemaster.local',  password: 'Player_Pass123!', roles: ['user']  },
            { name: 'Mage Lyra',     username: 'mage',        email: 'mage@gamemaster.local',      password: 'Player_Pass123!', roles: ['user']  },
            { name: 'Archer Finn',   username: 'archer',      email: 'archer@gamemaster.local',    password: 'Player_Pass123!', roles: ['user']  },
            { name: 'Clerc Sera',    username: 'clerc',       email: 'clerc@gamemaster.local',     password: 'Player_Pass123!', roles: ['user']  },
        ];
        for (const user of users) await createUser(user, auth);

        // 7. Activer le bot GameMaster
        console.log('\n── Activating GameMaster bot...');
        const appsRes = await request('GET', '/apps', null, auth);
        if (appsRes.status === 200 && appsRes.data.apps) {
            const gmApp = appsRes.data.apps.find(a =>
                a.name && a.name.toLowerCase().includes('gamemaster')
            );
            if (gmApp) {
                const activateRes = await request('POST', `/apps/${gmApp.id}/status`,
                    { status: 'auto_enabled' }, auth);
                if (activateRes.status === 200) {
                    console.log(`  ✅ GameMaster bot activated (id: ${gmApp.id}).`);
                } else {
                    console.log(`  ⚠️  Could not activate:`, JSON.stringify(activateRes.data).slice(0, 100));
                }
            } else {
                console.log('  ⚠️  GameMaster app not found — deploy the zip first.');
            }
        }

        // 8. Grafana
        await setupGrafana();

        // 9. Résumé
        console.log('\n════════════════════════════════════════');
        console.log('🎮 SETUP COMPLETE — GameMaster TPS Ready');
        console.log('════════════════════════════════════════');
        console.log(`\n🌐 Rocket.Chat : https://54.166.237.42`);
        console.log(`📊 Grafana     : http://54.166.237.42:${GRAFANA_PORT}`);
        console.log(`📋 Dozzle      : http://54.166.237.42:9999`);
        console.log('\n👤 Demo users:');
        console.log('   admin      / Admin456!     (super admin)');
        console.log('   mj         / MJ_Pass123!   (game master)');
        console.log('   professeur / Prof_Demo123! (compte démo prof)');
        console.log('   guerrier   / Player_Pass123!');
        console.log('   mage       / Player_Pass123!');
        console.log('   archer     / Player_Pass123!');
        console.log('   clerc      / Player_Pass123!');
        console.log('\n🎲 Test bot: /gm roll 2d20+4  in #combat\n');

    } catch (e) {
        console.error('Error during setup:', e);
    }
}

setup();
