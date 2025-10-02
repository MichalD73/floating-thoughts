import XCTest
@testable import FloatingThoughts

final class FloatingThoughtsTests: XCTestCase {
    func testDraftEmptyState() throws {
        let emptyDraft = NoteDraft()
        XCTAssertTrue(emptyDraft.isEmpty)

        var draft = NoteDraft(text: "", screenshotData: Data([0x0]))
        XCTAssertFalse(draft.isEmpty)

        draft = NoteDraft(text: "Test", screenshotData: nil)
        XCTAssertFalse(draft.isEmpty)
    }

    func testViewModelDisablesSubmitWhileSyncing() {
        let viewModel = NoteComposerViewModel(repository: PreviewNotesRepository())
        XCTAssertTrue(viewModel.isSubmitDisabled)

        viewModel.text = "Myšlenka"
        XCTAssertFalse(viewModel.isSubmitDisabled)
    }
}
