# 🐺 ERLİK — Open Source Native Mac Activity & Focus Intelligence

<p align="center">
  <img src="assets/erlik_logo.jpg" width="180" height="180" alt="ERLIK Logo" style="border-radius: 28px; box-shadow: 0 10px 25px rgba(0,0,0,0.5);">
</p>

<p align="center">
  <b>Apple Silicon (ARM64) İçin Açık Kaynak, Sıfır Bellek Tüketimli Zaman, IDE, AGI ve Odak Takipçisi</b><br>
  <i>İsmini Türk mitolojisinin derinlik ve kayıtlar hükümdarı Erlik Han'dan alır.</i>
</p>

<p align="center">
  <a href="#-about--hakkında">About / Hakkında</a> •
  <a href="#-özellikler">Özellikler</a> •
  <a href="#-ide--agi-ajan-algılama">IDE & AGI Algılama</a> •
  <a href="#-activitywatch-farkı">ActivityWatch Farkı</a> •
  <a href="#-hızlı-başlangıç">Hızlı Başlangıç</a> •
  <a href="#-katkıda-bulunma">Katkıda Bulunma</a>
</p>

---

## 📖 About / Hakkında

**ERLİK**, modern yazılımcılar, araştırmacılar ve otonom AI ile çalışan mühendisler için geliştirilmiş, **saf Apple Silicon (ARM64 Swift)** tabanlı, ultra hafif bir aktivite ve odak zekâsı platformudur. 

ActivityWatch veya RescueTime gibi ağır Python/Electron/Qt altyapılarıyla çalışan araçların aksine; ERLİK, macOS'un çekirdek API'lerine (`IOHIDSystem`, `NSWorkspace`, `AppleScript`) doğrudan bağlanır. Bilgisayarınızı yormadan (~8 MB RAM), hiçbir telemetriyi dışarı sızdırmadan (tamamen Local-First) çalışır.

### 🌟 Neden ERLİK?
- 🔋 **Sıfır CPU & Pil Yükü:** Gün boyu çalışsa bile pil döngünüzü tüketmez.
- 🔒 **%100 Gizlilik & Local-First:** Bütün veriler Mac'inizdeki yerel SQLite veritabanında (`erlik.db`) saklanır.
- 🤖 **Yeni Nesil AGI & Agent Takibi:** Antigravity, Claude Code, Cursor, Windsurf, Hermes ve otonom ajanlarla geçirilen süreleri otomatik ayrıştırır.
- 🌍 **3 Dil Desteği:** Türkçe, İngilizce ve Felemenkçe (Nederlands) hem Status Bar hem de Web Dashboard'da anlık değiştirilebilir.

---

## ⚡ Özellikler

- **Saf Apple Silicon Native (ARM64):** Rosetta 2 gerektirmez. M1/M2/M3/M4 mimarisine tam optimize.
- **Gerçek Zamanlı Donanımsal AFK:** Klavye ve fareyi bıraktığınız an macOS IOHID donanım sayacı ile çalışma süresini dondurur.
- **Modern & Tam Duyarlı (Responsive) Dashboard:**
  - Mobil, tablet ve masaüstü uyumlu glassmorphism arayüz (`http://localhost:5757`).
  - **Çoklu Dil Seçimi (TR / EN / NL):** Tek tıkla Türkçe, İngilizce ve Felemenkçe arayüz geçişi.
  - Klasik `alert()` yerine modern Glass Modal ve Toast bildirimleri.
  - Günlük (24s) / Haftalık (7g) / Aylık (30g) zaman filtreleri.
  - Chart.js zaman çizelgesi ve kategori halka grafiği.
- **🧠 macOS Menubar Widget:**
  - Menü çubuğunda canlı durum: `🐺 45 dk | 💾 38G | 🧠 80%`
  - **🧹 RAM & Önbellek Temizleme:** Tek tıkla inaktif RAM ve disk önbelleklerini temizleme (`purge`).
  - **Donanım Metriklerini Gizleme:** İsteğe bağlı sade mod (sadece kurt simgesi ve odak süresi).
  - Dil menüsü (TR, EN, NL).
