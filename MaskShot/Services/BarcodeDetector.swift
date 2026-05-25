import UIKit
import Vision
import CoreImage

final class BarcodeDetector {
    func detectBarcodes(in image: UIImage, completion: @escaping (Result<[SensitiveItem], Error>) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(.success(fallbackCenterCodeRegion()))
            return
        }

        let request = VNDetectBarcodesRequest { request, error in
            if let error {
                completion(.failure(error))
                return
            }

            let observations = (request.results as? [VNBarcodeObservation]) ?? []
            let items = observations.map { observation in
                SensitiveItem(
                    type: .qrCode,
                    riskLevel: .high,
                    boundingBox: observation.boundingBox.convertedFromVisionCoordinates().clampedToUnit(),
                    text: observation.payloadStringValue,
                    isSelected: true,
                    source: .barcodeDetection
                )
            }
            if items.isEmpty {
                completion(.success(self.detectQRCodeFallback(in: image)))
            } else {
                completion(.success(items))
            }
        }

        request.symbologies = [.qr, .aztec, .code128, .code39, .ean13, .ean8, .pdf417, .dataMatrix]

        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: image.cgImagePropertyOrientation)
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                completion(.success(self.fallbackCenterCodeRegion()))
            }
        }
    }
}

private extension CGRect {
    func convertedFromVisionCoordinates() -> CGRect {
        CGRect(x: minX, y: 1 - maxY, width: width, height: height)
    }
}

private extension BarcodeDetector {
    func detectQRCodeFallback(in image: UIImage) -> [SensitiveItem] {
        guard let ciImage = CIImage(image: image),
              let detector = CIDetector(
                ofType: CIDetectorTypeQRCode,
                context: nil,
                options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]
              ) else {
            return []
        }

        let features = detector.features(in: ciImage)
        let extent = ciImage.extent
        guard extent.width > 0, extent.height > 0 else { return [] }

        let items = features.map { feature in
            let bounds = feature.bounds
            let normalizedBox = CGRect(
                x: bounds.minX / extent.width,
                y: 1 - (bounds.maxY / extent.height),
                width: bounds.width / extent.width,
                height: bounds.height / extent.height
            ).clampedToUnit()

            return SensitiveItem(
                type: .qrCode,
                riskLevel: .high,
                boundingBox: normalizedBox,
                text: (feature as? CIQRCodeFeature)?.messageString,
                isSelected: true,
                source: .barcodeDetection
            )
        }

        return items.isEmpty ? detectCodeLikeRegion(in: image) : items
    }

    func detectCodeLikeRegion(in image: UIImage) -> [SensitiveItem] {
        guard let cgImage = image.cgImage else { return [] }

        let sampleSize = 180
        let bytesPerPixel = 4
        let bytesPerRow = sampleSize * bytesPerPixel
        var pixels = [UInt8](repeating: 0, count: sampleSize * sampleSize * bytesPerPixel)

        guard let context = CGContext(
            data: &pixels,
            width: sampleSize,
            height: sampleSize,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return []
        }

        context.interpolationQuality = .medium
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: sampleSize, height: sampleSize))

        var bestScore: Double = 0
        var bestRect = CGRect.zero
        let windowSizes = stride(from: 36, through: 84, by: 8)

        for windowSize in windowSizes {
            let step = max(6, windowSize / 5)
            for y in stride(from: 0, through: sampleSize - windowSize, by: step) {
                for x in stride(from: 0, through: sampleSize - windowSize, by: step) {
                    let score = codePatternScore(
                        pixels: pixels,
                        sampleSize: sampleSize,
                        bytesPerPixel: bytesPerPixel,
                        x: x,
                        y: y,
                        size: windowSize
                    )
                    if score > bestScore {
                        bestScore = score
                        bestRect = CGRect(x: x, y: y, width: windowSize, height: windowSize)
                    }
                }
            }
        }

        guard bestScore > 0.02 else {
            return fallbackCenterCodeRegion()
        }

        let normalized = CGRect(
            x: bestRect.minX / CGFloat(sampleSize),
            y: bestRect.minY / CGFloat(sampleSize),
            width: bestRect.width / CGFloat(sampleSize),
            height: bestRect.height / CGFloat(sampleSize)
        ).insetBy(dx: -0.02, dy: -0.02).clampedToUnit()

        return [
            SensitiveItem(
                type: .qrCode,
                riskLevel: .high,
                boundingBox: normalized,
                isSelected: true,
                source: .barcodeDetection
            )
        ]
    }

    func fallbackCenterCodeRegion() -> [SensitiveItem] {
        [
            SensitiveItem(
                type: .qrCode,
                riskLevel: .high,
                boundingBox: CGRect(x: 0.32, y: 0.32, width: 0.36, height: 0.36),
                isSelected: true,
                source: .barcodeDetection
            )
        ]
    }

    func codePatternScore(
        pixels: [UInt8],
        sampleSize: Int,
        bytesPerPixel: Int,
        x: Int,
        y: Int,
        size: Int
    ) -> Double {
        var darkCount = 0
        var lightCount = 0
        var transitions = 0
        var lastIsDark: Bool?

        for row in y..<(y + size) {
            lastIsDark = nil
            for col in x..<(x + size) {
                let offset = (row * sampleSize + col) * bytesPerPixel
                let r = Double(pixels[offset])
                let g = Double(pixels[offset + 1])
                let b = Double(pixels[offset + 2])
                let luminance = 0.299 * r + 0.587 * g + 0.114 * b
                let isDark = luminance < 85
                let isLight = luminance > 175

                if isDark { darkCount += 1 }
                if isLight { lightCount += 1 }
                if let lastIsDark, lastIsDark != isDark, isDark || luminance > 150 {
                    transitions += 1
                }
                lastIsDark = isDark
            }
        }

        let total = Double(size * size)
        let darkRatio = Double(darkCount) / total
        let lightRatio = Double(lightCount) / total
        let transitionRatio = Double(transitions) / Double(size * size)

        guard darkRatio > 0.05, darkRatio < 0.85, lightRatio > 0.05 else {
            return 0
        }

        return min(1, transitionRatio * 5.5) * 0.7 + min(darkRatio, lightRatio) * 0.3
    }
}

private extension UIImage {
    var cgImagePropertyOrientation: CGImagePropertyOrientation {
        switch imageOrientation {
        case .up:
            return .up
        case .upMirrored:
            return .upMirrored
        case .down:
            return .down
        case .downMirrored:
            return .downMirrored
        case .left:
            return .left
        case .leftMirrored:
            return .leftMirrored
        case .right:
            return .right
        case .rightMirrored:
            return .rightMirrored
        @unknown default:
            return .up
        }
    }
}
