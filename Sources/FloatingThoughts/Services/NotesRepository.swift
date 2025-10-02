import Foundation
@preconcurrency import FirebaseFirestore
@preconcurrency import FirebaseStorage

protocol NotesRepositoryProtocol: Sendable {
    func createNote(from draft: NoteDraft) async throws -> Note
}

enum NotesRepositoryError: LocalizedError {
    case serializationFailure

    var errorDescription: String? {
        switch self {
        case .serializationFailure:
            return "Poznámku se nepodařilo připravit pro uložení."
        }
    }
}

final class FirebaseNotesRepository: NotesRepositoryProtocol, @unchecked Sendable {
    private let service: FirebaseService

    init(service: FirebaseService = .shared) {
        self.service = service
    }

    func createNote(from draft: NoteDraft) async throws -> Note {
        let workspaceId = AppConfig.workspaceId
        let noteId = UUID().uuidString
        let now = Date()

        var attachments: [Note.Attachment] = []

        if let screenshotData = draft.screenshotData {
            let attachmentId = UUID().uuidString
            let storagePath = "workspaces/\(workspaceId)/notes/\(noteId)/\(attachmentId).png"
            let storageRef = service.storage.reference(withPath: storagePath)
            let metadata = StorageMetadata()
            metadata.contentType = "image/png"

            try await upload(data: screenshotData, to: storageRef, metadata: metadata)
            let downloadURL = try await fetchDownloadURL(from: storageRef)

            attachments.append(
                .init(
                    id: attachmentId,
                    type: .screenshot,
                    storagePath: storageRef.fullPath,
                    downloadURL: downloadURL
                )
            )
        }

        let note = Note(
            id: noteId,
            workspaceId: workspaceId,
            text: draft.text,
            attachments: attachments,
            createdAt: now,
            updatedAt: now
        )

        let data = note.asFirestorePayload()
        let docRef = service.firestore
            .collection("workspaces")
            .document(workspaceId)
            .collection("notes")
            .document(noteId)

        try await setDocument(reference: docRef, data: data)
        return note
    }

    private func upload(data: Data, to reference: StorageReference, metadata: StorageMetadata?) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, any Error>) in
            reference.putData(data, metadata: metadata) { _, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }

    private func setDocument(reference: DocumentReference, data: [String: Any]) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, any Error>) in
            reference.setData(data) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }
}

final class PreviewNotesRepository: NotesRepositoryProtocol, @unchecked Sendable {
    func createNote(from draft: NoteDraft) async throws -> Note {
        var attachments: [Note.Attachment] = []
        if draft.hasScreenshot {
            attachments.append(.init(
                id: UUID().uuidString,
                type: .screenshot,
                storagePath: nil,
                downloadURL: nil
            ))
        }
        return Note(
            workspaceId: AppConfig.workspaceId,
            text: draft.text,
            attachments: attachments
        )
    }
}

private extension Note {
    func asFirestorePayload() -> [String: Any] {
        [
            "id": id,
            "workspaceId": workspaceId,
            "text": text,
            "createdAt": Timestamp(date: createdAt),
            "updatedAt": Timestamp(date: updatedAt),
            "attachments": attachments.map { $0.asDictionary }
        ]
    }
}

private extension Note.Attachment {
    var asDictionary: [String: Any] {
        var payload: [String: Any] = [
            "id": id,
            "type": type.rawValue
        ]
        if let storagePath {
            payload["storagePath"] = storagePath
        }
        if let downloadURL {
            payload["downloadURL"] = downloadURL.absoluteString
        }
        return payload
    }
}

private extension FirebaseNotesRepository {
    func fetchDownloadURL(from reference: StorageReference) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            reference.downloadURL { url, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let url {
                    continuation.resume(returning: url)
                } else {
                    continuation.resume(throwing: NotesRepositoryError.serializationFailure)
                }
            }
        }
    }
}
