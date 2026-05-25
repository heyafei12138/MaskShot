import Foundation
import CoreGraphics

final class SensitiveInfoDetector {
    private let emailRegex = try? NSRegularExpression(
        pattern: #"[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}"#,
        options: [.caseInsensitive]
    )

    private let longNumberRegex = try? NSRegularExpression(
        pattern: #"\b(?:\d[\s-]?){8,}\d\b"#,
        options: []
    )

    private let amountRegex = try? NSRegularExpression(
        pattern: #"(?:(?:[$¥€£])\s?\d[\d,]*(?:\.\d{1,2})?|\d[\d,]*(?:\.\d{1,2})?\s?(?:USD|CNY|RMB|EUR|GBP))"#,
        options: [.caseInsensitive]
    )

    private let dataDetector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue | NSTextCheckingResult.CheckingType.phoneNumber.rawValue)

    func detect(in blocks: [RecognizedTextBlock]) -> [SensitiveItem] {
        blocks.flatMap { block in
            detect(in: block.text, boundingBox: block.boundingBox)
        }
    }
}

private extension SensitiveInfoDetector {
    func detect(in text: String, boundingBox: CGRect) -> [SensitiveItem] {
        var items: [SensitiveItem] = []
        let fullRange = NSRange(text.startIndex..<text.endIndex, in: text)

        if emailRegex?.firstMatch(in: text, options: [], range: fullRange) != nil {
            items.append(makeItem(type: .email, risk: .high, text: text, boundingBox: boundingBox, source: .regex))
        }

        dataDetector?.enumerateMatches(in: text, options: [], range: fullRange) { match, _, _ in
            guard let match else { return }
            switch match.resultType {
            case .phoneNumber:
                items.append(makeItem(type: .phone, risk: .high, text: text, boundingBox: boundingBox, source: .dataDetector))
            case .link:
                items.append(makeItem(type: .url, risk: .medium, text: text, boundingBox: boundingBox, source: .dataDetector))
            default:
                break
            }
        }

        if longNumberRegex?.firstMatch(in: text, options: [], range: fullRange) != nil {
            items.append(makeItem(type: .longNumber, risk: .medium, text: text, boundingBox: boundingBox, source: .regex))
        }

        if amountRegex?.firstMatch(in: text, options: [], range: fullRange) != nil {
            items.append(makeItem(type: .amount, risk: .low, text: text, boundingBox: boundingBox, source: .regex))
        }

        return items
    }

    func makeItem(
        type: SensitiveItemType,
        risk: RiskLevel,
        text: String,
        boundingBox: CGRect,
        source: DetectionSource
    ) -> SensitiveItem {
        SensitiveItem(
            type: type,
            riskLevel: risk,
            boundingBox: boundingBox,
            text: text,
            isSelected: risk != .low,
            source: source
        )
    }
}
