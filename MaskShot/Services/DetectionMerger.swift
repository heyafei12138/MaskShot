import CoreGraphics
import Foundation

final class DetectionMerger {
    func merge(_ items: [SensitiveItem]) -> [SensitiveItem] {
        var merged: [SensitiveItem] = []

        for item in items {
            guard let index = merged.firstIndex(where: { shouldMerge($0, item) }) else {
                merged.append(item)
                continue
            }

            var existing = merged[index]
            existing.boundingBox = existing.boundingBox.union(item.boundingBox).clampedToUnit()
            existing.isSelected = existing.isSelected || item.isSelected
            existing.riskLevel = highestRisk(existing.riskLevel, item.riskLevel)
            existing.text = [existing.text, item.text].compactMap { $0 }.joined(separator: " ")
            merged[index] = existing
        }

        return merged
    }
}

private extension DetectionMerger {
    func shouldMerge(_ lhs: SensitiveItem, _ rhs: SensitiveItem) -> Bool {
        guard lhs.type == rhs.type, lhs.boundingBox.intersects(rhs.boundingBox) else {
            return false
        }

        let intersection = lhs.boundingBox.intersection(rhs.boundingBox)
        let overlap = intersection.normalizedArea / max(min(lhs.boundingBox.normalizedArea, rhs.boundingBox.normalizedArea), 0.0001)
        let yDistance = abs(lhs.boundingBox.midY - rhs.boundingBox.midY)
        return overlap > 0.35 || (yDistance < 0.02 && lhs.boundingBox.intersects(rhs.boundingBox.insetBy(dx: -0.02, dy: -0.01)))
    }

    func highestRisk(_ lhs: RiskLevel, _ rhs: RiskLevel) -> RiskLevel {
        let rank: [RiskLevel: Int] = [.low: 0, .medium: 1, .high: 2]
        return (rank[lhs, default: 0] >= rank[rhs, default: 0]) ? lhs : rhs
    }
}
