// Cloudflare Worker for Erlik Landing Page (erlik.be & erlik.ertekin.workers.dev)

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
      <img src="data:image/jpeg;base64,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" alt="Erlik Logo" class="w-10 h-10 rounded-xl shadow-lg border border-sky-500/30 object-cover">
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
