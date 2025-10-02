import Foundation

struct Note: Identifiable, Hashable, Codable {
    struct Attachment: Hashable, Codable, Identifiable {
        enum AttachmentType: String, Codable {
            case screenshot
        }

        let id: String
        let type: AttachmentType
        var storagePath: String?
        var downloadURL: URL?
    }

    let id: String
    var workspaceId: String
    var text: String
    var attachments: [Attachment]
    var createdAt: Date
    var updatedAt: Date

    init(
        id: String = UUID().uuidString,
        workspaceId: String,
        text: String,
        attachments: [Attachment] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.workspaceId = workspaceId
        self.text = text
        self.attachments = attachments
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

struct NoteDraft {
    var text: String
    var screenshotData: Data?

    init(text: String = "", screenshotData: Data? = nil) {
        self.text = text
        self.screenshotData = screenshotData
    }

    var hasScreenshot: Bool {
        screenshotData != nil
    }

    var isEmpty: Bool {
        text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !hasScreenshot
    }
}
