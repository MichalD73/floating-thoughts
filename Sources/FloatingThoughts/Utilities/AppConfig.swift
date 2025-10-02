import Foundation

enum AppConfig {
    static let workspaceId: String = "personal"

    static let firebaseConfiguration = FirebaseConfiguration(
        apiKey: "AIzaSyDdKzUd-QVHEdHMGl3kbuAKk4p6CjgkgzQ",
        appId: "1:907874309868:web:5354ee69d6212f3d9937c9",
        projectId: "central-asset-storage",
        storageBucket: "central-asset-storage.firebasestorage.app",
        messagingSenderId: "907874309868"
    )
}

struct FirebaseConfiguration {
    let apiKey: String
    let appId: String
    let projectId: String
    let storageBucket: String
    let messagingSenderId: String
}
