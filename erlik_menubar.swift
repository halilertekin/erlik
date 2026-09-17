import Cocoa
import Foundation

// MARK: - Internationalization (i18n) Dictionary
enum ErlikLang: String {
    case tr, en, nl
}

struct I18n {
    static func t(_ key: String, lang: ErlikLang) -> String {
        let dict: [String: [ErlikLang: String]] = [
            "title": [.tr: "🐺 ERLİK Sistem & Odak Zekâsı", .en: "🐺 ERLİK System & Focus Intelligence", .nl: "🐺 ERLİK Systeem & Focus Intelligentie"],
            "open_dashboard": [.tr: "📊 Web Dashboard'u Aç", .en: "📊 Open Web Dashboard", .nl: "📊 Open Web Dashboard"],
            "pomodoro": [.tr: "🍅 Pomodoro Başlat/Durdur", .en: "🍅 Toggle Pomodoro", .nl: "🍅 Schakel Pomodoro In/Uit"],
            "purge_ram": [.tr: "🧹 RAM & Önbellek Temizle (Purge)", .en: "🧹 Free RAM & Purge Cache", .nl: "🧹 RAM Vrijmaken & Cache Opschonen"],
            "toggle_hardware": [.tr: "👁️ Disk/RAM Göster/Gizle", .en: "👁️ Toggle Disk/RAM Display", .nl: "👁️ Toon/Verberg Schijf & RAM"],
            "lang_select": [.tr: "🌐 Dil / Language / Taal", .en: "🌐 Dil / Language / Taal", .nl: "🌐 Dil / Language / Taal"],
            "quit": [.tr: "Çıkış", .en: "Quit", .nl: "Afsluiten"],
            "purging": [.tr: "Temizleniyor...", .en: "Purging...", .nl: "Opschonen..."],
            "purged": [.tr: "RAM Başarıyla Rahatlatıldı!", .en: "RAM Purged Successfully!", .nl: "RAM Succesvol Opgeschoond!"]
        ]
        return dict[key]?[lang] ?? key
    }
}

