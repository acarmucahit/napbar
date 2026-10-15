import Cocoa

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var ticker: Timer?
    private var fireDate: Date?
    private let presets = [5, 10, 15, 20, 30, 45, 60, 90, 120]

    func applicationDidFinishLaunching(_ notification: Notification) {
        // On notched Macs with a full menu bar, new items land under the notch and get hidden; start near the right edge instead.
        UserDefaults.standard.register(defaults: ["NSStatusItem Preferred Position NapBar": 300])
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.autosaveName = "NapBar"
        let image = NSImage(systemSymbolName: "moon.zzz", accessibilityDescription: "Sleep timer")
        image?.isTemplate = true
        statusItem.button?.image = image
        statusItem.button?.imagePosition = .imageLeading
        refresh()
    }

    private func refresh() {
        statusItem.button?.title = remaining().map { " " + format($0) } ?? ""
        statusItem.menu = buildMenu()
    }

    private func buildMenu() -> NSMenu {
        let menu = NSMenu()

        if let left = remaining(), let date = fireDate {
            let clock = DateFormatter.localizedString(from: date, dateStyle: .none, timeStyle: .short)
            let info = NSMenuItem(title: "Sleep at \(clock) (\(format(left)) left)", action: nil, keyEquivalent: "")
            info.isEnabled = false
            menu.addItem(info)
            menu.addItem(item("Add 15 min", #selector(addFifteen)))
            menu.addItem(item("Cancel", #selector(cancel), key: "x"))
            menu.addItem(.separator())
        }

        for minutes in presets {
            let label = minutes < 60 ? "\(minutes) min" : (minutes % 60 == 0 ? "\(minutes / 60) h" : "\(minutes / 60) h \(minutes % 60) min")
            let entry = item("Sleep in \(label)", #selector(pickPreset(_:)))
            entry.tag = minutes
            menu.addItem(entry)
        }
        menu.addItem(item("Custom…", #selector(pickCustom)))
        menu.addItem(.separator())
        menu.addItem(item("Sleep now", #selector(sleepNowAction)))
        menu.addItem(item("Quit", #selector(quit), key: "q"))
        return menu
    }

    private func item(_ title: String, _ action: Selector, key: String = "") -> NSMenuItem {
        let entry = NSMenuItem(title: title, action: action, keyEquivalent: key)
        entry.target = self
        return entry
    }

    @objc private func pickPreset(_ sender: NSMenuItem) { start(minutes: sender.tag) }

    @objc private func pickCustom() {
        let alert = NSAlert()
        alert.messageText = "Sleep in how many minutes?"
        alert.addButton(withTitle: "Start")
        alert.addButton(withTitle: "Cancel")
        let field = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        field.placeholderString = "Minutes"
        alert.accessoryView = field
        alert.window.initialFirstResponder = field
        NSApp.activate(ignoringOtherApps: true)
        guard alert.runModal() == .alertFirstButtonReturn,
              let minutes = Int(field.stringValue.trimmingCharacters(in: .whitespaces)), minutes > 0 else { return }
        start(minutes: minutes)
    }

    @objc private func addFifteen() {
        guard let date = fireDate else { return }
        fireDate = date.addingTimeInterval(15 * 60)
        refresh()
    }

    @objc private func cancel() {
        ticker?.invalidate()
        ticker = nil
        fireDate = nil
        refresh()
    }

    @objc private func sleepNowAction() {
        cancel()
        sleepNow()
    }

    @objc private func quit() { NSApp.terminate(nil) }

    private func start(minutes: Int) {
        fireDate = Date().addingTimeInterval(TimeInterval(minutes * 60))
        ticker?.invalidate()
        let timer = Timer(timeInterval: 1, repeats: true) { [weak self] _ in self?.tick() }
        RunLoop.main.add(timer, forMode: .common)
        ticker = timer
        refresh()
    }

    private func tick() {
        guard let left = remaining() else { return }
        if left <= 0 {
            cancel()
            sleepNow()
        } else {
            refresh()
        }
    }

    private func remaining() -> TimeInterval? {
        fireDate.map { max(0, $0.timeIntervalSinceNow) }
    }

    private func format(_ interval: TimeInterval) -> String {
        let total = Int(interval.rounded(.up))
        let h = total / 3600, m = (total % 3600) / 60, s = total % 60
        return h > 0 ? String(format: "%d:%02d:%02d", h, m, s) : String(format: "%02d:%02d", m, s)
    }

    private func sleepNow() {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/pmset")
        process.arguments = ["sleepnow"]
        try? process.run()
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
