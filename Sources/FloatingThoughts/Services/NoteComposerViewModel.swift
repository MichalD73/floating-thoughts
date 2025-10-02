import Foundation
import AppKit
import Combine

@MainActor
final class NoteComposerViewModel: ObservableObject {
    enum SyncState: Equatable {
        case idle
        case syncing
        case success
        case failure(String)

        var localizedDescription: String {
            switch self {
            case .idle:
                return String(localized: "sync_status_ready")
            case .syncing:
                return String(localized: "sync_status_syncing")
            case .success:
                return String(localized: "sync_status_ready")
            case .failure:
                return String(localized: "sync_status_error")
            }
        }
    }

    @Published var text: String = ""
    @Published private(set) var screenshotPreview: NSImage?
    @Published private(set) var syncState: SyncState = .idle
    @Published private(set) var lastError: String?

    private var screenshotData: Data?
    private let repository: NotesRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()

    init(repository: NotesRepositoryProtocol) {
        self.repository = repository
    }

    var isSubmitDisabled: Bool {
        draft.isEmpty || isSyncing
    }

    var isSyncing: Bool {
        if case .syncing = syncState { return true }
        return false
    }

    var draft: NoteDraft {
        NoteDraft(text: text, screenshotData: screenshotData)
    }

    func submit() {
        guard !draft.isEmpty else { return }

        syncState = .syncing
        lastError = nil
        let currentDraft = draft

        Task {
            do {
                _ = try await repository.createNote(from: currentDraft)
                await MainActor.run {
                    self.resetComposer()
                    self.syncState = .success
                    self.scheduleStateReset()
                }
            } catch {
                await MainActor.run {
                    self.lastError = error.localizedDescription
                    self.syncState = .failure(error.localizedDescription)
                }
            }
        }
    }

    func attachScreenshot(_ image: NSImage) {
        screenshotPreview = image
        screenshotData = image.pngData()
    }

    func clearScreenshot() {
        screenshotPreview = nil
        screenshotData = nil
    }

    func resetComposer() {
        text = ""
        clearScreenshot()
    }

    func handleError(_ error: Error) {
        let message = error.localizedDescription
        lastError = message
        syncState = .failure(message)
    }

    private func scheduleStateReset() {
        Task { [weak self] in
            try await Task.sleep(nanoseconds: 1_500_000_000)
            await MainActor.run {
                guard let self else { return }
                if case .success = self.syncState {
                    self.syncState = .idle
                }
            }
        }
    }
}
