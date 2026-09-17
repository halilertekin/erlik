import Cocoa
import Foundation

class ErlikMenuBarApp: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var timer: Timer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        updateStatus()

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "🐺 ERLİK System & Focus Intelligence", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "📊 Web Dashboard'u Aç", action: #selector(openDashboard), keyEquivalent: "d"))
        menu.addItem(NSMenuItem(title: "🍅 Pomodoro Başlat/Durdur", action: #selector(togglePomodoro), keyEquivalent: "p"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Çıkış", action: #selector(quit), keyEquivalent: "q"))

        statusItem?.menu = menu
        
        // Her 2 saniyede bir gerçek zamanlı donanım ve odak güncellemesi
        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(updateStatus), userInfo: nil, repeats: true)
    }

    // Doğrudan APFS Data Volume (/System/Volumes/Data) gerçek boş alanı
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

    // Mach Çekirdeği ile anlık aktif/wired/compressed bellek hesaplama
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
            var timeStr = "0 dk"
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let totalSec = json["total_active_seconds"] as? Int {
                let mins = totalSec / 60
                let hrs = Double(mins) / 60.0
                timeStr = mins > 90 ? String(format: "%.1f sa", hrs) : "\(mins) dk"
            }
            
            DispatchQueue.main.async {
                self?.statusItem?.button?.title = "🐺 \(timeStr) | 💾 \(diskStr) | 🧠 \(ramStr)"
            }
        }.resume()
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
