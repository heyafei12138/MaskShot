import Photos
import UIKit

final class LatestScreenshotService {
    enum LatestScreenshotResult {
        case image(UIImage, Date?)
        case noScreenshot
        case denied
    }

    func loadLatestScreenshot(
        requestsAuthorization: Bool,
        completion: @escaping (LatestScreenshotResult) -> Void
    ) {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)

        switch status {
        case .authorized, .limited:
            fetchLatestScreenshot(completion: completion)
        case .notDetermined:
            guard requestsAuthorization else {
                completion(.noScreenshot)
                return
            }

            PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] newStatus in
                DispatchQueue.main.async {
                    guard newStatus == .authorized || newStatus == .limited else {
                        completion(.denied)
                        return
                    }
                    self?.fetchLatestScreenshot(completion: completion)
                }
            }
        case .denied, .restricted:
            completion(.denied)
        @unknown default:
            completion(.denied)
        }
    }

    private func fetchLatestScreenshot(completion: @escaping (LatestScreenshotResult) -> Void) {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.fetchLimit = 1

        let assets = PHAsset.fetchAssets(with: .image, options: options)
        var screenshotAsset: PHAsset?

        assets.enumerateObjects { asset, _, stop in
            if asset.mediaSubtypes.contains(.photoScreenshot) {
                screenshotAsset = asset
                stop.pointee = true
            }
        }

        guard let screenshotAsset else {
            completion(.noScreenshot)
            return
        }

        let requestOptions = PHImageRequestOptions()
        requestOptions.deliveryMode = .highQualityFormat
        requestOptions.resizeMode = .fast
        requestOptions.isNetworkAccessAllowed = false

        PHImageManager.default().requestImage(
            for: screenshotAsset,
            targetSize: CGSize(width: 1200, height: 1200),
            contentMode: .aspectFit,
            options: requestOptions
        ) { image, _ in
            DispatchQueue.main.async {
                guard let image else {
                    completion(.noScreenshot)
                    return
                }
                completion(.image(image, screenshotAsset.creationDate))
            }
        }
    }
}
