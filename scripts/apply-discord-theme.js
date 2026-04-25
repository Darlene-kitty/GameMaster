const fs = require('fs');
const path = require('path');
const http = require('http');
const https = require('https');

// Read .env file to get variables
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

// Fallback logic inside Docker or local dev
if (process.env.RC_URL) {
    API_URL = `${process.env.RC_URL}/api/v1`;
} else if (API_URL.includes('localhost') && envVars.HTTP_PORT !== '80') {
    API_URL = `http://localhost:${envVars.HTTP_PORT}/api/v1`;
} else if (API_URL.includes('localhost')) {
    API_URL = 'http://rocketchat-1:3000/api/v1';
}

const ADMIN_USERNAME = process.env.ADMIN_USERNAME || envVars.ADMIN_USERNAME || 'admin';
const ADMIN_PASS = process.env.ADMIN_PASS || envVars.ADMIN_PASS;

console.log(`Connecting to Rocket.Chat via API: ${API_URL}`);

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
        if (body) req.write(JSON.stringify(body));
        req.end();
    });
}

async function applyTheme() {
    try {
        // 1. Login
        console.log(`Authenticating user: ${ADMIN_USERNAME}...`);
        const loginRes = await request('POST', '/login', {
            user: ADMIN_USERNAME,
            password: ADMIN_PASS
        });

        if (loginRes.status !== 200) {
            console.error('Authentication failed:', loginRes.data);
            process.exit(1);
        }

        const authHeaders = {
            'X-Auth-Token': loginRes.data.data.authToken,
            'X-User-Id': loginRes.data.data.userId
        };
        console.log('Authentication successful.');

        // 2. CSS global (thème Eldritch Forge)
        const mainCss   = fs.readFileSync(path.resolve(__dirname, '../rocketchat-app/discord-theme.css'), 'utf8');
        const loginCss  = fs.readFileSync(path.resolve(__dirname, '../rocketchat-app/login-styles.css'), 'utf8');
        const homeCss   = fs.readFileSync(path.resolve(__dirname, '../rocketchat-app/home-styles.css'), 'utf8');
        const combinedCss = `${mainCss}\n\n/* === LOGIN PAGE === */\n${loginCss}\n\n/* === HOME PAGE === */\n${homeCss}`;

        console.log('Injecting Custom CSS (theme + login + home)...');
        const cssRes = await request('POST', '/settings/theme-custom-css', {
            value: combinedCss
        }, authHeaders);
        console.log(cssRes.status === 200 ? '✅ CSS applied.' : '⚠️  CSS failed: ' + JSON.stringify(cssRes.data));

        // 3. Couleur primaire
        await request('POST', '/settings/theme-color-primary-background-color', { value: '#e67e22' }, authHeaders);
        console.log('✅ Primary color set.');

        // 4. Page de connexion — contenu HTML custom
        const loginHtml = fs.readFileSync(path.resolve(__dirname, '../rocketchat-app/login-page.html'), 'utf8');
        await request('POST', '/settings/Layout_Login_Terms', { value: loginHtml }, authHeaders);
        console.log('✅ Login page content injected.');

        // Nom du serveur affiché sur la page de login
        await request('POST', '/settings/Site_Name', { value: 'GameMaster' }, authHeaders);
        // Slogan sous le nom
        await request('POST', '/settings/Site_Url', { value: envVars.ROOT_URL || 'http://localhost' }, authHeaders);
        console.log('✅ Site name set.');

        // 5. Page d'accueil — corps HTML
        const homeHtml = fs.readFileSync(path.resolve(__dirname, '../rocketchat-app/home-page.html'), 'utf8');
        await request('POST', '/settings/Layout_Home_Body', { value: homeHtml }, authHeaders);
        // Activer la page d'accueil custom
        await request('POST', '/settings/Layout_Home_Title', { value: '🎮 GameMaster — Bienvenue dans l\'Archive' }, authHeaders);
        console.log('✅ Home page content injected.');

        // 6. Rôles RPG
        console.log('Creating RPG Roles...');
        const roles = ['MJ', 'Guerrier', 'Archer', 'Mage', 'Clerc', 'Voleur', 'Joueur'];
        for (const role of roles) {
            try {
                await request('POST', '/roles.create', { name: role }, authHeaders);
                console.log(`  ✅ Role "${role}" ensured.`);
            } catch (_) {
                console.log(`  ℹ️  Role "${role}" already exists.`);
            }
        }

        // 7. Canaux RPG
        console.log('Creating RPG Channels...');
        const channels = ['general', 'annonces', 'combat', 'lancer-des', 'roleplay', 'hors-jeu', 'aide'];
        for (const ch of channels) {
            const r = await request('POST', '/channels.create', { name: ch }, authHeaders);
            console.log(r.status === 200 ? `  ✅ #${ch} created.` : `  ℹ️  #${ch} already exists.`);
        }

        // 8. Activer le mode Dev pour les Apps
        await request('POST', '/settings/Apps_Framework_Development_Mode', { value: true }, authHeaders);
        console.log('✅ Apps Dev Mode enabled.');

        console.log('\n🎮 Done! Refresh your browser to see the full Eldritch Forge experience.');

    } catch (e) {
        console.error('An error occurred:', e);
    }
}

applyTheme();
