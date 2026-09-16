const http = require('http');
const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const PORT = 5757;
const DB_PATH = '/Users/halil/code/erlik/erlik.db';
const HTML_PATH = '/Users/halil/code/erlik/index.html';
const CONFIG_PATH = '/Users/halil/code/erlik/config.json';

// Config Helper
function loadConfig() {
    try {
        if (fs.existsSync(CONFIG_PATH)) {
            return JSON.parse(fs.readFileSync(CONFIG_PATH, 'utf8'));
        }
    } catch(e) {}
    return {
        email: "halil@ertekin.me",
        webhook: "https://discord.com/api/webhooks/1502968852516966461/6u33jekF1gGYeQvKHArZZSeFlp8ofTE4uIF-k6D4CjAY-1LdBsiIXESL-DvzjtWLusJX"
    };
}

function saveConfig(cfg) {
    fs.writeFileSync(CONFIG_PATH, JSON.stringify(cfg, null, 2), 'utf8');
}

function querySQLite(sql) {
    try {
        const out = execSync(`sqlite3 -json "${DB_PATH}" "${sql.replace(/"/g, '\\"')}"`, { encoding: 'utf-8' });
        return JSON.parse(out || '[]');
    } catch (e) {
        return [];
    }
}

const server = http.createServer((req, res) => {
    const parsedUrl = new URL(req.url, `http://${req.headers.host}`);
    
    if (parsedUrl.pathname === '/' || parsedUrl.pathname === '/index.html') {
        res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
        fs.createReadStream(HTML_PATH).pipe(res);
    } else if (parsedUrl.pathname === '/assets/erlik_logo.jpg') {
        const logoPath = '/Users/halil/code/erlik/assets/erlik_logo.jpg';
        if (fs.existsSync(logoPath)) {
            res.writeHead(200, { 'Content-Type': 'image/jpeg' });
            fs.createReadStream(logoPath).pipe(res);
        } else {
            res.writeHead(404);
            res.end();
        }
    } else if (parsedUrl.pathname === '/api/settings') {
        if (req.method === 'GET') {
            res.writeHead(200, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify(loadConfig()));
        } else if (req.method === 'POST') {
            let body = '';
            req.on('data', chunk => { body += chunk; });
            req.on('end', () => {
                try {
                    const data = JSON.parse(body || '{}');
                    const current = loadConfig();
                    if (data.email !== undefined) current.email = data.email.trim();
                    if (data.webhook !== undefined) current.webhook = data.webhook.trim();
                    saveConfig(current);
                    res.writeHead(200, { 'Content-Type': 'application/json' });
                    res.end(JSON.stringify({ success: true, config: current }));
                } catch(e) {
                    res.writeHead(400, { 'Content-Type': 'application/json' });
                    res.end(JSON.stringify({ error: e.message }));
                }
            });
        }
    } else if (parsedUrl.pathname === '/api/stats') {
        const range = parsedUrl.searchParams.get('range') || 'day';
        let timeFilter = "timestamp >= datetime('now', '-1 day')";
        let timeGroup = "strftime('%H:00', timestamp)";
        
        if (range === 'week') {
            timeFilter = "timestamp >= datetime('now', '-7 days')";
            timeGroup = "strftime('%Y-%m-%d', timestamp)";
        } else if (range === 'month') {
            timeFilter = "timestamp >= datetime('now', '-30 days')";
            timeGroup = "strftime('%Y-%m-%d', timestamp)";
        }

        const activeRes = querySQLite(`SELECT IFNULL(SUM(duration_seconds), 0) as total FROM erlik_heartbeats WHERE is_afk = 0 AND ${timeFilter};`);
        const afkRes = querySQLite(`SELECT IFNULL(SUM(duration_seconds), 0) as total FROM erlik_heartbeats WHERE is_afk = 1 AND ${timeFilter};`);
        const countRes = querySQLite(`SELECT COUNT(*) as total FROM erlik_heartbeats WHERE ${timeFilter};`);

        const categories = querySQLite(`SELECT category, SUM(duration_seconds) as total_sec FROM erlik_heartbeats WHERE is_afk = 0 AND ${timeFilter} GROUP BY category ORDER BY total_sec DESC;`);
        const apps = querySQLite(`SELECT app_name, SUM(duration_seconds) as total_sec FROM erlik_heartbeats WHERE is_afk = 0 AND ${timeFilter} GROUP BY app_name ORDER BY total_sec DESC LIMIT 10;`);
        const recent = querySQLite(`SELECT timestamp, app_name, category, window_title, duration_seconds FROM erlik_heartbeats WHERE ${timeFilter} ORDER BY id DESC LIMIT 25;`);
        const timeline = querySQLite(`SELECT ${timeGroup} as period, SUM(duration_seconds) as duration FROM erlik_heartbeats WHERE is_afk = 0 AND ${timeFilter} GROUP BY period ORDER BY period ASC;`);

        const payload = {
            total_active_seconds: activeRes[0] ? activeRes[0].total : 0,
            total_afk_seconds: afkRes[0] ? afkRes[0].total : 0,
            total_events: countRes[0] ? countRes[0].total : 0,
            categories: categories,
            apps: apps,
            recent: recent,
            timeline: timeline
        };

        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify(payload));
    } else if (parsedUrl.pathname === '/api/export') {
        // ActivityWatch standard compatible bucket export
        const events = querySQLite(`SELECT id, timestamp, app_name, bundle_id, category, window_title, duration_seconds, is_afk FROM erlik_heartbeats ORDER BY id ASC;`);
        const exportData = {
            client: "erlik-macos-arm64",
            version: "2.1.0",
            exported_at: new Date().toISOString(),
            buckets: {
                "erlik-watcher-window": {
                    name: "Window & Focus Activity",
                    type: "currentwindow",
                    events: events.map(e => ({
                        id: e.id,
                        timestamp: e.timestamp,
                        duration: e.duration_seconds,
                        data: {
                            app: e.app_name,
                            bundle_id: e.bundle_id,
                            title: e.window_title,
                            category: e.category,
                            is_afk: Boolean(e.is_afk)
                        }
                    }))
                }
            }
        };
        res.writeHead(200, {
            'Content-Type': 'application/json',
            'Content-Disposition': 'attachment; filename="erlik-activity-data.json"'
        });
        res.end(JSON.stringify(exportData, null, 2));
    } else if (parsedUrl.pathname === '/api/send-email' && req.method === 'POST') {
        let body = '';
        req.on('data', chunk => { body += chunk; });
        req.on('end', () => {
            try {
                let payload = {};
                try { payload = JSON.parse(body || '{}'); } catch(e) {}
                
                // Update config if provided
                const cfg = loadConfig();
                if (payload.email) cfg.email = payload.email.trim();
                if (payload.webhook) cfg.webhook = payload.webhook.trim();
                saveConfig(cfg);

                execSync(`USER_EMAIL="${cfg.email}" USER_WEBHOOK="${cfg.webhook}" /Users/halil/code/erlik/erlik_mailer.sh`, { encoding: 'utf-8' });
                res.writeHead(200, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({ success: true, message: `Rapor ${cfg.email} ve Webhook'a başarıyla iletildi!` }));
            } catch(e) {
                res.writeHead(500, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({ success: false, error: e.message }));
            }
        });
    } else {
        res.writeHead(404);
        res.end('Not Found');
    }
});

server.listen(PORT, '127.0.0.1', () => {
    console.log(`🐺 ERLİK Web UI v2.1 ready: http://localhost:${PORT}`);
});
