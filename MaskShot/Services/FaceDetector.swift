import UIKit
import Vision

final class FaceDetector {
    func detectFaces(in image: UIImage, completion: @escaping (Result<[SensitiveItem], Error>) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(.failure(VisionDetectionError.missingCGImage))
            return
        }

        let request = VNDetectFaceRectanglesRequest { request, error in
            if let error {
                completion(.failure(error))
                return
            }

            let observations = (request.results as? [VNFaceObservation]) ?? []
            let items = observations.map { observation in
                SensitiveItem(
                    type: .face,
                    riskLevel: .high,
                    boundingBox: observation.boundingBox.convertedFromVisionCoordinates().expandedBy(percent: 0.16).clampedToUnit(),
                    isSelected: true,
                    source: .faceDetection
                )
            }
            completion(.success(items))
        }

        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: image.cgImagePropertyOrientation)
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                completion(.failure(error))
            }
        }
    }
}

private extension CGRect {
    func convertedFromVisionCoordinates() -> CGRect {
        CGRect(x: minX, y: 1 - maxY, width: width, height: height)
    }

    func expandedBy(percent: CGFloat) -> CGRect {
        insetBy(dx: -width * percent, dy: -height * percent)
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
