import AppKit
import CoreGraphics

protocol ScreenshotCapturing {
    func capturePrimaryDisplay() throws -> NSImage
}

enum ScreenshotCaptureError: LocalizedError {
    case permissionDenied
    case captureFailed

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Aplikace nemá oprávnění pro snímání obrazovky."
        case .captureFailed:
            return "Snímek obrazovky se nepodařilo pořídit."
        }
    }
}

final class ScreenshotCapturer: ScreenshotCapturing {
    func capturePrimaryDisplay() throws -> NSImage {
        let displayId = CGMainDisplayID()
        guard let cgImage = CGDisplayCreateImage(displayId) else {
            if CGPreflightScreenCaptureAccess() {
                throw ScreenshotCaptureError.captureFailed
            } else {
                throw ScreenshotCaptureError.permissionDenied
            }
        }
        let size = NSSize(width: cgImage.width, height: cgImage.height)
        let image = NSImage(cgImage: cgImage, size: size)
        return image
    }
}
