import UIKit

struct RedactionSession {
    let originalImage: UIImage
    var sensitiveItems: [SensitiveItem]
    var redactionStyle: RedactionStyle
    var renderedImage: UIImage?

    init(
        originalImage: UIImage,
        sensitiveItems: [SensitiveItem] = [],
        redactionStyle: RedactionStyle = .blackout,
        renderedImage: UIImage? = nil
    ) {
        self.originalImage = originalImage
        self.sensitiveItems = sensitiveItems
        self.redactionStyle = redactionStyle
        self.renderedImage = renderedImage
    }

    var selectedItems: [SensitiveItem] {
        sensitiveItems.filter(\.isSelected)
    }

    mutating func addManualItem(in imageRect: CGRect) {
        let item = SensitiveItem(
            type: .manual,
            riskLevel: .high,
            boundingBox: imageRect,
            isSelected: true,
            source: .manual
        )
        sensitiveItems.append(item)
    }

    mutating func toggleSelection(for id: SensitiveItem.ID) {
        guard let index = sensitiveItems.firstIndex(where: { $0.id == id }) else { return }
        sensitiveItems[index].isSelected.toggle()
    }

    mutating func selectAllItems() {
        sensitiveItems = sensitiveItems.map { item in
            var copy = item
            copy.isSelected = true
            return copy
        }
    }

    mutating func removeItem(id: SensitiveItem.ID) {
        sensitiveItems.removeAll { $0.id == id }
    }
}

