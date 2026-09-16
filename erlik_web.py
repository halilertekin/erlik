import http.server
import socketserver
import sqlite3
import json
import os

PORT = 5757
DB_PATH = "/Users/halil/code/erlik/erlik.db"

DASHBOARD_HTML = """<!DOCTYPE html>
<html lang="tr" class="dark">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ERLİK — Mac Activity Intelligence</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=JetBrains+Mono:wght@400;600&display=swap" rel="stylesheet">
    <script>
        tailwind.config = {
            darkMode: 'class',
            theme: {
                extend: {
                    fontFamily: {
                        sans: ['"Plus Jakarta Sans"', 'sans-serif'],
                        mono: ['"JetBrains Mono"', 'monospace'],
                    },
                    colors: {
                        erlik: {
                            bg: '#090D16',
                            card: '#0F172A',
                            border: '#1E293B',
                            primary: '#38BDF8',
                            accent: '#F43F5E',
                            emerald: '#10B981',
                            amber: '#F59E0B'
                        }
                    }
                }
            }
        }
    </script>
    <style>
        body { font-family: 'Plus Jakarta Sans', sans-serif; background-color: #090D16; }
        .glass { background: rgba(15, 23, 42, 0.75); backdrop-filter: blur(12px); }
    </style>
</head>
<body class="text-slate-100 min-h-screen p-6 md:p-10 antialiased selection:bg-sky-500 selection:text-white">
    <div class="max-w-6xl mx-auto space-y-8">
        <!-- Top Navigation -->
        <header class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 border-b border-slate-800/80 pb-6">
            <div class="flex items-center gap-3">
                <div class="w-10 h-10 rounded-xl bg-gradient-to-tr from-sky-500 to-indigo-600 flex items-center justify-center shadow-lg shadow-sky-500/20 font-bold text-lg">
                    🐺
                </div>
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
                <span id="liveClock" class="font-mono text-xs px-3 py-1.5 rounded-lg bg-slate-800/80 border border-slate-700 text-slate-400">--:--:--</span>
                <button onclick="fetchStats()" class="px-4 py-1.5 bg-sky-500/10 hover:bg-sky-500/20 text-sky-400 border border-sky-500/30 rounded-lg text-xs font-semibold tracking-wide transition flex items-center gap-1.5">
                    <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path></svg>
                    Yenile
                </button>
            </div>
        </header>

        <!-- Metric KPI Cards -->
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
            <div class="glass p-5 rounded-2xl border border-slate-800 relative overflow-hidden">
                <div class="text-slate-400 text-xs font-semibold uppercase tracking-wider">Bugünkü Toplam Çalışma</div>
                <div id="metricTotal" class="text-3xl font-bold text-white mt-2 font-mono">0 dk</div>
                <div class="text-xs text-emerald-400 mt-2 flex items-center gap-1">
                    <span class="w-1.5 h-1.5 rounded-full bg-emerald-400"></span> Gerçek Aktif Odaklanma
                </div>
            </div>
            <div class="glass p-5 rounded-2xl border border-slate-800 relative overflow-hidden">
                <div class="text-slate-400 text-xs font-semibold uppercase tracking-wider">Ana Uygulama</div>
                <div id="metricTopApp" class="text-2xl font-bold text-sky-400 mt-2 truncate">-</div>
                <div id="metricTopAppTime" class="text-xs text-slate-400 mt-2 font-mono">0 sn</div>
            </div>
            <div class="glass p-5 rounded-2xl border border-slate-800 relative overflow-hidden">
                <div class="text-slate-400 text-xs font-semibold uppercase tracking-wider">Boşta (AFK) Süresi</div>
                <div id="metricAfk" class="text-3xl font-bold text-amber-400 mt-2 font-mono">0 dk</div>
                <div class="text-xs text-slate-500 mt-2">Donanım IOHID Sayacı</div>
            </div>
            <div class="glass p-5 rounded-2xl border border-slate-800 relative overflow-hidden">
                <div class="text-slate-400 text-xs font-semibold uppercase tracking-wider">Takip Edilen Pencereler</div>
                <div id="metricSessions" class="text-3xl font-bold text-indigo-400 mt-2 font-mono">0</div>
                <div class="text-xs text-slate-500 mt-2">Benzersiz Aktivite Kaydı</div>
            </div>
        </div>

        <!-- Category & App Breakdown -->
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
            <!-- Left: Category Distribution -->
            <div class="glass p-6 rounded-2xl border border-slate-800 space-y-4">
                <h2 class="text-base font-semibold text-slate-200">Kategori Dağılımı</h2>
                <div id="categoryContainer" class="space-y-3">
                    <p class="text-slate-500 text-xs">Yükleniyor...</p>
                </div>
            </div>

            <!-- Right: Detailed App List -->
            <div class="glass p-6 rounded-2xl border border-slate-800 lg:col-span-2 space-y-4">
                <h2 class="text-base font-semibold text-slate-200">Uygulama Kullanım Detayı</h2>
                <div id="appContainer" class="space-y-3">
                    <p class="text-slate-500 text-xs">Yükleniyor...</p>
                </div>
            </div>
        </div>

        <!-- Recent Activities Feed -->
        <div class="glass rounded-2xl border border-slate-800 p-6 space-y-4">
            <h2 class="text-base font-semibold text-slate-200">Son Pencere ve Odak Akışı</h2>
            <div class="overflow-x-auto">
                <table class="w-full text-left text-xs text-slate-300">
                    <thead class="bg-slate-800/60 uppercase text-[10px] font-semibold text-slate-400 border-b border-slate-700/60">
                        <tr>
                            <th class="py-3 px-4">Zaman</th>
                            <th class="py-3 px-4">Uygulama</th>
                            <th class="py-3 px-4">Kategori</th>
                            <th class="py-3 px-4">Pencere Başlığı</th>
                            <th class="py-3 px-4 text-right">Süre</th>
                        </tr>
                    </thead>
                    <tbody id="recentFeed" class="divide-y divide-slate-800">
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <script>
        function updateClock() {
            const d = new Date();
            document.getElementById('liveClock').innerText = d.toLocaleTimeString('tr-TR');
        }
        setInterval(updateClock, 1000);
        updateClock();

        function fmtDuration(secs) {
            if (secs < 60) return secs + ' sn';
            const mins = Math.floor(secs / 60);
            if (mins < 60) return mins + ' dk';
            const hrs = (mins / 60).toFixed(1);
            return hrs + ' sa';
        }

        async function fetchStats() {
            try {
                const res = await fetch('/api/stats');
                const data = await res.json();

                document.getElementById('metricTotal').innerText = fmtDuration(data.total_active_seconds);
                document.getElementById('metricAfk').innerText = fmtDuration(data.total_afk_seconds);
                document.getElementById('metricSessions').innerText = data.total_events || 0;
                
                if (data.apps && data.apps.length > 0) {
                    document.getElementById('metricTopApp').innerText = data.apps[0].app_name;
                    document.getElementById('metricTopAppTime').innerText = fmtDuration(data.apps[0].total_sec);
                }

                // Categories
                const catContainer = document.getElementById('categoryContainer');
                const maxCat = data.categories.length > 0 ? data.categories[0].total_sec : 1;
                catContainer.innerHTML = data.categories.map(c => {
                    const pct = Math.round((c.total_sec / maxCat) * 100);
                    return `
                        <div>
                            <div class="flex justify-between text-xs mb-1 font-medium">
                                <span class="text-slate-300">${c.category}</span>
                                <span class="text-slate-400 font-mono">${fmtDuration(c.total_sec)}</span>
                            </div>
                            <div class="w-full bg-slate-800 rounded-full h-1.5">
                                <div class="bg-indigo-500 h-1.5 rounded-full" style="width: ${pct}%"></div>
                            </div>
                        </div>
                    `;
                }).join('') || '<p class="text-xs text-slate-500">Henüz kategori verisi yok.</p>';

                // Apps
                const appContainer = document.getElementById('appContainer');
                const maxApp = data.apps.length > 0 ? data.apps[0].total_sec : 1;
                appContainer.innerHTML = data.apps.map(a => {
                    const pct = Math.round((a.total_sec / maxApp) * 100);
                    return `
                        <div>
                            <div class="flex justify-between text-xs mb-1">
                                <span class="font-semibold text-slate-200">${a.app_name}</span>
                                <span class="text-slate-400 font-mono">${fmtDuration(a.total_sec)}</span>
                            </div>
                            <div class="w-full bg-slate-800 rounded-full h-2">
                                <div class="bg-sky-400 h-2 rounded-full" style="width: ${pct}%"></div>
                            </div>
                        </div>
                    `;
                }).join('') || '<p class="text-xs text-slate-500">Henüz uygulama kaydı yok.</p>';

                // Recent Feed
                const feed = document.getElementById('recentFeed');
                feed.innerHTML = data.recent.map(r => `
                    <tr class="hover:bg-slate-800/40 transition">
                        <td class="py-2.5 px-4 font-mono text-slate-400">${r.timestamp.split(' ')[1] || r.timestamp}</td>
                        <td class="py-2.5 px-4 font-semibold text-sky-400">${r.app_name}</td>
                        <td class="py-2.5 px-4"><span class="px-2 py-0.5 rounded text-[10px] bg-slate-800 text-slate-300 border border-slate-700">${r.category}</span></td>
                        <td class="py-2.5 px-4 truncate max-w-sm text-slate-300" title="${r.window_title || ''}">${r.window_title || '-'}</td>
                        <td class="py-2.5 px-4 text-right font-mono text-emerald-400">${fmtDuration(r.duration_seconds)}</td>
                    </tr>
                `).join('');
            } catch (e) {
                console.error("Stats fetch error:", e);
            }
        }

        fetchStats();
        setInterval(fetchStats, 3000);
    </script>
</body>
</html>
"""

class ErlikHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/" or self.path == "/index.html":
            self.send_response(200)
            self.send_header("Content-type", "text/html; charset=utf-8")
            self.end_headers()
            self.wfile.write(DASHBOARD_HTML.encode("utf-8"))
        elif self.path == "/api/stats":
            conn = sqlite3.connect(DB_PATH)
            c = conn.cursor()

            # Toplam aktif & afk süreleri
            c.execute("SELECT IFNULL(SUM(duration_seconds), 0) FROM erlik_heartbeats WHERE is_afk = 0;")
            active_sec = c.fetchone()[0]

            c.execute("SELECT IFNULL(SUM(duration_seconds), 0) FROM erlik_heartbeats WHERE is_afk = 1;")
            afk_sec = c.fetchone()[0]

            c.execute("SELECT COUNT(*) FROM erlik_heartbeats;")
            total_events = c.fetchone()[0]

            # Kategori bazlı
            c.execute("""
                SELECT category, SUM(duration_seconds) as total_sec
                FROM erlik_heartbeats
                WHERE is_afk = 0
                GROUP BY category
                ORDER BY total_sec DESC;
            """)
            categories = [{"category": r[0], "total_sec": r[1]} for r in c.fetchall()]

            # Uygulama bazlı
            c.execute("""
                SELECT app_name, SUM(duration_seconds) as total_sec
                FROM erlik_heartbeats
                WHERE is_afk = 0
                GROUP BY app_name
                ORDER BY total_sec DESC
                LIMIT 10;
            """)
            apps = [{"app_name": r[0], "total_sec": r[1]} for r in c.fetchall()]

            # Son akış
            c.execute("""
                SELECT timestamp, app_name, category, window_title, duration_seconds
                FROM erlik_heartbeats
                ORDER BY id DESC
                LIMIT 25;
            """)
            recent = [{
                "timestamp": r[0],
                "app_name": r[1],
                "category": r[2],
                "window_title": r[3],
                "duration_seconds": r[4]
            } for r in c.fetchall()]

            conn.close()

            data = {
                "total_active_seconds": active_sec,
                "total_afk_seconds": afk_sec,
                "total_events": total_events,
                "categories": categories,
                "apps": apps,
                "recent": recent
            }

            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps(data).encode("utf-8"))
        else:
            self.send_response(404)
            self.end_headers()

if __name__ == "__main__":
    with socketserver.TCPServer(("127.0.0.1", PORT), ErlikHandler) as httpd:
        print(f"🐺 ERLİK Web Engine başlatıldı: http://localhost:{PORT}")
        httpd.serve_forever()
