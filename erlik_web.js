const http = require('http');
const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const PORT = 5757;
const DB_PATH = '/Users/halil/code/erlik/erlik.db';

const HTML = `<!DOCTYPE html>
<html lang="tr" class="dark">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ERLİK — Mac Activity & Focus Intelligence</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=JetBrains+Mono:wght@400;600&display=swap" rel="stylesheet">
    <script>
        tailwind.config = {
            darkMode: 'class',
            theme: {
                extend: {
                    fontFamily: {
                        sans: ['"Plus Jakarta Sans"', 'sans-serif'],
                        mono: ['"JetBrains Mono"', 'monospace'],
                    }
                }
            }
        }
    </script>
    <style>
        body { font-family: 'Plus Jakarta Sans', sans-serif; background-color: #080C14; }
        .glass { background: rgba(15, 23, 42, 0.7); backdrop-filter: blur(16px); }
    </style>
</head>
<body class="text-slate-100 min-h-screen p-4 md:p-8 antialiased selection:bg-sky-500 selection:text-white">
    <div class="max-w-6xl mx-auto space-y-6">
        <!-- Header -->
        <header class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 border-b border-slate-800/80 pb-6">
            <div class="flex items-center gap-4">
                <img src="/assets/erlik_logo.jpg" alt="ERLIK Logo" class="w-12 h-12 rounded-2xl shadow-lg shadow-sky-500/20 border border-sky-500/30 object-cover">
                <div>
                    <h1 class="text-2xl font-bold tracking-tight bg-gradient-to-r from-sky-400 via-indigo-300 to-rose-400 bg-clip-text text-transparent">
                        ERLİK
                    </h1>
                    <p class="text-xs text-slate-400 font-medium tracking-wide flex items-center gap-2">
                        <span class="inline-block w-2 h-2 rounded-full bg-emerald-400 animate-pulse"></span>
                        Native ARM64 Activity & Focus Intelligence
                    </p>
                </div>
            </div>
            <div class="flex items-center gap-3">
                <!-- Time Range Filter -->
                <div class="flex bg-slate-900 border border-slate-800 rounded-xl p-1 text-xs">
                    <button onclick="setTimeRange('day')" id="btn-day" class="px-3 py-1.5 rounded-lg font-medium transition bg-sky-500 text-white">Günlük</button>
                    <button onclick="setTimeRange('week')" id="btn-week" class="px-3 py-1.5 rounded-lg font-medium transition text-slate-400 hover:text-slate-200">Haftalık</button>
                    <button onclick="setTimeRange('month')" id="btn-month" class="px-3 py-1.5 rounded-lg font-medium transition text-slate-400 hover:text-slate-200">Aylık</button>
                </div>
                <button onclick="sendWeeklyEmail()" id="btnEmail" class="px-3 py-1.5 bg-indigo-600/20 hover:bg-indigo-600/30 text-indigo-300 border border-indigo-500/30 rounded-xl text-xs font-semibold tracking-wide transition flex items-center gap-1.5">
                    <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"></path></svg>
                    Mail Raporu
                </button>
            </div>
        </header>

        <!-- KPI Cards -->
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
            <div class="glass p-5 rounded-2xl border border-slate-800/80">
                <div class="text-slate-400 text-xs font-semibold uppercase tracking-wider">Aktif Odaklanma</div>
                <div id="metricTotal" class="text-3xl font-bold text-white mt-2 font-mono">0 dk</div>
                <div class="text-xs text-emerald-400 mt-2 flex items-center gap-1">
                    <span class="w-1.5 h-1.5 rounded-full bg-emerald-400"></span> Gerçek Ekran Süresi
                </div>
            </div>
            <div class="glass p-5 rounded-2xl border border-slate-800/80">
                <div class="text-slate-400 text-xs font-semibold uppercase tracking-wider">Ana Uygulama</div>
                <div id="metricTopApp" class="text-2xl font-bold text-sky-400 mt-2 truncate">-</div>
                <div id="metricTopAppTime" class="text-xs text-slate-400 mt-2 font-mono">0 sn</div>
            </div>
            <div class="glass p-5 rounded-2xl border border-slate-800/80">
                <div class="text-slate-400 text-xs font-semibold uppercase tracking-wider">Boşta (AFK) Süresi</div>
                <div id="metricAfk" class="text-3xl font-bold text-amber-400 mt-2 font-mono">0 dk</div>
                <div class="text-xs text-slate-500 mt-2">Donanım IOHID Sayacı</div>
            </div>
            <div class="glass p-5 rounded-2xl border border-slate-800/80">
                <div class="text-slate-400 text-xs font-semibold uppercase tracking-wider">Toplam Nabız (Events)</div>
                <div id="metricSessions" class="text-3xl font-bold text-indigo-400 mt-2 font-mono">0</div>
                <div class="text-xs text-slate-500 mt-2">Kalıcı SQLite Kayıtları</div>
            </div>
        </div>

        <!-- Charts Grid -->
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
            <!-- Timeline Chart -->
            <div class="glass p-5 rounded-2xl border border-slate-800/80 lg:col-span-2 flex flex-col justify-between">
                <div class="flex justify-between items-center mb-4">
                    <h2 class="text-sm font-semibold text-slate-200">Zaman Boyunca Odak Dağılımı</h2>
                    <span id="rangeLabel" class="text-xs font-mono text-slate-400">Son 24 Saat</span>
                </div>
                <div class="h-64 relative">
                    <canvas id="timelineChart"></canvas>
                </div>
            </div>

            <!-- Category Donut Chart -->
            <div class="glass p-5 rounded-2xl border border-slate-800/80 flex flex-col justify-between">
                <h2 class="text-sm font-semibold text-slate-200 mb-4">Kategori Dağılımı</h2>
                <div class="h-64 relative flex items-center justify-center">
                    <canvas id="categoryChart"></canvas>
                </div>
            </div>
        </div>

        <!-- App Breakdown & Live Feed -->
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
            <!-- App Breakdown -->
            <div class="glass p-6 rounded-2xl border border-slate-800/80 space-y-4">
                <h2 class="text-sm font-semibold text-slate-200">Uygulama Kullanım Sıralaması</h2>
                <div id="appContainer" class="space-y-3">
                    <p class="text-slate-500 text-xs">Yükleniyor...</p>
                </div>
            </div>

            <!-- Live Window Activity -->
            <div class="glass p-6 rounded-2xl border border-slate-800/80 lg:col-span-2 space-y-4">
                <h2 class="text-sm font-semibold text-slate-200">Son Pencere Başlıkları & Detaylar</h2>
                <div class="overflow-x-auto">
                    <table class="w-full text-left text-xs text-slate-300">
                        <thead class="bg-slate-800/60 uppercase text-[10px] font-semibold text-slate-400 border-b border-slate-700/60">
                            <tr>
                                <th class="py-2.5 px-3">Zaman</th>
                                <th class="py-2.5 px-3">Uygulama</th>
                                <th class="py-2.5 px-3">Pencere Başlığı</th>
                                <th class="py-2.5 px-3 text-right">Süre</th>
                            </tr>
                        </thead>
                        <tbody id="recentFeed" class="divide-y divide-slate-800">
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <script>
        let currentRange = 'day';
        let timelineChart = null;
        let categoryChart = null;

        function setTimeRange(range) {
            currentRange = range;
            ['day', 'week', 'month'].forEach(r => {
                const btn = document.getElementById('btn-' + r);
                if (r === range) {
                    btn.className = 'px-3 py-1.5 rounded-lg font-medium transition bg-sky-500 text-white';
                } else {
                    btn.className = 'px-3 py-1.5 rounded-lg font-medium transition text-slate-400 hover:text-slate-200';
                }
            });
            document.getElementById('rangeLabel').innerText = range === 'day' ? 'Son 24 Saat' : (range === 'week' ? 'Son 7 Gün' : 'Son 30 Gün');
            fetchStats();
        }

        function fmtDuration(secs) {
            if (secs < 60) return secs + ' sn';
            const mins = Math.floor(secs / 60);
            if (mins < 60) return mins + ' dk';
            const hrs = (mins / 60).toFixed(1);
            return hrs + ' sa';
        }

        async function sendWeeklyEmail() {
            const btn = document.getElementById('btnEmail');
            btn.innerText = 'Gönderiliyor...';
            try {
                const res = await fetch('/api/send-email', { method: 'POST' });
                const d = await res.json();
                alert(d.message || 'Rapor gönderildi!');
            } catch(e) {
                alert('E-posta servisi tetiklenirken hata oluştu.');
            } finally {
                btn.innerHTML = '<svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"></path></svg> Mail Raporu';
            }
        }

        async function fetchStats() {
            try {
                const res = await fetch('/api/stats?range=' + currentRange);
                const data = await res.json();

                document.getElementById('metricTotal').innerText = fmtDuration(data.total_active_seconds);
                document.getElementById('metricAfk').innerText = fmtDuration(data.total_afk_seconds);
                document.getElementById('metricSessions').innerText = data.total_events || 0;
                
                if (data.apps && data.apps.length > 0) {
                    document.getElementById('metricTopApp').innerText = data.apps[0].app_name;
                    document.getElementById('metricTopAppTime').innerText = fmtDuration(data.apps[0].total_sec);
                }

                // Render App List
                const appContainer = document.getElementById('appContainer');
                const maxApp = data.apps.length > 0 ? data.apps[0].total_sec : 1;
                appContainer.innerHTML = data.apps.map(a => {
                    const pct = Math.round((a.total_sec / maxApp) * 100);
                    return `
                        <div>
                            <div class="flex justify-between text-xs mb-1">
                                <span class="font-semibold text-slate-200">\${a.app_name}</span>
                                <span class="text-slate-400 font-mono">\${fmtDuration(a.total_sec)}</span>
                            </div>
                            <div class="w-full bg-slate-800 rounded-full h-1.5">
                                <div class="bg-sky-400 h-1.5 rounded-full" style="width: \${pct}%"></div>
                            </div>
                        </div>
                    `;
                }).join('') || '<p class="text-xs text-slate-500">Kayıt yok.</p>';

                // Render Table
                const feed = document.getElementById('recentFeed');
                feed.innerHTML = data.recent.map(r => `
                    <tr class="hover:bg-slate-800/40 transition">
                        <td class="py-2 px-3 font-mono text-slate-400 text-[11px]">\${r.timestamp.split(' ')[1] || r.timestamp}</td>
                        <td class="py-2 px-3 font-semibold text-sky-400">\${r.app_name}</td>
                        <td class="py-2 px-3 truncate max-w-xs text-slate-300" title="\${r.window_title || ''}">\${r.window_title || '-'}</td>
                        <td class="py-2 px-3 text-right font-mono text-emerald-400 font-medium">\${fmtDuration(r.duration_seconds)}</td>
                    </tr>
                `).join('');

                // Update Category Chart
                const catLabels = data.categories.map(c => c.category);
                const catData = data.categories.map(c => Math.round(c.total_sec / 60));
                
                if (categoryChart) categoryChart.destroy();
                const ctxCat = document.getElementById('categoryChart').getContext('2d');
                categoryChart = new Chart(ctxCat, {
                    type: 'doughnut',
                    data: {
                        labels: catLabels,
                        datasets: [{
                            data: catData,
                            backgroundColor: ['#38BDF8', '#818CF8', '#34D399', '#F472B6', '#FBBF24', '#94A3B8'],
                            borderWidth: 0
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: { position: 'bottom', labels: { color: '#94A3B8', boxWidth: 10, font: { size: 10 } } }
                        }
                    }
                });

                // Update Timeline Chart
                if (timelineChart) timelineChart.destroy();
                const ctxTime = document.getElementById('timelineChart').getContext('2d');
                timelineChart = new Chart(ctxTime, {
                    type: 'bar',
                    data: {
                        labels: data.timeline.map(t => t.period),
                        datasets: [{
                            label: 'Odak (Dakika)',
                            data: data.timeline.map(t => Math.round(t.duration / 60)),
                            backgroundColor: '#38BDF8',
                            borderRadius: 6
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        scales: {
                            x: { grid: { display: false }, ticks: { color: '#64748B', font: { size: 10 } } },
                            y: { grid: { color: '#1E293B' }, ticks: { color: '#64748B', font: { size: 10 } } }
                        },
                        plugins: { legend: { display: false } }
                    }
                });

            } catch (e) {
                console.error("Stats error:", e);
            }
        }

        fetchStats();
        setInterval(fetchStats, 5000);
    </script>
</body>
</html>`;

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
        res.end(HTML);
    } else if (parsedUrl.pathname === '/assets/erlik_logo.jpg') {
        const logoPath = '/Users/halil/code/erlik/assets/erlik_logo.jpg';
        if (fs.existsSync(logoPath)) {
            res.writeHead(200, { 'Content-Type': 'image/jpeg' });
            fs.createReadStream(logoPath).pipe(res);
        } else {
            res.writeHead(404);
            res.end();
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
    } else if (parsedUrl.pathname === '/api/send-email' && req.method === 'POST') {
        try {
            execSync('/Users/halil/code/erlik/erlik_mailer.sh', { encoding: 'utf-8' });
            res.writeHead(200, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({ success: true, message: 'Haftalık rapor halil@ertekin.me adresine gönderildi!' }));
        } catch(e) {
            res.writeHead(500, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({ success: false, error: e.message }));
        }
    } else {
        res.writeHead(404);
        res.end('Not Found');
    }
});

server.listen(PORT, '127.0.0.1', () => {
    console.log(`🐺 ERLİK Web UI v2.0 ready: http://localhost:${PORT}`);
});
