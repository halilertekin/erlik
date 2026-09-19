import os

logo_b64 = open("/Users/halil/code/erlik/landing/logo_base64.txt").read().strip()

template = """// Cloudflare Worker for Erlik Landing Page (erlik.be & erlik.ertekin.workers.dev)

export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);

    // API or Health check endpoint
    if (url.pathname === "/api/health") {
      return new Response(JSON.stringify({
        status: "online",
        project: "ERLIK",
        desc: "Apple Silicon Native Activity & Focus Intelligence Tracker",
        version: "3.2.3",
        homebrew: "brew install halilertekin/erlik/erlik",
        domain: "erlik.be"
      }), {
        headers: { "Content-Type": "application/json; charset=utf-8", "Access-Control-Allow-Origin": "*" }
      });
    }

    // Redirect /brew or /install to github instructions
    if (url.pathname === "/install") {
      return Response.redirect("https://github.com/halilertekin/erlik#-homebrew-installation", 302);
    }

    const html = `<!DOCTYPE html>
<html lang="tr" class="dark">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>ERLÍK — Apple Silicon Native Mac Activity & Focus Intelligence</title>
  <meta name="description" content="M1/M2/M3/M4 için saf Swift ARM64 mimarisiyle yazılmış, sıfır RAM/CPU tüketen, gizlilik odaklı açık kaynak macOS aktivite, IDE, AGI & odak takipçisi.">
  <meta property="og:title" content="ERLÍK — Apple Silicon Native Mac Activity & Focus Intelligence">
  <meta property="og:description" content="Zero RAM, Zero CPU, Pure Swift ARM64. Modern Mac aktivite ve AGI ajan çalışma telemetrisi.">
  <meta property="og:type" content="website">
  <meta property="og:url" content="https://erlik.be">
  <link rel="icon" href="data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><text y='.9em' font-size='90'>🐺</text></svg>">
  <script src="https://cdn.tailwindcss.com"></script>
  <script>
    tailwind.config = {
      darkMode: 'class',
      theme: {
        extend: {
          colors: {
            brand: {
              50: '#f0f9ff',
              400: '#38bdf8',
              500: '#0284c7',
              600: '#0369a1',
            }
          }
        }
      }
    }
  </script>
  <style>
    @import url('https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500;600;700&family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap');
    body {
      font-family: 'Plus Jakarta Sans', sans-serif;
      background: radial-gradient(circle at 50% 0%, #0f172a 0%, #020617 100%);
    }
    .font-mono {
      font-family: 'JetBrains Mono', monospace;
    }
    .glass-card {
      background: rgba(15, 23, 42, 0.75);
      backdrop-filter: blur(16px);
      -webkit-backdrop-filter: blur(16px);
      border: 1px solid rgba(255, 255, 255, 0.08);
    }
    .glass-card:hover {
      border-color: rgba(56, 189, 248, 0.25);
    }
    .glow-cyan {
      box-shadow: 0 0 50px -10px rgba(56, 189, 248, 0.25);
    }
    .glow-purple {
      box-shadow: 0 0 50px -10px rgba(192, 132, 252, 0.25);
    }
    .gradient-text {
      background: linear-gradient(135deg, #38bdf8 0%, #818cf8 50%, #c084fc 100%);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
    }
  </style>
</head>
<body class="min-h-screen text-slate-100 selection:bg-sky-500 selection:text-white flex flex-col justify-between antialiased">

  <!-- Ambient Glow Background -->
  <div class="fixed inset-0 overflow-hidden pointer-events-none z-0">
    <div class="absolute -top-40 left-1/2 -translate-x-1/2 w-[600px] sm:w-[900px] h-[400px] bg-gradient-to-tr from-sky-600/15 via-indigo-600/15 to-purple-600/15 blur-[120px] rounded-full"></div>
    <div class="absolute top-1/2 left-10 w-72 h-72 bg-sky-500/5 blur-[100px] rounded-full"></div>
    <div class="absolute top-2/3 right-10 w-80 h-80 bg-purple-500/5 blur-[100px] rounded-full"></div>
  </div>

  <!-- Navigation -->
  <nav class="relative z-10 max-w-6xl mx-auto w-full px-6 py-6 flex items-center justify-between">
    <div class="flex items-center gap-3">
      <img src="data:image/jpeg;base64,__LOGO_PLACEHOLDER__" alt="Erlik Logo" class="w-10 h-10 rounded-xl shadow-lg border border-sky-500/30 object-cover">
      <div>
        <div class="flex items-center gap-2">
          <span class="font-extrabold tracking-tight text-xl text-white">ERLÍK</span>
          <span class="text-[10px] font-mono px-2 py-0.5 rounded-full bg-sky-500/10 text-sky-400 border border-sky-500/30 font-semibold">v3.2.3</span>
        </div>
        <p class="text-[11px] text-slate-400 font-mono hidden sm:block">macOS Focus Intelligence</p>
      </div>
    </div>
    <div class="flex items-center gap-3 text-xs">
      <a href="https://github.com/halilertekin/erlik" target="_blank" rel="noopener" class="px-3.5 py-2 rounded-xl bg-slate-900/80 hover:bg-slate-800 text-slate-200 border border-slate-700/80 font-medium transition flex items-center gap-2">
        <svg class="w-4 h-4 fill-current" viewBox="0 0 24 24"><path d="M12 0C5.37 0 0 5.37 0 12c0 5.31 3.435 9.795 8.205 11.385.6.105.825-.255.825-.57 0-.285-.015-1.23-.015-2.235-3.015.555-3.795-.735-4.035-1.41-.135-.345-.72-1.41-1.23-1.695-.42-.225-1.02-.78-.015-.795.945-.015 1.62.87 1.845 1.23 1.08 1.815 2.805 1.305 3.495.99.105-.78.42-1.305.765-1.605-2.67-.3-5.46-1.335-5.46-5.925 0-1.305.465-2.385 1.23-3.225-.12-.3-.54-1.53.12-3.18 0 0 1.005-.315 3.3 1.23.96-.27 1.98-.405 3-.405s2.04.135 3 .405c2.295-1.56 3.3-1.23 3.3-1.23.66 1.65.24 2.88.12 3.18.765.84 1.23 1.905 1.23 3.225 0 4.605-2.805 5.625-5.475 5.925.435.375.81 1.095.81 2.22 0 1.605-.015 2.895-.015 3.3 0 .315.225.69.825.57A12.02 12.02 0 0024 12c0-6.63-5.37-12-12-12z"/></svg>
        <span>GitHub</span>
      </a>
      <a href="#install" class="px-4 py-2 rounded-xl bg-gradient-to-r from-sky-500 to-indigo-600 hover:from-sky-400 hover:to-indigo-500 text-white font-semibold transition shadow-md shadow-sky-500/20">
        Kurulum
      </a>
    </div>
  </nav>

  <!-- Hero Section -->
  <main class="relative z-10 max-w-5xl mx-auto px-6 pt-12 pb-16 text-center">
    
    <!-- Badge -->
    <div class="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-sky-500/10 border border-sky-500/30 text-sky-300 text-xs font-mono mb-6 backdrop-blur-md">
      <span class="w-2 h-2 rounded-full bg-sky-400 animate-ping"></span>
      <span>Saf Swift ARM64 Native & Zero Memory Leak</span>
    </div>

    <!-- Title -->
    <h1 class="text-4xl sm:text-6xl lg:text-7xl font-extrabold tracking-tight leading-[1.1] mb-6">
      Mac için <span class="gradient-text">Aktivite, AGI & Odak</span> Zekâsı
    </h1>

    <!-- Subtitle -->
    <p class="text-base sm:text-xl text-slate-400 max-w-3xl mx-auto mb-10 leading-relaxed">
      ActivityWatch veya RescueTime gibi 200MB+ RAM tüketen ağır Electron uygulamalarına veda edin. 
      <b class="text-slate-200">ERLÍK</b>, doğrudan Apple Silicon çekirdeğine (<span class="font-mono text-sky-400">IOHIDSystem</span>) kancalanır; 
      <b class="text-sky-300">~8 MB RAM</b> ile sıfır pil tüketimi ve <b>%100 yerel gizlilik</b> sunar.
    </p>

    <!-- Installation Terminal Card -->
    <div id="install" class="max-w-xl mx-auto mb-14 text-left">
      <div class="glass-card rounded-2xl p-4 shadow-2xl glow-cyan">
        <div class="flex items-center justify-between pb-3 mb-3 border-b border-slate-800">
          <div class="flex items-center gap-2">
            <span class="w-3 h-3 rounded-full bg-rose-500/80"></span>
            <span class="w-3 h-3 rounded-full bg-amber-500/80"></span>
            <span class="w-3 h-3 rounded-full bg-emerald-500/80"></span>
            <span class="text-xs font-mono text-slate-400 ml-2">Terminal (Homebrew)</span>
          </div>
          <span class="text-[10px] font-mono text-slate-500">v3.2.3 arm64</span>
        </div>
        <div class="space-y-2 font-mono text-xs sm:text-sm">
          <div class="flex items-center justify-between group bg-slate-950/60 p-2.5 rounded-xl border border-slate-800/80">
            <div class="flex items-center gap-2 text-sky-300 overflow-x-auto">
              <span class="text-slate-500 select-none">$</span>
              <span>brew install halilertekin/erlik/erlik</span>
            </div>
            <button onclick="copyCmd('brew install halilertekin/erlik/erlik', this)" class="text-xs px-2.5 py-1 rounded-lg bg-slate-800 hover:bg-slate-700 text-slate-300 transition flex items-center gap-1 shrink-0 ml-2" title="Kopyala">
              <span>📋</span>
              <span class="btn-text">Kopyala</span>
            </button>
          </div>
          <div class="flex items-center justify-between group bg-slate-950/60 p-2.5 rounded-xl border border-slate-800/80">
            <div class="flex items-center gap-2 text-purple-300 overflow-x-auto">
              <span class="text-slate-500 select-none">$</span>
              <span>erlik start</span>
            </div>
            <button onclick="copyCmd('erlik start', this)" class="text-xs px-2.5 py-1 rounded-lg bg-slate-800 hover:bg-slate-700 text-slate-300 transition flex items-center gap-1 shrink-0 ml-2" title="Kopyala">
              <span>📋</span>
              <span class="btn-text">Kopyala</span>
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Features Grid -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6 text-left max-w-5xl mx-auto">
      
      <!-- Feature 1 -->
      <div class="glass-card rounded-2xl p-6 transition duration-300">
        <div class="w-12 h-12 rounded-xl bg-sky-500/10 border border-sky-500/30 flex items-center justify-center text-2xl mb-4">
          ⚡
        </div>
        <h3 class="text-lg font-bold text-white mb-2">Saf ARM64 Swift Çekirdeği</h3>
        <p class="text-xs text-slate-400 leading-relaxed">
          Rosetta veya Electron katmanı olmadan Apple Silicon için optimize edildi. Sadece ~8MB RAM harcar, arka planda varlığını hissettirmez ve pil tüketmez.
        </p>
      </div>

      <!-- Feature 2 -->
      <div class="glass-card rounded-2xl p-6 transition duration-300">
        <div class="w-12 h-12 rounded-xl bg-purple-500/10 border border-purple-500/30 flex items-center justify-center text-2xl mb-4">
          🤖
        </div>
        <h3 class="text-lg font-bold text-white mb-2">AGI & Agent Telemetrisi</h3>
        <p class="text-xs text-slate-400 leading-relaxed">
          Antigravity, Cursor, Claude Code, Codex, ZCode ve OpenClaw ile çalışma sürelerinizi otomatik tanır. Sentetik kodlama oranı ve tahmini token maliyetini hesaplar.
        </p>
      </div>

      <!-- Feature 3 -->
      <div class="glass-card rounded-2xl p-6 transition duration-300">
        <div class="w-12 h-12 rounded-xl bg-emerald-500/10 border border-emerald-500/30 flex items-center justify-center text-2xl mb-4">
          🔒
        </div>
        <h3 class="text-lg font-bold text-white mb-2">%100 Yerel & Özel SQLite</h3>
        <p class="text-xs text-slate-400 leading-relaxed">
          Hiçbir telemetri veriniz internete sızmaz. Tüm aktivite, pencere başlıkları ve odak kayıtları bilgisayarınızdaki yerel <code class="text-sky-300">erlik.db</code> dosyasında saklanır.
        </p>
      </div>

      <!-- Feature 4 -->
      <div class="glass-card rounded-2xl p-6 transition duration-300">
        <div class="w-12 h-12 rounded-xl bg-amber-500/10 border border-amber-500/30 flex items-center justify-center text-2xl mb-4">
          🐺
        </div>
        <h3 class="text-lg font-bold text-white mb-2">macOS Menubar Companion</h3>
        <p class="text-xs text-slate-400 leading-relaxed">
          Menü çubuğunuzda anlık odak süresi, serbest RAM ve disk durumu. Tek tıkla inaktif belleği boşaltma (<code class="text-amber-300">purge</code>) ve geliştirici önbelleklerini temizleme.
        </p>
      </div>

      <!-- Feature 5 -->
      <div class="glass-card rounded-2xl p-6 transition duration-300">
        <div class="w-12 h-12 rounded-xl bg-rose-500/10 border border-rose-500/30 flex items-center justify-center text-2xl mb-4">
          🍅
        </div>
        <h3 class="text-lg font-bold text-white mb-2">Pomodoro & 20-20-20 Ergonomi</h3>
        <p class="text-xs text-slate-400 leading-relaxed">
          Yerleşik 25/5 odaklanma sayacı ve göz sağlığınızı koruyan ergonomik 20-20-20 dinlenme rehberliği ile tükenmişlik yaşamadan derin odaklanın.
        </p>
      </div>

      <!-- Feature 6 -->
      <div class="glass-card rounded-2xl p-6 transition duration-300">
        <div class="w-12 h-12 rounded-xl bg-cyan-500/10 border border-cyan-500/30 flex items-center justify-center text-2xl mb-4">
          📊
        </div>
        <h3 class="text-lg font-bold text-white mb-2">Çok Dilli Glassmorphism Panel</h3>
        <p class="text-xs text-slate-400 leading-relaxed">
          <code class="text-sky-300">localhost:5757</code> adresinde Türkçe, İngilizce ve Felemenkçe destekli, interaktif Chart.js grafiklerine sahip karanlık mod dashboard.
        </p>
      </div>

    </div>

    <!-- Comparison Table Preview -->
    <div class="mt-16 max-w-4xl mx-auto text-left">
      <div class="glass-card rounded-2xl p-6 overflow-hidden">
        <h3 class="text-sm font-bold text-slate-300 uppercase tracking-wider mb-4 flex items-center gap-2">
          <span>⚖️</span> Mimari Karşılaştırması: ERLİK vs Diğerleri
        </h3>
        <div class="overflow-x-auto">
          <table class="w-full text-xs font-mono">
            <thead>
              <tr class="border-b border-slate-800 text-slate-400">
                <th class="py-2.5 text-left font-semibold">Özellik</th>
                <th class="py-2.5 text-center text-sky-400 font-bold bg-sky-500/10 rounded-t-lg">🐺 ERLÍK (Swift)</th>
                <th class="py-2.5 text-center font-normal text-slate-400">ActivityWatch</th>
                <th class="py-2.5 text-center font-normal text-slate-400">RescueTime</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-slate-800/60">
              <tr>
                <td class="py-2.5 text-slate-300 font-sans">RAM Tüketimi</td>
                <td class="py-2.5 text-center text-emerald-400 font-bold bg-sky-500/5">~8 MB</td>
                <td class="py-2.5 text-center text-rose-400">200 MB+ (Python/Qt)</td>
                <td class="py-2.5 text-center text-rose-400">150 MB+ (Electron)</td>
              </tr>
              <tr>
                <td class="py-2.5 text-slate-300 font-sans">İşlemci / Pil Etkisi</td>
                <td class="py-2.5 text-center text-emerald-400 font-bold bg-sky-500/5">%0.0 (Idle)</td>
                <td class="py-2.5 text-center text-amber-400">%1-3 CPU</td>
                <td class="py-2.5 text-center text-amber-400">%1-4 CPU</td>
              </tr>
              <tr>
                <td class="py-2.5 text-slate-300 font-sans">Yapay Zekâ (AGI) Telemetrisi</td>
                <td class="py-2.5 text-center text-emerald-400 font-bold bg-sky-500/5">Var (Otomatik)</td>
                <td class="py-2.5 text-center text-slate-500">Yok</td>
                <td class="py-2.5 text-center text-slate-500">Yok</td>
              </tr>
              <tr>
                <td class="py-2.5 text-slate-300 font-sans">RAM Boşaltma & Cache Temizleme</td>
                <td class="py-2.5 text-center text-emerald-400 font-bold bg-sky-500/5">Yerleşik</td>
                <td class="py-2.5 text-center text-slate-500">Yok</td>
                <td class="py-2.5 text-center text-slate-500">Yok</td>
              </tr>
              <tr>
                <td class="py-2.5 text-slate-300 font-sans">Veri Gizliliği</td>
                <td class="py-2.5 text-center text-emerald-400 font-bold bg-sky-500/5">%100 Yerel SQLite</td>
                <td class="py-2.5 text-center text-emerald-400">Yerel</td>
                <td class="py-2.5 text-center text-rose-400">Bulut Sunucularında</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

  </main>

  <!-- Footer -->
  <footer class="relative z-10 border-t border-slate-800/80 py-8 text-center text-xs text-slate-500">
    <div class="max-w-6xl mx-auto px-6 flex flex-col sm:flex-row items-center justify-between gap-4">
      <div class="flex items-center gap-2">
        <span class="text-base">🐺</span>
        <span class="text-slate-300 font-semibold">ERLÍK</span>
        <span>— Open Source under MIT License</span>
      </div>
      <div class="flex items-center gap-4 font-mono">
        <a href="https://github.com/halilertekin/erlik" target="_blank" rel="noopener" class="hover:text-sky-400 transition">GitHub Repo</a>
        <span>•</span>
        <a href="https://github.com/halilertekin/homebrew-erlik" target="_blank" rel="noopener" class="hover:text-sky-400 transition">Homebrew Tap</a>
        <span>•</span>
        <span class="text-slate-600">erlik.be</span>
      </div>
    </div>
  </footer>

  <script>
    function copyCmd(text, btn) {
      navigator.clipboard.writeText(text).then(() => {
        const span = btn.querySelector(".btn-text");
        if (span) {
          const old = span.innerText;
          span.innerText = "Kopyalandı!";
          setTimeout(() => { span.innerText = old; }, 2000);
        }
      });
    }
  </script>

</body>
</html>`;

    return new Response(html, {
      headers: {
        "Content-Type": "text/html; charset=utf-8",
        "Cache-Control": "public, max-age=300"
      }
    });
  }
};
"""

content = template.replace("__LOGO_PLACEHOLDER__", logo_b64)
with open("/Users/halil/code/erlik/landing/worker.js", "w") as f:
    f.write(content)
print("Worker script written successfully, size:", len(content))
