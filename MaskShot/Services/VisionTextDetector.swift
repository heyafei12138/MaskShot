import UIKit
import Vision

struct RecognizedTextBlock {
    let text: String
    let boundingBox: CGRect
}

enum VisionDetectionError: Error {
    case missingCGImage
}

final class VisionTextDetector {
    func detectText(in image: UIImage, completion: @escaping (Result<[RecognizedTextBlock], Error>) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(.failure(VisionDetectionError.missingCGImage))
            return
        }

        let request = VNRecognizeTextRequest { request, error in
            if let error {
                completion(.failure(error))
                return
            }

            let observations = (request.results as? [VNRecognizedTextObservation]) ?? []
            let blocks = observations.compactMap { observation -> RecognizedTextBlock? in
                guard let candidate = observation.topCandidates(1).first else { return nil }
                return RecognizedTextBlock(
                    text: candidate.string,
                    boundingBox: observation.boundingBox.convertedFromVisionCoordinates().clampedToUnit()
                )
            }
            completion(.success(blocks))
        }

        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["en-US", "zh-Hans", "zh-Hant"]
        request.usesLanguageCorrection = true

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
