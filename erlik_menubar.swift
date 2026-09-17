import Cocoa
import Foundation

class ErlikMenuBarApp: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var timer: Timer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        updateStatus()

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "🐺 ERLİK Focus Intelligence", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "📊 Web Dashboard'u Aç", action: #selector(openDashboard), keyEquivalent: "d"))
        menu.addItem(NSMenuItem(title: "🍅 Pomodoro Başlat/Durdur", action: #selector(togglePomodoro), keyEquivalent: "p"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Çıkış", action: #selector(quit), keyEquivalent: "q"))

        statusItem?.menu = menu
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(updateStatus), userInfo: nil, repeats: true)
    }

    @objc func updateStatus() {
        guard let url = URL(string: "http://127.0.0.1:5757/api/stats?range=day") else { return }
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let totalSec = json["total_active_seconds"] as? Int else { return }
            
            let mins = totalSec / 60
            let hrs = Double(mins) / 60.0
            let timeStr = mins > 90 ? String(format: "%.1f sa", hrs) : "\(mins) dk"
            
            DispatchQueue.main.async {
                self?.statusItem?.button?.title = "🐺 \(timeStr)"
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
app.setActivationPolicy(.accessory) // Dock ikonu göstermez, sadece menubar
app.run()
