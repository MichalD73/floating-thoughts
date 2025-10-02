import SwiftUI
import AppKit

@MainActor
final class FloatingPanelController: NSObject, NSWindowDelegate {
    static let shared = FloatingPanelController()

    private var panel: NSPanel?
    private var hostingController: NSHostingController<FloatingPanelView>?
    private let viewModel: NoteComposerViewModel
    private let screenshotCapturer: ScreenshotCapturing

    private override init() {
        self.screenshotCapturer = ScreenshotCapturer()
        self.viewModel = NoteComposerViewModel(repository: FirebaseNotesRepository())
        super.init()
    }

    init(
        repository: NotesRepositoryProtocol,
        screenshotCapturer: ScreenshotCapturing
    ) {
        self.viewModel = NoteComposerViewModel(repository: repository)
        self.screenshotCapturer = screenshotCapturer
        super.init()
    }

    func showPanel() {
        if panel == nil {
            createPanel()
        }
        guard let panel else { return }
        panel.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func hidePanel() {
        panel?.orderOut(nil)
    }

    func togglePanel() {
        if panel?.isVisible == true {
            hidePanel()
        } else {
            showPanel()
        }
    }

    private func createPanel() {
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 380, height: 320),
            styleMask: [
                .titled,
                .fullSizeContentView,
                .closable,
                .resizable
            ],
            backing: .buffered,
            defer: false
        )

        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.level = .floating
        panel.isFloatingPanel = true
        panel.collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary
        ]
        panel.isReleasedWhenClosed = false
        panel.hidesOnDeactivate = false
        panel.isMovableByWindowBackground = true
        panel.delegate = self
        panel.standardWindowButton(.closeButton)?.isHidden = true
        panel.standardWindowButton(.miniaturizeButton)?.isHidden = true
        panel.standardWindowButton(.zoomButton)?.isHidden = true

        let rootView = FloatingPanelView(
            viewModel: viewModel,
            onRequestScreenshotCapture: { [weak self] in
                self?.handleScreenshotRequest()
            },
            onRequestClose: { [weak self] in
                self?.hidePanel()
            }
        )

        let hostingController = NSHostingController(rootView: rootView)
        panel.contentViewController = hostingController
        panel.center()

        self.panel = panel
        self.hostingController = hostingController
    }

    private func handleScreenshotRequest() {
        Task { [weak self] in
            guard let self else { return }
            do {
                let image = try screenshotCapturer.capturePrimaryDisplay()
                await MainActor.run {
                    self.viewModel.attachScreenshot(image)
                }
            } catch {
                await MainActor.run {
                    self.viewModel.handleError(error)
                }
            }
        }
    }

    func windowWillClose(_ notification: Notification) {
        if notification.object as? NSPanel === panel {
            panel = nil
            hostingController = nil
        }
    }
}
