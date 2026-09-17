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
        webhook: "https://discord.com/api/webhooks/1502968852516966461/6u33jekF1gGYeQvKHArZZSeFlp8ofTE4uIF-k6D4CjAY-1LdBsiIXESL-DvzjtWLusJX",
        daily_goal_hours: 4
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
                    if (data.daily_goal_hours !== undefined) current.daily_goal_hours = Number(data.daily_goal_hours);
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

        // AI Assisted coding metrics
        const aiCodingRes = querySQLite(`SELECT IFNULL(SUM(duration_seconds), 0) as total FROM erlik_heartbeats WHERE is_afk = 0 AND ${timeFilter} AND (app_name LIKE '%Antigravity%' OR app_name LIKE '%Cursor%' OR app_name LIKE '%ChatGPT%' OR app_name LIKE '%Claude%' OR app_name LIKE '%Hermes%');`);

        const categories = querySQLite(`SELECT category, SUM(duration_seconds) as total_sec FROM erlik_heartbeats WHERE is_afk = 0 AND ${timeFilter} GROUP BY category ORDER BY total_sec DESC;`);
        const apps = querySQLite(`SELECT app_name, SUM(duration_seconds) as total_sec FROM erlik_heartbeats WHERE is_afk = 0 AND ${timeFilter} GROUP BY app_name ORDER BY total_sec DESC LIMIT 10;`);
        
        // Projects breakdown with Git branches
        const projects = querySQLite(`SELECT IFNULL(project_name, 'Genel') as project, IFNULL(git_branch, '-') as branch, SUM(duration_seconds) as total_sec FROM erlik_heartbeats WHERE is_afk = 0 AND ${timeFilter} GROUP BY project ORDER BY total_sec DESC LIMIT 8;`);

        // Daily Activity Streak (Son 14 gün)
        const streakDays = querySQLite(`SELECT strftime('%Y-%m-%d', timestamp) as day, SUM(duration_seconds) as total_sec FROM erlik_heartbeats WHERE is_afk = 0 AND timestamp >= datetime('now', '-14 days') GROUP BY day ORDER BY day ASC;`);

        const recent = querySQLite(`SELECT timestamp, app_name, category, IFNULL(project_name, 'Genel') as project_name, IFNULL(git_branch, '-') as git_branch, window_title, duration_seconds FROM erlik_heartbeats WHERE ${timeFilter} ORDER BY id DESC LIMIT 25;`);
        const timeline = querySQLite(`SELECT ${timeGroup} as period, SUM(duration_seconds) as duration FROM erlik_heartbeats WHERE is_afk = 0 AND ${timeFilter} GROUP BY period ORDER BY period ASC;`);

        const cfg = loadConfig();
        const payload = {
            total_active_seconds: activeRes[0] ? activeRes[0].total : 0,
            total_afk_seconds: afkRes[0] ? afkRes[0].total : 0,
            total_ai_coding_seconds: aiCodingRes[0] ? aiCodingRes[0].total : 0,
            total_events: countRes[0] ? countRes[0].total : 0,
            daily_goal_hours: cfg.daily_goal_hours || 4,
            categories: categories,
            apps: apps,
            projects: projects,
            streak: streakDays,
            recent: recent,
            timeline: timeline
        };

        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify(payload));
    } else if (parsedUrl.pathname === '/api/export') {
        const events = querySQLite(`SELECT id, timestamp, app_name, bundle_id, category, IFNULL(project_name, 'Genel') as project, IFNULL(git_branch, '-') as git_branch, window_title, duration_seconds, is_afk FROM erlik_heartbeats ORDER BY id ASC;`);
        const exportData = {
            client: "erlik-macos-arm64",
            version: "3.0.0",
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
                            project: e.project,
                            branch: e.git_branch,
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
    console.log(`🐺 ERLİK Web UI v3.0 ready: http://localhost:${PORT}`);
});
