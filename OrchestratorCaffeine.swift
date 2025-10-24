import Cocoa
import IOKit.pwr_mgt

// MARK: - App Delegate

class AppDelegate: NSObject {
    var window: NSWindow?
    var toggleMenuItem: NSMenuItem?
    var statsMenuItem: NSMenuItem?
    weak var statusItem: NSStatusItem?
    private var assertionID: IOPMAssertionID = 0
    private var activeStartTime: Date?
    private var totalActiveSeconds: TimeInterval = 0
    
    override init() {
        super.init()
        // Load saved statistics
        let defaults = UserDefaults.standard
        totalActiveSeconds = defaults.double(forKey: "totalActiveSeconds")
    }
    
    @objc func toggleVisibility() {
        guard let window = window, let menuItem = toggleMenuItem else { return }
        
        if window.isVisible {
            hideWindow()
            menuItem.title = "Show"
        } else {
            showWindow()
            menuItem.title = "Hide"
        }
        updateStatsDisplay()
    }
    
    @objc func showStats() {
        var displaySeconds = totalActiveSeconds
        
        // Add current session time if active
        if let startTime = activeStartTime {
            displaySeconds += Date().timeIntervalSince(startTime)
        }
        
        let hours = Int(displaySeconds) / 3600
        let minutes = (Int(displaySeconds) % 3600) / 60
        
        let alert = NSAlert()
        alert.messageText = "Orchestrator Statistics"
        alert.informativeText = "Total time keeping screen awake:\n\(hours)h \(minutes)m"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Reset Stats")
        
        let response = alert.runModal()
        if response == .alertSecondButtonReturn {
            totalActiveSeconds = 0
            activeStartTime = Date() // Reset current session start
            UserDefaults.standard.set(0, forKey: "totalActiveSeconds")
            updateStatsDisplay()
        }
    }
    
    func enableSleepPrevention() {
        guard assertionID == 0 else { return }
        
        IOPMAssertionCreateWithName(
            kIOPMAssertionTypeNoDisplaySleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            "Orchestrator Caffeine Active" as CFString,
            &assertionID
        )
        
        activeStartTime = Date()
        updateIconState(active: true)
    }
    
    private func disableSleepPrevention() {
        guard assertionID != 0 else { return }
        
        // Save accumulated time
        if let startTime = activeStartTime {
            totalActiveSeconds += Date().timeIntervalSince(startTime)
            UserDefaults.standard.set(totalActiveSeconds, forKey: "totalActiveSeconds")
            activeStartTime = nil
        }
        
        IOPMAssertionRelease(assertionID)
        assertionID = 0
        updateIconState(active: false)
    }
    
    private func hideWindow() {
        window?.orderOut(nil)
        disableSleepPrevention()
    }
    
    private func showWindow() {
        window?.makeKeyAndOrderFront(nil)
        enableSleepPrevention()
    }
    
    private func updateIconState(active: Bool) {
        guard let button = statusItem?.button else { return }
        
        // Add visual indicator - make icon slightly transparent when inactive
        button.alphaValue = active ? 1.0 : 0.5
    }
    
    func updateStatsDisplay() {
        var displaySeconds = totalActiveSeconds
        
        // Add current session time if active
        if let startTime = activeStartTime {
            displaySeconds += Date().timeIntervalSince(startTime)
        }
        
        let hours = Int(displaySeconds) / 3600
        let minutes = (Int(displaySeconds) % 3600) / 60
        statsMenuItem?.title = "Stats: \(hours)h \(minutes)m active"
    }
    
    func startStatsTimer() {
        // Update stats display every minute
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.updateStatsDisplay()
        }
    }
    
    deinit {
        disableSleepPrevention()
    }
}

// MARK: - Draggable View

class DraggableView: NSView {
    private var initialLocation: NSPoint?
    
    override func mouseDown(with event: NSEvent) {
        initialLocation = event.locationInWindow
    }
    
    override func mouseDragged(with event: NSEvent) {
        guard let window = self.window, let initial = initialLocation else { return }
        
        let currentLocation = event.locationInWindow
        let newOrigin = NSPoint(
            x: window.frame.origin.x + (currentLocation.x - initial.x),
            y: window.frame.origin.y + (currentLocation.y - initial.y)
        )
        
        window.setFrameOrigin(newOrigin)
    }
}

// MARK: - Main

let app = NSApplication.shared
app.setActivationPolicy(.accessory)

let appDelegate = AppDelegate()

// MARK: - Menu Bar Setup

let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

// Get icon path from bundle resources
let iconPath: String = {
    if let bundlePath = Bundle.main.resourcePath {
        let bundledIcon = bundlePath + "/icon.png"
        if FileManager.default.fileExists(atPath: bundledIcon) {
            return bundledIcon
        }
    }
    let currentDir = FileManager.default.currentDirectoryPath
    return currentDir + "/assets/icon.png"
}()

