import Photos
import UIKit

enum ExportServiceError: Error {
    case missingImageData
    case saveFailed
}

final class ExportService {
    private let renderer = RedactionRenderer()

    func render(session: RedactionSession) -> UIImage {
        renderer.render(session: session)
    }

    func jpegDataWithoutMetadata(from image: UIImage) throws -> Data {
        guard let data = image.jpegData(compressionQuality: 0.96) else {
            throw ExportServiceError.missingImageData
        }
        return data
    }

    func copyToPasteboard(_ image: UIImage) {
        UIPasteboard.general.image = image
    }

    func saveToPhotoLibrary(_ image: UIImage, completion: @escaping (Result<Void, Error>) -> Void) {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            guard status == .authorized || status == .limited else {
                DispatchQueue.main.async {
                    completion(.failure(ExportServiceError.saveFailed))
                }
                return
            }

            PHPhotoLibrary.shared().performChanges {
                PHAssetCreationRequest.creationRequestForAsset(from: image)
            } completionHandler: { success, error in
                DispatchQueue.main.async {
                    if success {
                        completion(.success(()))
                    } else {
                        completion(.failure(error ?? ExportServiceError.saveFailed))
                    }
                }
            }
        }
    }
}