- **ActivityWatch Standardında Dışa Aktarma (Export):**
  - Tüm aktivitelerinizi açık kaynak formatında (Bucket / Event tabanlı JSON) tek tıkla indirin.
- **Kişiselleştirilebilir Raporlama:**
  - Dashboard üzerinden e-posta veya Discord/Slack Webhook entegrasyonu.
- **Proje & Git Branch Tespiti:**
  - Aktif pencere başlığından projeyi ve o projenin aktif `git branch`'ini otomatik tespit eder.

---

## 🛠️ IDE & AGI Ajan Algılama

ERLİK, klasik uygulamaların ötesine geçerek geliştirici ortamlarını ve otonom yapay zeka ajanlarını derinlemesine sınıflandırır:

| Kategori | Desteklenen Ortamlar & Ajanlar |
| :--- | :--- |
| **🤖 AGI & AI Ajanları** | Antigravity, Cursor, Codex, Hermes, OpenClaw, Claude Code, Windsurf, Devin, Aider, Ollama, LM Studio, ChatGPT |
| **💻 IDE & Editörler** | VS Code, Xcode, JetBrains (IntelliJ, PyCharm, WebStorm, GoLand, CLion, Rider, DataGrip), Zed, Sublime, Neovim, Emacs, Nova |
| **⚡ Terminal & CLI** | Ghostty, iTerm2, Terminal, Warp, Alacritty, Kitty, WezTerm, Hyper, tmux |
| **🎨 Tasarım & Medya** | Figma, Canva, Photoshop, Illustrator, Blender, BambuStudio, Premiere, DaVinci Resolve |
| **💬 İletişim & Chat** | Slack, Discord, Telegram, WhatsApp, Spark, Zoom, Teams, Messages |
| **📝 Notlar & Planlama** | Notion, Obsidian, Linear, Apple Notes, Craft, Reminders, Excel, Word |

---

## 📊 ActivityWatch vs ERLİK

| Özellik | ActivityWatch (macOS) | ERLİK (Native ARM64) |
| :--- | :--- | :--- |
| **Mimari & İşlemci** | Ağır Python/Qt + x86 (Rosetta ihtiyacı) | Saf Swift ARM64 (Apple Silicon Native) |
| **RAM Tüketimi** | ~150 - 300 MB | **~8 - 15 MB** |
| **Pil / Enerji Verimi** | Orta | **Maksimum (Sıfır CPU yükü)** |
| **AGI / Ajan Ayrıştırma** | Yok (hepsini tarayıcı/app sayar) | **Özel AGI & Otonom Ajan Tespiti** |
| **macOS Menubar Eklentisi**| Yok / Üçüncü parti | **Dahili Native RAM/Disk/Süre Menü Çubuğu** |
| **Arayüz** | Vue/Ağır Web | Ultra hafif Tailwind + Responsive Glass UI |
| **Çoklu Dil** | Kısıtlı | **Türkçe, English, Nederlands** |
| **Raporlama** | Eklenti gerektirir | Dahili E-Posta & Discord Webhook |

---

## 🚀 Hızlı Başlangıç

### 1. Klonlayın ve Derleyin/Başlatın
```bash
git clone https://github.com/halilertekin/erlik.git
cd erlik
./erlik.sh start
```

Tarayıcınızda açın: **[http://localhost:5757](http://localhost:5757)**

### 2. Durum Kontrolü & Durdurma
```bash
./erlik.sh status   # Servis durumunu kontrol eder
./erlik.sh stop     # Servisleri durdurur
```

---

## 📦 Dışa Aktarma (Export)

Dashboard üzerindeki **"Dışa Aktar"** butonuna basarak veya doğrudan API üzerinden tüm geçmişi JSON olarak alabilirsiniz:
```bash
curl http://localhost:5757/api/export > erlik-backup.json
```

---

## 📜 Lisans
MIT License — Açık kaynak ve topluluk katkılarına açıktır!