// Load icon for menu bar
if let iconImage = NSImage(contentsOfFile: iconPath) {
    iconImage.size = NSSize(width: 18, height: 18)
    statusItem.button?.image = iconImage
} else {
    statusItem.button?.title = "🎼"
}

// Get GIF path from bundle resources
let gifPath: String = {
    if let bundlePath = Bundle.main.resourcePath {
        let bundledGif = bundlePath + "/pet.gif"
        if FileManager.default.fileExists(atPath: bundledGif) {
            return bundledGif
        }
    }
    // Fallback: look in current directory (for development)
    let currentDir = FileManager.default.currentDirectoryPath
    return currentDir + "/assets/pet.gif"
}()

// Create menu
let menu = NSMenu()
let toggleItem = NSMenuItem(title: "Hide", action: #selector(AppDelegate.toggleVisibility), keyEquivalent: "h")
toggleItem.target = appDelegate
menu.addItem(toggleItem)

let statsItem = NSMenuItem(title: "Stats: 0h 0m active", action: #selector(AppDelegate.showStats), keyEquivalent: "s")
statsItem.target = appDelegate
menu.addItem(statsItem)

menu.addItem(NSMenuItem.separator())
menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
statusItem.menu = menu

appDelegate.toggleMenuItem = toggleItem
appDelegate.statsMenuItem = statsItem
appDelegate.statusItem = statusItem

// MARK: - Window Setup

let windowSize: CGFloat = 100

// Position at bottom-center of screen with margin equal to robot size
let screenWidth = NSScreen.main?.frame.width ?? 1440
let startX: CGFloat = (screenWidth - windowSize) / 2
let startY: CGFloat = windowSize

let window = NSWindow(
    contentRect: NSRect(x: startX, y: startY, width: windowSize, height: windowSize),
    styleMask: [.borderless],
    backing: .buffered,
    defer: false
)

window.level = .floating
window.backgroundColor = .clear
window.isOpaque = false
window.hasShadow = false

// MARK: - Content Setup

let draggableView = DraggableView(frame: NSRect(x: 0, y: 0, width: windowSize, height: windowSize))

// Load and animate GIF
if let gifData = try? Data(contentsOf: URL(fileURLWithPath: gifPath)),
   let source = CGImageSourceCreateWithData(gifData as CFData, nil) {
    
    let imageView = NSImageView(frame: NSRect(x: 0, y: 0, width: windowSize, height: windowSize))
    
    // Extract all frames from GIF
    var images: [NSImage] = []
    let frameCount = CGImageSourceGetCount(source)
    
    for i in 0..<frameCount {
        if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
            let nsImage = NSImage(cgImage: cgImage, size: NSSize(width: windowSize, height: windowSize))
            images.append(nsImage)
        }
    }
    
    if !images.isEmpty {
        imageView.image = images[0]
        imageView.animates = true
        imageView.canDrawSubviewsIntoLayer = true
        
        // Animate frames using timer in common run loop mode (continues when menu is open)
        var currentFrame = 0
        let timer = Timer(timeInterval: 0.1, repeats: true) { _ in
            imageView.image = images[currentFrame % images.count]
            currentFrame += 1
        }
        RunLoop.current.add(timer, forMode: .common)
    }
    
    draggableView.addSubview(imageView)
} else {
    // Fallback to emoji if GIF fails to load
    let label = NSTextField(frame: NSRect(x: 0, y: 0, width: windowSize, height: windowSize))
    label.stringValue = "🎼"
    label.font = NSFont.systemFont(ofSize: 60)
    label.isBezeled = false
    label.drawsBackground = false
    label.isEditable = false
    label.isSelectable = false
    label.alignment = .center
    draggableView.addSubview(label)
}

appDelegate.window = window
appDelegate.enableSleepPrevention()
appDelegate.updateStatsDisplay()
appDelegate.startStatsTimer()
window.contentView = draggableView
window.makeKeyAndOrderFront(nil)

// Show first launch notification
let defaults = UserDefaults.standard
if !defaults.bool(forKey: "hasLaunchedBefore") {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        if let button = statusItem.button {
            // Create container view with padding
            let containerView = NSView(frame: NSRect(x: 0, y: 0, width: 220, height: 50))
            
            // Create label with padding
            let notification = NSTextField(frame: NSRect(x: 15, y: 15, width: 190, height: 20))
            notification.stringValue = "Your orchestrator is running!"
            notification.isBezeled = false
            notification.drawsBackground = false
            notification.isEditable = false
            notification.isSelectable = false
            notification.alignment = .center
            notification.font = NSFont.systemFont(ofSize: 13)
            notification.textColor = NSColor.labelColor
            
            containerView.addSubview(notification)
            
            let popover = NSPopover()
            popover.contentViewController = NSViewController()
            popover.contentViewController?.view = containerView
            popover.behavior = .transient
            popover.appearance = NSAppearance(named: .aqua)
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            
            // Auto-dismiss after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                popover.close()
            }
        }
    }
    defaults.set(true, forKey: "hasLaunchedBefore")
}

app.run()
