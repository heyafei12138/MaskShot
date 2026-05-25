import CoreGraphics
import Foundation

struct SensitiveItem: Identifiable, Codable, Equatable {
    let id: UUID
    var type: SensitiveItemType
    var riskLevel: RiskLevel
    var boundingBox: CGRect
    var text: String?
    var isSelected: Bool
    var source: DetectionSource

    init(
        id: UUID = UUID(),
        type: SensitiveItemType,
        riskLevel: RiskLevel,
        boundingBox: CGRect,
        text: String? = nil,
        isSelected: Bool,
        source: DetectionSource
    ) {
        self.id = id
        self.type = type
        self.riskLevel = riskLevel
        self.boundingBox = boundingBox
        self.text = text
        self.isSelected = isSelected
        self.source = source
    }
}

enum SensitiveItemType: String, Codable, CaseIterable {
    case email
    case phone
    case url
    case amount
    case longNumber
    case face
    case qrCode
    case manual
    case unknown

    var displayName: String {
        switch self {
        case .email: return "Email"
        case .phone: return "Phone"
        case .url: return "URL"
        case .amount: return "Amount"
        case .longNumber: return "Number"
        case .face: return "Face"
        case .qrCode: return "QR"
        case .manual: return "Manual"
        case .unknown: return "Unknown"
        }
    }
}

enum RiskLevel: String, Codable {
    case high
    case medium
    case low
}

enum DetectionSource: String, Codable {
    case visionText
    case dataDetector
    case regex
    case faceDetection
    case barcodeDetection
    case manual
}

enum RedactionStyle: String, Codable, CaseIterable {
    case blackout
    case pixelCover
    case blur

    var displayName: String {
        switch self {
        case .blackout: return "Blackout"
        case .pixelCover: return "Pixel Cover"
        case .blur: return "Blur"
        }
    }
}

extension CGRect {
    var normalizedArea: CGFloat {
        max(width, 0) * max(height, 0)
    }

    func scaled(to rect: CGRect) -> CGRect {
        CGRect(
            x: rect.minX + minX * rect.width,
            y: rect.minY + minY * rect.height,
            width: width * rect.width,
            height: height * rect.height
        )
    }

    func clampedToUnit() -> CGRect {
        let minX = max(0, min(1, self.minX))
        let minY = max(0, min(1, self.minY))
        let maxX = max(0, min(1, self.maxX))
        let maxY = max(0, min(1, self.maxY))
        return CGRect(x: minX, y: minY, width: max(0, maxX - minX), height: max(0, maxY - minY))
    }
}