class ErlikMenuBarApp: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var timer: Timer?
    
    // User Preferences
    var showHardwareMetrics: Bool = true
    var currentLang: ErlikLang = .tr

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        loadPreferences()
        buildMenu()
        updateStatus()

        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(updateStatus), userInfo: nil, repeats: true)
    }

    func loadPreferences() {
        if let savedShow = UserDefaults.standard.object(forKey: "erlik_show_hardware") as? Bool {
            showHardwareMetrics = savedShow
        }
        if let savedLang = UserDefaults.standard.string(forKey: "erlik_lang"),
           let lang = ErlikLang(rawValue: savedLang) {
            currentLang = lang
        }
    }

    func savePreferences() {
        UserDefaults.standard.set(showHardwareMetrics, forKey: "erlik_show_hardware")
        UserDefaults.standard.set(currentLang.rawValue, forKey: "erlik_lang")
    }

    func buildMenu() {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: I18n.t("title", lang: currentLang), action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: I18n.t("open_dashboard", lang: currentLang), action: #selector(openDashboard), keyEquivalent: "d"))
        menu.addItem(NSMenuItem(title: I18n.t("pomodoro", lang: currentLang), action: #selector(togglePomodoro), keyEquivalent: "p"))
        menu.addItem(NSMenuItem(title: I18n.t("purge_ram", lang: currentLang), action: #selector(purgeRAM), keyEquivalent: "r"))
        menu.addItem(NSMenuItem.separator())
        
        let toggleHW = NSMenuItem(title: "\(I18n.t("toggle_hardware", lang: currentLang)) [\(showHardwareMetrics ? "✓" : "✗")]", action: #selector(toggleHardware), keyEquivalent: "h")
        menu.addItem(toggleHW)

        // Dil Seçim Alt Menüsü
        let langMenu = NSMenu()
        let trItem = NSMenuItem(title: "🇹🇷 Türkçe \(currentLang == .tr ? "✓" : "")", action: #selector(setLangTR), keyEquivalent: "")
        let enItem = NSMenuItem(title: "🇬🇧 English \(currentLang == .en ? "✓" : "")", action: #selector(setLangEN), keyEquivalent: "")
        let nlItem = NSMenuItem(title: "🇳🇱 Nederlands \(currentLang == .nl ? "✓" : "")", action: #selector(setLangNL), keyEquivalent: "")
        langMenu.addItem(trItem)
        langMenu.addItem(enItem)
        langMenu.addItem(nlItem)

        let langParent = NSMenuItem(title: I18n.t("lang_select", lang: currentLang), action: nil, keyEquivalent: "")
        langParent.submenu = langMenu
        menu.addItem(langParent)

        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: I18n.t("quit", lang: currentLang), action: #selector(quit), keyEquivalent: "q"))

        statusItem?.menu = menu
    }

    func getDiskFreeSpace() -> String {
        do {
            let attrs = try FileManager.default.attributesOfFileSystem(forPath: "/System/Volumes/Data")
            if let freeBytes = attrs[.systemFreeSize] as? Int64 {
                let gb = Double(freeBytes) / 1_073_741_824.0
                return String(format: "%.0fG", gb)
            }
        } catch {}
        return "--"
    }

    func getRAMUsage() -> String {
        var stats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size)
        let kerr = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }
        if kerr == KERN_SUCCESS {
            let pageSize = UInt64(vm_kernel_page_size)
            let active = UInt64(stats.active_count) * pageSize
            let wired = UInt64(stats.wire_count) * pageSize
            let compressed = UInt64(stats.compressor_page_count) * pageSize
            let usedBytes = active + wired + compressed
            let totalBytes = ProcessInfo.processInfo.physicalMemory
            let usedGB = Double(usedBytes) / 1_073_741_824.0
            let pct = Double(usedBytes) / Double(totalBytes) * 100.0
            return String(format: "%.0f%% (%.0fG)", pct, usedGB)
        }
        return "--"
    }

    @objc func updateStatus() {
        let diskStr = getDiskFreeSpace()
        let ramStr = getRAMUsage()

        guard let url = URL(string: "http://127.0.0.1:5757/api/stats?range=day") else { return }
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self = self else { return }
            var timeStr = "0 dk"
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let totalSec = json["total_active_seconds"] as? Int {
                let mins = totalSec / 60
                let hrs = Double(mins) / 60.0
                let hrUnit = self.currentLang == .nl ? "u" : (self.currentLang == .en ? "h" : "sa")
                let minUnit = self.currentLang == .nl ? "m" : (self.currentLang == .en ? "m" : "dk")
                timeStr = mins > 90 ? String(format: "%.1f %@", hrs, hrUnit) : "\(mins) \(minUnit)"
            }
            
            DispatchQueue.main.async {
                if self.showHardwareMetrics {
                    self.statusItem?.button?.title = "🐺 \(timeStr) | 💾 \(diskStr) | 🧠 \(ramStr)"
                } else {
                    self.statusItem?.button?.title = "🐺 \(timeStr)"
                }
            }
        }.resume()
    }

    @objc func toggleHardware() {
        showHardwareMetrics.toggle()
        savePreferences()
        buildMenu()
        updateStatus()
    }

    @objc func setLangTR() { currentLang = .tr; savePreferences(); buildMenu(); updateStatus() }
    @objc func setLangEN() { currentLang = .en; savePreferences(); buildMenu(); updateStatus() }
    @objc func setLangNL() { currentLang = .nl; savePreferences(); buildMenu(); updateStatus() }

    @objc func purgeRAM() {
        let originalTitle = statusItem?.button?.title
        statusItem?.button?.title = "🐺 🧹 \(I18n.t("purging", lang: currentLang))"

        DispatchQueue.global(qos: .userInitiated).async {
            // macOS Disk Cache ve inaktif RAM'i boşalt
            let task = Process()
            task.executableURL = URL(fileURLWithPath: "/usr/sbin/purge")
            try? task.run()
            task.waitUntilExit()

            DispatchQueue.main.async {
                self.updateStatus()
                // Bildirim gönder
                let note = NSUserNotification()
                note.title = "ERLIK"
                note.informativeText = I18n.t("purged", lang: self.currentLang)
                NSUserNotificationCenter.default.deliver(note)
            }
        }
    }

    @objc func openDashboard() {
        if let url = URL(string: "http://localhost:5757") {
            NSWorkspace.shared.open(url)
        }
    }

    @objc func togglePomodoro() {
        openDashboard()
    }

    @objc func quit() {
        NSApplication.shared.terminate(self)
    }
}

let app = NSApplication.shared
let delegate = ErlikMenuBarApp()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
