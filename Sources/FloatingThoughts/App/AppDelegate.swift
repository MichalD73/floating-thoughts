import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        FirebaseService.shared.configureIfNeeded()
        NSApp.setActivationPolicy(.regular)
        FloatingPanelController.shared.showPanel()
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        FloatingPanelController.shared.showPanel()
        return true
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Placeholder for cleanup if needed later.
    }
}
