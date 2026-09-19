import os

logo_b64 = open("/Users/halil/code/erlik/landing/logo_base64.txt").read().strip()

template = """// Cloudflare Worker for Erlik Landing Page (erlik.be & erlik.ertekin.workers.dev)
// PasteApp.io-inspired Apple Native Architecture & Telemetry Showcase

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
        domain: "erlik.be",
        timestamp: new Date().toISOString()
      }), {
        headers: { "Content-Type": "application/json; charset=utf-8", "Access-Control-Allow-Origin": "*" }
      });
    }

    // Redirect /brew or /install to github instructions
    if (url.pathname === "/install" || url.pathname === "/brew") {
      return Response.redirect("https://github.com/halilertekin/erlik#-homebrew-installation", 302);
    }

    const html = `<!DOCTYPE html>
<html lang="en" class="scroll-smooth">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>ERLÍK — Pure Swift Focus & AGI Intelligence for Mac</title>
  <meta name="description" content="Pure Swift ARM64 macOS activity, IDE & AGI agent telemetry tracker. 8MB RAM, zero battery drain, 100% private SQLite on-device.">
  <meta property="og:title" content="ERLÍK — Everything you build on your Mac, measured with zero overhead.">
  <meta property="og:description" content="More than a time tracker. Built for developers, AI engineers, and deep focus. Inspired by Apple-native craft.">
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
            pasteBg: '#090a0f',
            pasteCard: '#13151f',
            pasteBorder: 'rgba(255, 255, 255, 0.08)',
            pastePill: '#1e2130',
            brand: {
              400: '#38bdf8',
              500: '#0ea5e9',
              600: '#0284c7',
            }
          },
          fontFamily: {
            sans: ['-apple-system', 'BlinkMacSystemFont', 'Plus Jakarta Sans', 'SF Pro Display', 'Segoe UI', 'Roboto', 'sans-serif'],
            mono: ['SF Mono', 'JetBrains Mono', 'Menlo', 'monospace']
          }
        }
      }
    }
  </script>
  <style>
    @import url('https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500;600;700&family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap');
    body {
      font-family: 'Plus Jakarta Sans', -apple-system, BlinkMacSystemFont, sans-serif;
      background-color: #07080c;
      color: #f1f5f9;
      overflow-x: hidden;
    }
    .apple-glass {
      background: rgba(19, 21, 32, 0.72);
      backdrop-filter: blur(24px);
      -webkit-backdrop-filter: blur(24px);
      border: 1px solid rgba(255, 255, 255, 0.08);
    }
    .apple-glass:hover {
      border-color: rgba(56, 189, 248, 0.28);
    }
    .apple-pill-active {
      background: rgba(255, 255, 255, 0.12);
      border-color: rgba(255, 255, 255, 0.25);
      color: #ffffff;
      box-shadow: 0 4px 20px rgba(0, 0, 0, 0.35);
    }
    .glow-radial {
      background: radial-gradient(circle 600px at 50% -10%, rgba(56, 189, 248, 0.18), transparent 70%),
                  radial-gradient(circle 500px at 80% 20%, rgba(168, 85, 247, 0.12), transparent 70%),
                  radial-gradient(circle 500px at 20% 30%, rgba(14, 165, 233, 0.12), transparent 70%);
    }
    .gradient-hero-text {
      background: linear-gradient(180deg, #ffffff 0%, #cbd5e1 55%, #94a3b8 100%);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
    }
    .gradient-accent-text {
      background: linear-gradient(135deg, #38bdf8 0%, #818cf8 50%, #c084fc 100%);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
    }
    /* Hide scrollbars for carousels */
    .no-scrollbar::-webkit-scrollbar { display: none; }
    .no-scrollbar { -ms-overflow-style: none; scrollbar-width: none; }
    .animate-float {
      animation: float 6s ease-in-out infinite;
    }
    @keyframes float {
      0%, 100% { transform: translateY(0px); }
      50% { transform: translateY(-8px); }
    }
  </style>
</head>
<body class="min-h-screen selection:bg-sky-500 selection:text-white relative">

  <!-- Ambient Backdrop Glow (PasteApp feel) -->
  <div class="fixed inset-0 glow-radial pointer-events-none z-0"></div>

  <!-- Top Announcement Bar -->
  <div class="relative z-20 border-b border-white/5 bg-slate-950/60 backdrop-blur-md px-4 py-2 text-center text-xs text-slate-400 flex items-center justify-center gap-2">
    <span class="inline-flex items-center gap-1.5 px-2 py-0.5 rounded-full bg-sky-500/10 text-sky-300 font-mono text-[11px] border border-sky-500/20">
      <span class="w-1.5 h-1.5 rounded-full bg-sky-400 animate-pulse"></span>
      NEW v3.2.3
    </span>
    <span>Autonomous Remote Session & Terminal Tracking without mouse movement now live!</span>
    <a href="#install" class="text-sky-400 hover:text-sky-300 underline font-medium ml-1">Install via Brew &rarr;</a>
  </div>

  <!-- Main Navigation -->
  <header class="sticky top-0 z-50 apple-glass border-b border-white/5 transition-all">
    <div class="max-w-6xl mx-auto px-6 h-16 flex items-center justify-between">
      
      <!-- Brand -->
      <a href="#" class="flex items-center gap-3 group">
        <img src="data:image/jpeg;base64,__LOGO_PLACEHOLDER__" alt="Erlik Logo" class="w-9 h-9 rounded-xl shadow-lg border border-white/10 object-cover group-hover:scale-105 transition">
        <div>
          <div class="flex items-center gap-2">
            <span class="font-extrabold tracking-tight text-lg text-white">ERLÍK</span>
            <span class="text-[10px] font-mono px-2 py-0.5 rounded-full bg-white/5 text-slate-300 border border-white/10">macOS</span>
          </div>
        </div>
      </a>

      <!-- Navigation Links -->
      <nav class="hidden md:flex items-center gap-8 text-sm text-slate-400 font-medium">
        <a href="#features" class="hover:text-white transition">Features</a>
        <a href="#built-for" class="hover:text-white transition">Use Cases</a>
        <a href="#ai-tools" class="hover:text-white transition">AI & AGI Telemetry</a>
        <a href="#privacy" class="hover:text-white transition">Privacy</a>
        <a href="#comparison" class="hover:text-white transition">Architecture</a>
      </nav>

      <!-- Action Buttons -->
      <div class="flex items-center gap-3 text-xs">
        <a href="https://github.com/halilertekin/erlik" target="_blank" rel="noopener" class="px-3.5 py-2 rounded-xl bg-white/5 hover:bg-white/10 text-slate-200 border border-white/10 font-medium transition flex items-center gap-2">
          <svg class="w-4 h-4 fill-current" viewBox="0 0 24 24"><path d="M12 0C5.37 0 0 5.37 0 12c0 5.31 3.435 9.795 8.205 11.385.6.105.825-.255.825-.57 0-.285-.015-1.23-.015-2.235-3.015.555-3.795-.735-4.035-1.41-.135-.345-.72-1.41-1.23-1.695-.42-.225-1.02-.78-.015-.795.945-.015 1.62.87 1.845 1.23 1.08 1.815 2.805 1.305 3.495.99.105-.78.42-1.305.765-1.605-2.67-.3-5.46-1.335-5.46-5.925 0-1.305.465-2.385 1.23-3.225-.12-.3-.54-1.53.12-3.18 0 0 1.005-.315 3.3 1.23.96-.27 1.98-.405 3-.405s2.04.135 3 .405c2.295-1.56 3.3-1.23 3.3-1.23.66 1.65.24 2.88.12 3.18.765.84 1.23 1.905 1.23 3.225 0 4.605-2.805 5.625-5.475 5.925.435.375.81 1.095.81 2.22 0 1.605-.015 2.895-.015 3.3 0 .315.225.69.825.57A12.02 12.02 0 0024 12c0-6.63-5.37-12-12-12z"/></svg>
          <span class="hidden sm:inline">GitHub</span>
        </a>
        <a href="#install" class="px-4 py-2 rounded-xl bg-white text-black font-semibold hover:bg-slate-200 transition shadow-lg shadow-white/10 flex items-center gap-1.5">
          <span>Get ERLÍK</span>
        </a>
      </div>

    </div>
  </header>

  <!-- Hero Section (PasteApp Hero Model) -->
  <section class="relative z-10 pt-16 sm:pt-24 pb-20 px-6 text-center max-w-5xl mx-auto">
    
    <!-- Apple Silicon Pill -->
    <div class="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-white/5 border border-white/10 text-slate-300 text-xs font-mono mb-8 backdrop-blur-md">
      <span class="text-sky-400">⚡</span>
      <span>Engineered for Apple Silicon M1 / M2 / M3 / M4</span>
      <span class="text-slate-600">•</span>
      <span class="text-emerald-400">8 MB RAM Native</span>
    </div>

    <!-- Main Display Heading -->
    <h1 class="text-4xl sm:text-6xl lg:text-7xl font-extrabold tracking-tight leading-[1.08] mb-6">
      <span class="gradient-hero-text">Everything you build on your Mac,</span><br>
      <span class="gradient-accent-text">measured with zero overhead.</span>
    </h1>

    <!-- Subtitle -->
    <p class="text-base sm:text-xl text-slate-400 max-w-2xl mx-auto mb-10 leading-relaxed font-normal">
      No Electron baggage. No 300MB RAM memory leaks. ERLÍK hooks directly into the macOS Mach kernel to track deep focus, remote terminal sessions, and autonomous AGI agents — with 100% private SQLite storage.
    </p>

    <!-- CTAs and Terminal Install Box -->
    <div class="flex flex-col sm:flex-row items-center justify-center gap-4 mb-14 max-w-xl mx-auto">
      
      <!-- Homebrew Pill Input -->
      <div class="w-full sm:w-auto flex-1 flex items-center justify-between px-4 py-3 rounded-2xl bg-white/5 border border-white/10 font-mono text-xs text-sky-300 shadow-2xl backdrop-blur-md group hover:border-sky-500/40 transition">
        <div class="flex items-center gap-2 overflow-x-auto no-scrollbar">
          <span class="text-slate-500 select-none">$</span>
          <span class="text-slate-200">brew install halilertekin/erlik/erlik</span>
        </div>
        <button onclick="copyBrew('brew install halilertekin/erlik/erlik', this)" class="ml-3 px-3 py-1.5 rounded-xl bg-white/10 hover:bg-white/20 text-white font-sans text-xs font-medium transition shrink-0 flex items-center gap-1.5">
          <span class="btn-icon">📋</span>
          <span class="btn-text">Copy</span>
        </button>
      </div>

      <a href="https://github.com/halilertekin/erlik/releases" target="_blank" class="w-full sm:w-auto px-6 py-3.5 rounded-2xl bg-white text-black font-semibold hover:bg-slate-100 transition shadow-xl shrink-0 flex items-center justify-center gap-2">
        <span>Download App</span>
        <span class="text-xs text-slate-500 font-mono">v3.2.3</span>
      </a>
    </div>

    <!-- Live Interactive Menubar & Dashboard Mockup (Hero Interactive Element) -->
    <div class="relative max-w-4xl mx-auto pt-6">
      
      <!-- Floating Mockup Container with Mac Window Chrome -->
      <div class="apple-glass rounded-2xl sm:rounded-3xl p-4 sm:p-6 shadow-2xl shadow-black/80 border border-white/10 text-left">
        
        <!-- Mac Top Bar -->
        <div class="flex items-center justify-between pb-4 mb-4 border-b border-white/5">
          <div class="flex items-center gap-2">
            <span class="w-3 h-3 rounded-full bg-[#ff5f56] inline-block"></span>
            <span class="w-3 h-3 rounded-full bg-[#ffbd2e] inline-block"></span>
            <span class="w-3 h-3 rounded-full bg-[#27c93f] inline-block"></span>
            <span class="ml-3 text-xs font-mono text-slate-400 hidden sm:inline">ERLÍK — Menubar Companion & AGI Cockpit</span>
          </div>
          <div class="flex items-center gap-3">
            <span class="px-2.5 py-0.5 rounded-full bg-emerald-500/10 text-emerald-400 font-mono text-[11px] border border-emerald-500/20 flex items-center gap-1.5">
              <span class="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-pulse"></span>
              Live Telemetry: Active
            </span>
            <span class="text-xs font-mono text-slate-500">M4 Pro Max • 8.1 MB RAM</span>
          </div>
        </div>

        <!-- Interactive Menubar Simulator Component -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4 font-mono text-xs">
          
          <!-- Card 1: Today's Focus -->
          <div class="p-4 rounded-xl bg-white/[0.03] border border-white/5 flex flex-col justify-between">
            <div class="flex items-center justify-between text-slate-400 mb-2">
              <span class="font-sans font-semibold text-slate-200">Today's Deep Work</span>
              <span class="text-sky-400">⏱️ ACTIVE</span>
            </div>
            <div class="text-3xl font-extrabold text-white tracking-tight my-2 font-sans" id="hero-timer">
              04h 28m 14s
            </div>
            <div class="flex items-center justify-between text-[11px] text-slate-400 border-t border-white/5 pt-2">
              <span>Human Coding: <b class="text-sky-300">2h 15m</b></span>
              <span>AGI Agents: <b class="text-purple-300">2h 13m</b></span>
            </div>
          </div>

          <!-- Card 2: Autonomous Agent Telemetry -->
          <div class="p-4 rounded-xl bg-white/[0.03] border border-white/5 flex flex-col justify-between">
            <div class="flex items-center justify-between text-slate-400 mb-2">
              <span class="font-sans font-semibold text-slate-200">Active AI Sessions</span>
              <span class="text-purple-400">🤖 3 DETECTED</span>
            </div>
            <div class="space-y-1.5 my-1">
              <div class="flex items-center justify-between text-[11px]">
                <span class="text-slate-300 font-sans">Claude Code (Terminal)</span>
                <span class="text-emerald-400 font-mono">1h 45m</span>
              </div>
              <div class="flex items-center justify-between text-[11px]">
                <span class="text-slate-300 font-sans">Antigravity / Gemini</span>
                <span class="text-sky-400 font-mono">2h 10m</span>
              </div>
              <div class="flex items-center justify-between text-[11px]">
                <span class="text-slate-300 font-sans">Codex CLI / ZCode</span>
                <span class="text-purple-400 font-mono">33m</span>
              </div>
            </div>
            <div class="text-[10px] text-slate-500 border-t border-white/5 pt-1.5">
              Keyboard/Mouse idle detected: Auto-tracked via process IPC
            </div>
          </div>

          <!-- Card 3: Memory & Hardware Cockpit -->
          <div class="p-4 rounded-xl bg-white/[0.03] border border-white/5 flex flex-col justify-between">
            <div class="flex items-center justify-between text-slate-400 mb-2">
              <span class="font-sans font-semibold text-slate-200">Memory Purge</span>
              <span class="text-emerald-400">⚡ 1-CLICK</span>
            </div>
            <div class="my-2">
              <div class="flex items-center justify-between text-[11px] mb-1">
                <span class="text-slate-400">App Footprint:</span>
                <span class="text-emerald-300 font-bold">8.1 MB</span>
              </div>
              <div class="w-full bg-slate-800 rounded-full h-1.5 overflow-hidden">
                <div class="bg-emerald-400 h-1.5 rounded-full" style="width: 4%"></div>
              </div>
            </div>
            <button onclick="simulatePurge(this)" class="w-full py-1.5 rounded-lg bg-white/10 hover:bg-white/20 text-slate-200 font-sans text-[11px] font-semibold transition flex items-center justify-center gap-1.5">
              <span>🧹</span>
              <span class="purge-text">Purge Inactive RAM & Dev Caches</span>
            </button>
          </div>

        </div>

      </div>

    </div>

  </section>

  <!-- Section: More than a time tracker (PasteApp Horizontal Feature Section) -->
  <section id="features" class="relative z-10 py-20 px-6 border-t border-white/5 max-w-6xl mx-auto">
    <div class="text-center max-w-3xl mx-auto mb-16">
      <h2 class="text-xs uppercase font-mono tracking-widest text-sky-400 mb-3">Next-Gen Architecture</h2>
      <p class="text-3xl sm:text-5xl font-extrabold text-white tracking-tight">More than a time tracker.</p>
      <p class="text-slate-400 text-base sm:text-lg mt-4">
        Paste revolutionized clipboard management with seamless native craft. ERLÍK does the same for developer telemetry, focus ergonomics, and AI workflows.
      </p>
    </div>

    <!-- Feature Grid / Carousel Cards -->
    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
      
      <!-- Card 1 -->
      <div class="apple-glass rounded-3xl p-8 transition duration-300 hover:scale-[1.01] flex flex-col justify-between">
        <div>
          <div class="w-12 h-12 rounded-2xl bg-sky-500/10 border border-sky-500/20 flex items-center justify-center text-2xl mb-6">
            ⚡
          </div>
          <h3 class="text-2xl font-bold text-white mb-3">Zero-RAM Swift Native Core</h3>
          <p class="text-slate-400 leading-relaxed text-sm mb-6">
            Unlike legacy trackers that bundle full Chrome/Electron engines (eating 200–400MB of RAM and draining battery), ERLÍK runs directly on macOS Mach APIs. It operates silently in the menubar, using only <span class="text-sky-300 font-mono font-semibold">~8 MB</span> of memory.
          </p>
        </div>
        <div class="p-4 rounded-2xl bg-black/40 border border-white/5 font-mono text-xs text-slate-300">
          <div class="flex justify-between py-1 border-b border-white/5">
            <span class="text-slate-400">ERLÍK (Swift ARM64):</span>
            <span class="text-emerald-400 font-bold">~8.1 MB RAM</span>
          </div>
          <div class="flex justify-between py-1 border-b border-white/5">
            <span class="text-slate-400">ActivityWatch (Qt/Python):</span>
            <span class="text-rose-400">~220 MB RAM</span>
          </div>
          <div class="flex justify-between py-1">
            <span class="text-slate-400">RescueTime (Electron):</span>
            <span class="text-rose-400">~180 MB RAM</span>
          </div>
        </div>
      </div>

      <!-- Card 2 -->
      <div class="apple-glass rounded-3xl p-8 transition duration-300 hover:scale-[1.01] flex flex-col justify-between">
        <div>
          <div class="w-12 h-12 rounded-2xl bg-purple-500/10 border border-purple-500/20 flex items-center justify-center text-2xl mb-6">
            🤖
          </div>
          <h3 class="text-2xl font-bold text-white mb-3">Autonomous AGI & Agent Telemetry</h3>
          <p class="text-slate-400 leading-relaxed text-sm mb-6">
            When you code with autonomous agents, your hands leave the keyboard while work continues. ERLÍK detects Claude Code, Codex, Antigravity, OpenClaw, and terminal tasks even when idle, quantifying your exact synthetic vs. human ratio.
          </p>
        </div>
        <div class="p-4 rounded-2xl bg-black/40 border border-white/5 font-mono text-xs text-slate-300 space-y-2">
          <div class="flex items-center justify-between text-purple-300">
            <span>Synthetic Coding Ratio:</span>
            <span class="font-bold">48.2%</span>
          </div>
          <div class="w-full bg-slate-800 rounded-full h-2 overflow-hidden flex">
            <div class="bg-sky-400 h-2" style="width: 52%" title="Human Focus"></div>
            <div class="bg-purple-500 h-2" style="width: 48%" title="Agent Telemetry"></div>
          </div>
          <div class="flex justify-between text-[11px] text-slate-400">
            <span>🔵 52% Human</span>
            <span>🟣 48% Autonomous Agents</span>
          </div>
        </div>
      </div>

      <!-- Card 3 -->
      <div class="apple-glass rounded-3xl p-8 transition duration-300 hover:scale-[1.01] flex flex-col justify-between">
        <div>
          <div class="w-12 h-12 rounded-2xl bg-amber-500/10 border border-amber-500/20 flex items-center justify-center text-2xl mb-6">
            🐺
          </div>
          <h3 class="text-2xl font-bold text-white mb-3">Menubar Superpowers & Cache Cleaner</h3>
          <p class="text-slate-400 leading-relaxed text-sm mb-6">
            Stay focused right from your notch or menubar. View live timers, switch projects, and free up gigabytes of accumulated Xcode derived data, Node modules caches, and inactive RAM with a single click.
          </p>
        </div>
        <div class="p-3 rounded-2xl bg-black/40 border border-white/5 flex items-center justify-between text-xs font-mono">
          <div class="flex items-center gap-2 text-slate-300">
            <span class="w-2 h-2 rounded-full bg-amber-400"></span>
            <span>Xcode / DerivedData / Caches</span>
          </div>
          <span class="text-emerald-400 font-semibold">-14.2 GB Cleaned</span>
        </div>
      </div>

      <!-- Card 4 -->
      <div class="apple-glass rounded-3xl p-8 transition duration-300 hover:scale-[1.01] flex flex-col justify-between">
        <div>
          <div class="w-12 h-12 rounded-2xl bg-rose-500/10 border border-rose-500/20 flex items-center justify-center text-2xl mb-6">
            🍅
          </div>
          <h3 class="text-2xl font-bold text-white mb-3">Ergonomic Health & 20-20-20 Rules</h3>
          <p class="text-slate-400 leading-relaxed text-sm mb-6">
            Prevent eye strain and developer burnout. Native discreet notifications nudge you to rest your eyes on distant objects every 20 minutes, backed by an integrated Pomodoro interval engine.
          </p>
        </div>
        <div class="p-3 rounded-2xl bg-black/40 border border-white/5 flex items-center justify-between text-xs font-mono">
          <div class="flex items-center gap-2 text-slate-300">
            <span class="w-2 h-2 rounded-full bg-rose-400"></span>
            <span>20-20-20 Optical Wellness</span>
          </div>
          <span class="text-sky-300">Next break in 14:20</span>
        </div>
      </div>

    </div>
  </section>

  <!-- Section: Built for how you work (PasteApp Interactive Segmented Tabs) -->
  <section id="built-for" class="relative z-10 py-20 px-6 border-t border-white/5 max-w-6xl mx-auto">
    <div class="text-center max-w-3xl mx-auto mb-12">
      <h2 class="text-xs uppercase font-mono tracking-widest text-purple-400 mb-3">Tailored Experience</h2>
      <p class="text-3xl sm:text-5xl font-extrabold text-white tracking-tight">Built for how you work.</p>
    </div>

    <!-- Audience Segmented Switcher Pills -->
    <div class="flex items-center justify-center gap-2 sm:gap-4 max-w-2xl mx-auto mb-12 flex-wrap">
      <button onclick="selectTab('devs', this)" class="audience-tab apple-pill-active px-5 py-2.5 rounded-full text-xs sm:text-sm font-semibold border border-white/10 transition">
        Developers
      </button>
      <button onclick="selectTab('agents', this)" class="audience-tab text-slate-400 hover:text-white px-5 py-2.5 rounded-full text-xs sm:text-sm font-semibold border border-transparent transition">
        AI & AGI Engineers
      </button>
      <button onclick="selectTab('remote', this)" class="audience-tab text-slate-400 hover:text-white px-5 py-2.5 rounded-full text-xs sm:text-sm font-semibold border border-transparent transition">
        Remote & SSH
      </button>
      <button onclick="selectTab('founders', this)" class="audience-tab text-slate-400 hover:text-white px-5 py-2.5 rounded-full text-xs sm:text-sm font-semibold border border-transparent transition">
        Founders & Teams
      </button>
    </div>

    <!-- Tab Content Display Area -->
    <div class="apple-glass rounded-3xl p-8 sm:p-12 max-w-4xl mx-auto border border-white/10">
      
      <!-- Tab 1: Developers -->
      <div id="tab-devs" class="tab-panel">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-8 items-center">
          <div>
            <span class="text-xs font-mono text-sky-400 uppercase tracking-wider">For Software Engineers</span>
            <h3 class="text-2xl sm:text-3xl font-bold text-white mt-2 mb-4">Deep Git branch context without interruption.</h3>
            <p class="text-slate-400 text-sm leading-relaxed mb-6">
              Track exactly how much time you spend on each branch, repo, and editor (VS Code, Xcode, Cursor, Neovim, JetBrains). Everything is mapped seamlessly to your commit logs without any manual start/stop friction.
            </p>
            <ul class="space-y-2 text-xs text-slate-300 font-mono">
              <li class="flex items-center gap-2"><span class="text-emerald-400">✓</span> Automatic active Git branch detection</li>
              <li class="flex items-center gap-2"><span class="text-emerald-400">✓</span> Project-level aggregation & daily diffs</li>
              <li class="flex items-center gap-2"><span class="text-emerald-400">✓</span> Zero CPU overhead while debugging heavy builds</li>
            </ul>
          </div>
          <div class="p-6 rounded-2xl bg-black/60 border border-white/5 font-mono text-xs space-y-3">
            <div class="text-slate-500"># Current Project Telemetry</div>
            <div class="flex justify-between"><span class="text-sky-300">probex/immostory</span><span class="text-slate-400">3h 42m</span></div>
            <div class="flex justify-between"><span class="text-purple-300">branch: feat/ag-telemetry</span><span class="text-slate-400">2h 10m</span></div>
            <div class="flex justify-between"><span class="text-emerald-300">VS Code + Neovim</span><span class="text-slate-400">98% focus</span></div>
          </div>
        </div>
      </div>

      <!-- Tab 2: AI & AGI Engineers -->
      <div id="tab-agents" class="tab-panel hidden">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-8 items-center">
          <div>
            <span class="text-xs font-mono text-purple-400 uppercase tracking-wider">For AI Pioneers</span>
            <h3 class="text-2xl sm:text-3xl font-bold text-white mt-2 mb-4">Measure synthetic vs. human engineering hours.</h3>
            <p class="text-slate-400 text-sm leading-relaxed mb-6">
              The modern engineer orchestrates Claude Code, Antigravity, and Codex in parallel. ERLÍK tracks autonomous agent work and gives you visibility into your AI leverage and estimated token spend.
            </p>
            <ul class="space-y-2 text-xs text-slate-300 font-mono">
              <li class="flex items-center gap-2"><span class="text-purple-400">✓</span> Multi-agent concurrency monitoring</li>
              <li class="flex items-center gap-2"><span class="text-purple-400">✓</span> Claude Code, Codex, Antigravity & OpenClaw hooks</li>
              <li class="flex items-center gap-2"><span class="text-purple-400">✓</span> Model spend & token cost estimate calculator</li>
            </ul>
          </div>
          <div class="p-6 rounded-2xl bg-black/60 border border-white/5 font-mono text-xs space-y-3">
            <div class="text-slate-500"># AGI Agent Cockpit</div>
            <div class="flex justify-between"><span class="text-purple-400">Claude 3.7 Sonnet</span><span class="text-emerald-400">Active (45m)</span></div>
            <div class="flex justify-between"><span class="text-sky-400">Antigravity Multi-agent</span><span class="text-emerald-400">Active (1h 12m)</span></div>
            <div class="flex justify-between"><span class="text-amber-400">Synthetic Multiplier</span><span class="text-white font-bold">3.4x leverage</span></div>
          </div>
        </div>
      </div>

      <!-- Tab 3: Remote & SSH -->
      <div id="tab-remote" class="tab-panel hidden">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-8 items-center">
          <div>
            <span class="text-xs font-mono text-emerald-400 uppercase tracking-wider">For Terminal Nomads</span>
            <h3 class="text-2xl sm:text-3xl font-bold text-white mt-2 mb-4">Track long-running terminal and remote sessions.</h3>
            <p class="text-slate-400 text-sm leading-relaxed mb-6">
              Working remotely via SSH, tmux, or watching a long deployment? Typical trackers log you as "Idle" after 3 minutes. ERLÍK inspects terminal process activity and active socket sessions to keep your streak alive.
            </p>
            <ul class="space-y-2 text-xs text-slate-300 font-mono">
              <li class="flex items-center gap-2"><span class="text-emerald-400">✓</span> Zero false "Idle" states during remote compilation</li>
              <li class="flex items-center gap-2"><span class="text-emerald-400">✓</span> SSH & tmux session continuity</li>
              <li class="flex items-center gap-2"><span class="text-emerald-400">✓</span> Works across Ghostty, iTerm2, Kitty & Apple Terminal</li>
            </ul>
          </div>
          <div class="p-6 rounded-2xl bg-black/60 border border-white/5 font-mono text-xs space-y-3">
            <div class="text-slate-500"># Remote Session Monitor</div>
            <div class="flex justify-between"><span class="text-emerald-400">ssh prod-server-hetzner</span><span class="text-slate-300">Connected</span></div>
            <div class="flex justify-between"><span class="text-slate-400">Keyboard Input:</span><span class="text-amber-300">0 ops/min (Watch mode)</span></div>
            <div class="flex justify-between"><span class="text-slate-400">State:</span><span class="text-emerald-400 font-bold">Deep Remote Focus</span></div>
          </div>
        </div>
      </div>

      <!-- Tab 4: Founders & Teams -->
      <div id="tab-founders" class="tab-panel hidden">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-8 items-center">
          <div>
            <span class="text-xs font-mono text-amber-400 uppercase tracking-wider">For Solo Founders & Leads</span>
            <h3 class="text-2xl sm:text-3xl font-bold text-white mt-2 mb-4">Automated focus proof and streak reports.</h3>
            <p class="text-slate-400 text-sm leading-relaxed mb-6">
              Generate daily and weekly markdown summaries, send automated progress emails, and export raw ActivityWatch-compatible JSON whenever you need client audit trails or personal retrospective reviews.
            </p>
            <ul class="space-y-2 text-xs text-slate-300 font-mono">
              <li class="flex items-center gap-2"><span class="text-amber-400">✓</span> Daily email & Discord webhook summaries</li>
              <li class="flex items-center gap-2"><span class="text-amber-400">✓</span> ActivityWatch JSON export compatibility</li>
              <li class="flex items-center gap-2"><span class="text-amber-400">✓</span> GitHub commit correlation graphs</li>
            </ul>
          </div>
          <div class="p-6 rounded-2xl bg-black/60 border border-white/5 font-mono text-xs space-y-3">
            <div class="text-slate-500"># Daily Focus Streak</div>
            <div class="flex justify-between"><span class="text-amber-300">Current Streak:</span><span class="text-white font-bold">14 Days 🔥</span></div>
            <div class="flex justify-between"><span class="text-slate-400">Total Billable Hours:</span><span class="text-emerald-400 font-bold">6.8h Today</span></div>
            <div class="flex justify-between"><span class="text-slate-400">Report Status:</span><span class="text-sky-300">Ready to Export</span></div>
          </div>
        </div>
      </div>

    </div>

  </section>

  <!-- Section: Bring your telemetry to AI (PasteApp AI section replica) -->
  <section id="ai-tools" class="relative z-10 py-20 px-6 border-t border-white/5 max-w-6xl mx-auto">
    <div class="apple-glass rounded-3xl p-8 sm:p-14 border border-white/10 relative overflow-hidden">
      
      <div class="max-w-2xl relative z-10">
        <div class="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-purple-500/10 border border-purple-500/20 text-purple-300 text-xs font-mono mb-6">
          <span>🧠</span>
          <span>Model Context Protocol (MCP) Ready</span>
        </div>
        <h2 class="text-3xl sm:text-5xl font-extrabold text-white tracking-tight mb-4">
          Bring your Mac telemetry<br>into your AI tools.
        </h2>
        <p class="text-slate-400 text-base sm:text-lg leading-relaxed mb-8">
          Connect your local ERLÍK telemetry directly to Claude Desktop, Cursor, or your personal AI agents. Ask your assistant: <i>"What did I code yesterday across repos?"</i> or <i>"How much time did my tests take this week?"</i>
        </p>

        <div class="flex flex-wrap gap-4">
          <a href="https://github.com/halilertekin/erlik#-mcp-integration" target="_blank" class="px-6 py-3 rounded-xl bg-purple-600 hover:bg-purple-500 text-white font-semibold transition shadow-lg shadow-purple-600/20 text-xs sm:text-sm">
            See ERLÍK for AI &rarr;
          </a>
          <div class="px-4 py-3 rounded-xl bg-white/5 border border-white/10 font-mono text-xs text-purple-300 flex items-center">
            npx -y @erlik/mcp-server
          </div>
        </div>
      </div>

      <!-- Decorative AI Badge Backdrop -->
      <div class="absolute -right-10 -bottom-10 opacity-10 sm:opacity-20 text-[200px] select-none pointer-events-none">
        🤖
      </div>

    </div>
  </section>

  <!-- Section: Private by Design (Apple-style Security Shield) -->
  <section id="privacy" class="relative z-10 py-20 px-6 border-t border-white/5 max-w-5xl mx-auto text-center">
    <div class="w-16 h-16 rounded-3xl bg-emerald-500/10 border border-emerald-500/20 flex items-center justify-center text-3xl mx-auto mb-6">
      🛡️
    </div>
    <h2 class="text-xs uppercase font-mono tracking-widest text-emerald-400 mb-3">Privacy First</h2>
    <p class="text-3xl sm:text-5xl font-extrabold text-white tracking-tight">Private by design.</p>
    <p class="text-slate-400 text-base sm:text-lg max-w-2xl mx-auto mt-4 leading-relaxed">
      Your code, window titles, and work habits are strictly confidential. ERLÍK stores 100% of data in your local macOS Application Support folder. No cloud servers, no tracker cookies, no external telemetry.
    </p>

    <div class="mt-8 inline-block px-5 py-3 rounded-2xl bg-white/5 border border-white/10 font-mono text-xs text-slate-300">
      ~/Library/Application Support/erlik/erlik.db
    </div>
  </section>

  <!-- Section: Architecture Comparison (ERLIK vs Electron vs Legacy) -->
  <section id="comparison" class="relative z-10 py-20 px-6 border-t border-white/5 max-w-5xl mx-auto">
    <div class="text-center mb-12">
      <h2 class="text-xs uppercase font-mono tracking-widest text-sky-400 mb-3">Benchmark</h2>
      <p class="text-3xl sm:text-4xl font-extrabold text-white tracking-tight">Engineering Comparison</p>
    </div>

    <div class="apple-glass rounded-3xl p-6 sm:p-8 overflow-hidden border border-white/10">
      <div class="overflow-x-auto">
        <table class="w-full text-xs font-mono">
          <thead>
            <tr class="border-b border-white/10 text-slate-400">
              <th class="py-3 text-left font-semibold font-sans text-sm">Specification</th>
              <th class="py-3 text-center text-sky-400 font-bold bg-sky-500/10 rounded-t-xl">🐺 ERLÍK (Pure Swift)</th>
              <th class="py-3 text-center font-normal text-slate-400">ActivityWatch</th>
              <th class="py-3 text-center font-normal text-slate-400">RescueTime</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-white/5">
            <tr>
              <td class="py-3 text-slate-200 font-sans">Binary Architecture</td>
              <td class="py-3 text-center text-emerald-400 font-bold bg-sky-500/5">Native ARM64 Mach-O</td>
              <td class="py-3 text-center text-slate-400">Python + Qt Bundle</td>
              <td class="py-3 text-center text-rose-400">Electron / WebKit</td>
            </tr>
            <tr>
              <td class="py-3 text-slate-200 font-sans">Active Memory (RAM)</td>
              <td class="py-3 text-center text-emerald-400 font-bold bg-sky-500/5">~8.1 MB</td>
              <td class="py-3 text-center text-rose-400">~220 MB</td>
              <td class="py-3 text-center text-rose-400">~180 MB</td>
            </tr>
            <tr>
              <td class="py-3 text-slate-200 font-sans">CPU & Battery Drain</td>
              <td class="py-3 text-center text-emerald-400 font-bold bg-sky-500/5">&lt; 0.01% (Zero drain)</td>
              <td class="py-3 text-center text-amber-400">1.5% – 3.0%</td>
              <td class="py-3 text-center text-amber-400">1.0% – 4.0%</td>
            </tr>
            <tr>
              <td class="py-3 text-slate-200 font-sans">Autonomous AGI Agent Tracking</td>
              <td class="py-3 text-center text-emerald-400 font-bold bg-sky-500/5">Built-in (Claude/Codex/AG)</td>
              <td class="py-3 text-center text-slate-600">None</td>
              <td class="py-3 text-center text-slate-600">None</td>
            </tr>
            <tr>
              <td class="py-3 text-slate-200 font-sans">RAM Purge & Xcode Cache Cleaner</td>
              <td class="py-3 text-center text-emerald-400 font-bold bg-sky-500/5">Integrated 1-Click</td>
              <td class="py-3 text-center text-slate-600">None</td>
              <td class="py-3 text-center text-slate-600">None</td>
            </tr>
            <tr>
              <td class="py-3 text-slate-200 font-sans">Data Privacy</td>
              <td class="py-3 text-center text-emerald-400 font-bold bg-sky-500/5">100% On-Device SQLite</td>
              <td class="py-3 text-center text-emerald-400">Local</td>
              <td class="py-3 text-center text-rose-400">Third-party Cloud</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </section>

  <!-- Final CTA (PasteApp style) -->
  <section class="relative z-10 py-24 px-6 border-t border-white/5 text-center max-w-4xl mx-auto">
    <h2 class="text-3xl sm:text-5xl font-extrabold text-white tracking-tight mb-6">
      Install ERLÍK on your Mac in seconds.
    </h2>
    <p class="text-slate-400 text-base sm:text-lg mb-10 max-w-xl mx-auto">
      Zero config required. Free and open source under the MIT License.
    </p>
    
    <div class="flex flex-col sm:flex-row items-center justify-center gap-4">
      <button onclick="copyBrew('brew install halilertekin/erlik/erlik', this)" class="px-8 py-4 rounded-2xl bg-white text-black font-bold hover:bg-slate-200 transition shadow-2xl flex items-center gap-2">
        <span>brew install halilertekin/erlik/erlik</span>
        <span class="btn-icon">📋</span>
      </button>
      <a href="https://github.com/halilertekin/erlik" target="_blank" class="px-8 py-4 rounded-2xl bg-white/5 hover:bg-white/10 border border-white/10 text-white font-bold transition">
        View on GitHub
      </a>
    </div>
  </section>

  <!-- Footer -->
  <footer class="relative z-10 border-t border-white/5 py-10 text-center text-xs text-slate-500">
    <div class="max-w-6xl mx-auto px-6 flex flex-col sm:flex-row items-center justify-between gap-6">
      <div class="flex items-center gap-3">
        <span class="text-lg">🐺</span>
        <span class="text-slate-200 font-bold">ERLÍK</span>
        <span>•</span>
        <span>Crafted with Apple-native rigor by <a href="https://ertekin.me" target="_blank" class="text-slate-300 hover:text-white underline">Halil Ertekin</a></span>
      </div>
      <div class="flex items-center gap-6 font-mono text-[11px]">
        <a href="https://github.com/halilertekin/erlik" target="_blank" class="hover:text-sky-400 transition">GitHub</a>
        <a href="https://github.com/halilertekin/homebrew-erlik" target="_blank" class="hover:text-sky-400 transition">Homebrew Tap</a>
        <a href="https://erlik.ertekin.workers.dev/api/health" target="_blank" class="hover:text-sky-400 transition">Edge API</a>
        <span class="text-slate-600">erlik.be</span>
      </div>
    </div>
  </footer>

  <!-- Interactive Scripts -->
  <script>
    // Copy Command Helper
    function copyBrew(text, btn) {
      navigator.clipboard.writeText(text).then(() => {
        const textSpan = btn.querySelector('.btn-text');
        const iconSpan = btn.querySelector('.btn-icon');
        if (textSpan) textSpan.innerText = 'Copied!';
        if (iconSpan) iconSpan.innerText = '✓';
        setTimeout(() => {
          if (textSpan) textSpan.innerText = 'Copy';
          if (iconSpan) iconSpan.innerText = '📋';
        }, 2200);
      });
    }

    // Segmented Tab Switcher
    function selectTab(tabId, el) {
      document.querySelectorAll('.audience-tab').forEach(btn => {
        btn.classList.remove('apple-pill-active');
        btn.classList.add('text-slate-400', 'border-transparent');
      });
      el.classList.add('apple-pill-active');
      el.classList.remove('text-slate-400', 'border-transparent');

      document.querySelectorAll('.tab-panel').forEach(panel => {
        panel.classList.add('hidden');
      });
      const active = document.getElementById('tab-' + tabId);
      if (active) active.classList.remove('hidden');
    }

    // Simulate RAM Purge
    function simulatePurge(btn) {
      const span = btn.querySelector('.purge-text');
      span.innerText = 'Purging macOS Inactive Cache...';
      btn.classList.add('opacity-70', 'pointer-events-none');
      setTimeout(() => {
        span.innerText = 'Cleaned 3.4 GB Inactive RAM ✓';
        btn.classList.remove('opacity-70');
        setTimeout(() => {
          span.innerText = 'Purge Inactive RAM & Dev Caches';
          btn.classList.remove('pointer-events-none');
        }, 3000);
      }, 1200);
    }

    // Live Clock increment
    let sec = 14;
    setInterval(() => {
      sec++;
      const timer = document.getElementById('hero-timer');
      if (timer) {
        const s = sec % 60;
        const m = 28 + Math.floor(sec / 60);
        timer.innerText = '04h ' + m + 'm ' + (s < 10 ? '0' : '') + s + 's';
      }
    }, 1000);
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
print("Worker script written successfully! Size:", len(content))
