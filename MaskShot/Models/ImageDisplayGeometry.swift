import CoreGraphics

struct ImageDisplayGeometry: Equatable {
    let imageSize: CGSize
    let containerSize: CGSize
    let displayedImageRect: CGRect

    static func aspectFit(imageSize: CGSize, in containerSize: CGSize) -> ImageDisplayGeometry {
        guard imageSize.width > 0,
              imageSize.height > 0,
              containerSize.width > 0,
              containerSize.height > 0 else {
            return ImageDisplayGeometry(
                imageSize: imageSize,
                containerSize: containerSize,
                displayedImageRect: .zero
            )
        }

        let widthScale = containerSize.width / imageSize.width
        let heightScale = containerSize.height / imageSize.height
        let scale = min(widthScale, heightScale)
        let size = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
        let origin = CGPoint(
            x: (containerSize.width - size.width) * 0.5,
            y: (containerSize.height - size.height) * 0.5
        )

        return ImageDisplayGeometry(
            imageSize: imageSize,
            containerSize: containerSize,
            displayedImageRect: CGRect(origin: origin, size: size)
        )
    }
}

