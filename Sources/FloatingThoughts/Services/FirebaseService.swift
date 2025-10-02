import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage

final class FirebaseService: @unchecked Sendable {
    static let shared = FirebaseService()

    private var isConfigured = false
    private let lock = NSLock()

    private init() {}

    func configureIfNeeded() {
        guard !isConfigured else { return }

        lock.lock()
        defer { lock.unlock() }

        guard !isConfigured else { return }

        if FirebaseApp.app() == nil {
            let credentials = AppConfig.firebaseConfiguration
            let options = FirebaseOptions(
                googleAppID: credentials.appId,
                gcmSenderID: credentials.messagingSenderId
            )
            options.apiKey = credentials.apiKey
            options.projectID = credentials.projectId
            options.storageBucket = credentials.storageBucket

            FirebaseApp.configure(options: options)
        }

        isConfigured = true
    }

    var firestore: Firestore {
        configureIfNeeded()
        return Firestore.firestore()
    }

    var storage: Storage {
        configureIfNeeded()
        return Storage.storage()
    }
}
