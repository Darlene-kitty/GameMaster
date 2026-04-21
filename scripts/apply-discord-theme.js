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
    API_URL = 'http://localhost:3000/api/v1'; 
}

const ADMIN_USERNAME = process.env.ADMIN_USERNAME || envVars.ADMIN_USERNAME || 'admin';
const ADMIN_PASS = process.env.ADMIN_PASS || envVars.ADMIN_PASS || 'Admin456!';

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
            // Accepter les certs auto-signés en local
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

        // 2. Read Custom CSS
        const cssPath = path.resolve(__dirname, '../rocketchat-app/discord-theme.css');
        const customCss = fs.readFileSync(cssPath, 'utf8');

        // 3. Inject Theme Custom CSS
        console.log('Injecting Custom CSS theme into settings...');
        const cssRes = await request('POST', '/settings/theme-custom-css', {
            value: customCss
        }, authHeaders);

        if (cssRes.status === 200) {
            console.log('✅ Custom CSS successfully applied.');
        } else {
            console.error('Failed to apply Custom CSS:', cssRes.data);
        }

        // 4. Update basic theme setting to allow mobile to pick up blurple slightly (Optional, but helps coherence)
        console.log('Updating Primary color configuration...');
        await request('POST', '/settings/theme-color-primary-background-color', {
            value: '#e67e22'
        }, authHeaders);
        
        // 5. Create RPG Roles (MJ, Guerrier, Archer, Joueur)
        console.log('Creating RPG Roles...');
        const rolesToCreate = ['MJ', 'Guerrier', 'Archer', 'Joueur'];
        for (const role of rolesToCreate) {
            try {
                await request('POST', '/roles.create', { name: role }, authHeaders);
                console.log(`Role ${role} ensured.`);
            } catch (err) {
                console.log(`Role ${role} might already exist or could not be created.`);
            }
        }

        // 6. Create RPG Channels (#combat, #lancer-des)
        console.log('Creating RPG Channels...');
        const channelsToCreate = ['combat', 'lancer-des'];
        for (const channelName of channelsToCreate) {
            const chanRes = await request('POST', '/channels.create', { name: channelName }, authHeaders);
            if (chanRes.status === 200) {
                console.log(`Channel #${channelName} created successfully.`);
            } else {
                console.log(`Channel #${channelName} might already exist.`);
            }
        }

        // 7. Activer le mode Développement pour que RC-Apps puisse upload le zip !
        console.log('Activating Apps Framework Development Mode...');
        await request('POST', '/settings/Apps_Framework_Development_Mode', {
            value: true
        }, authHeaders);

        console.log('Done! Refresh the browser to see the Eldritch Forge theme, new channels and roles.');
        
    } catch (e) {
        console.error('An error occurred during script execution:', e);
    }
}

applyTheme();
