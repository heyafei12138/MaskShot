import UIKit

final class RedactionRenderer {
    func render(session: RedactionSession) -> UIImage {
        render(
            image: session.originalImage,
            items: session.selectedItems,
            style: session.redactionStyle
        )
    }

    func render(image: UIImage, items: [SensitiveItem], style: RedactionStyle) -> UIImage {
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = image.scale
        format.opaque = true

        let renderer = UIGraphicsImageRenderer(size: image.size, format: format)
        return renderer.image { context in
            image.draw(in: CGRect(origin: .zero, size: image.size))

            for item in items {
                let rect = item.boundingBox.clampedToUnit().scaled(to: CGRect(origin: .zero, size: image.size))
                drawRedaction(in: rect, style: style, context: context.cgContext)
            }
        }
    }
}

private extension RedactionRenderer {
    func drawRedaction(in rect: CGRect, style: RedactionStyle, context: CGContext) {
        switch style {
        case .blackout, .blur:
            context.setFillColor(AppTheme.Color.blackout.cgColor)
            context.fill(rect)
        case .pixelCover:
            context.setFillColor(AppTheme.Color.blackout.cgColor)
            context.fill(rect)
            context.setFillColor(UIColor.white.withAlphaComponent(0.18).cgColor)

            let tileSize: CGFloat = max(6, min(rect.width, rect.height) / 8)
            var y = rect.minY
            while y < rect.maxY {
                var x = rect.minX
                while x < rect.maxX {
                    if Int((x + y) / tileSize).isMultiple(of: 2) {
                        context.fill(CGRect(x: x, y: y, width: tileSize, height: tileSize).intersection(rect))
                    }
                    x += tileSize
                }
                y += tileSize
            }
        }
    }
}
