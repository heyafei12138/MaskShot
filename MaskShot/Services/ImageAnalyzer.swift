import UIKit

final class ImageAnalyzer {
    private let textDetector = VisionTextDetector()
    private let infoDetector = SensitiveInfoDetector()
    private let faceDetector = FaceDetector()
    private let barcodeDetector = BarcodeDetector()
    private let merger = DetectionMerger()

    func analyze(_ image: UIImage, completion: @escaping (Result<[SensitiveItem], Error>) -> Void) {
        let lock = NSLock()
        var allItems: [SensitiveItem] = []
        var errors: [Error] = []
        var pendingRequestCount = 3

        func record(result: Result<[SensitiveItem], Error>) {
            lock.lock()
            switch result {
            case .success(let items):
                allItems.append(contentsOf: items)
            case .failure(let error):
                errors.append(error)
            }

            pendingRequestCount -= 1
            let shouldFinish = pendingRequestCount == 0
            let currentItems = allItems
            let currentErrors = errors
            lock.unlock()

            guard shouldFinish else { return }

            let merged = merger.merge(currentItems).sorted { lhs, rhs in
                if lhs.riskLevel != rhs.riskLevel {
                    return lhs.riskLevel.sortRank > rhs.riskLevel.sortRank
                }
                return lhs.boundingBox.minY < rhs.boundingBox.minY
            }

            if merged.isEmpty, let firstError = currentErrors.first {
                completion(.failure(firstError))
            } else {
                completion(.success(merged))
            }
        }

        textDetector.detectText(in: image) { [infoDetector] result in
            switch result {
            case .success(let blocks):
                record(result: .success(infoDetector.detect(in: blocks)))
            case .failure(let error):
                record(result: .failure(error))
            }
        }

        faceDetector.detectFaces(in: image) { result in
            record(result: result)
        }

        barcodeDetector.detectBarcodes(in: image) { result in
            record(result: result)
        }
    }
}

private extension RiskLevel {
    var sortRank: Int {
        switch self {
        case .high:
            return 3
        case .medium:
            return 2
        case .low:
            return 1
        }
    }
}
