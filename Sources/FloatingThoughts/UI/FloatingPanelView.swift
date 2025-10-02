import SwiftUI
import AppKit

struct FloatingPanelView: View {
    @ObservedObject var viewModel: NoteComposerViewModel
    let onRequestScreenshotCapture: () -> Void
    let onRequestClose: () -> Void

    init(
        viewModel: NoteComposerViewModel,
        onRequestScreenshotCapture: @escaping () -> Void,
        onRequestClose: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.onRequestScreenshotCapture = onRequestScreenshotCapture
        self.onRequestClose = onRequestClose
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header
            composer
            attachments
            statusBar
        }
        .padding(16)
        .frame(minWidth: 320, minHeight: 260)
    }

    private var header: some View {
        HStack {
            Text(String(localized: "app_title")).font(.headline)
            Spacer()
            Button(action: onRequestClose) {
                Image(systemName: "xmark")
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
    }

    private var composer: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topLeading) {
                TextEditor(text: $viewModel.text)
                    .font(.body)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.2))
                    )
                    .frame(minHeight: 120)

                if viewModel.text.isEmpty {
                    Text(String(localized: "note_placeholder"))
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                        .padding(.leading, 5)
                }
            }

            HStack {
                Button(String(localized: "capture_screenshot")) {
                    onRequestScreenshotCapture()
                }
                .disabled(viewModel.isSyncing)

                Spacer()

                Button(String(localized: "save_note")) {
                    viewModel.submit()
                }
                .keyboardShortcut(.return, modifiers: [.command])
                .disabled(viewModel.isSubmitDisabled)
            }
        }
    }

    private var attachments: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let screenshot = viewModel.screenshotPreview {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Screenshot")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Image(nsImage: screenshot)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 160)
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                    Button("Odebrat") {
                        viewModel.clearScreenshot()
                    }
                    .buttonStyle(.borderless)
                }
            }
        }
    }

    private var statusBar: some View {
        HStack(spacing: 8) {
            Text(viewModel.syncState.localizedDescription)
                .font(.caption)
                .foregroundColor(.secondary)

            if case .failure(let message) = viewModel.syncState {
                Text(message)
                    .font(.caption)
                    .foregroundColor(.red)
            }

            Spacer()
        }
    }
}
