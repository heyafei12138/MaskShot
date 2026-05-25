import PhotosUI
import SnapKit
import UIKit

final class HomeViewController: UIViewController {
    private let latestScreenshotService = LatestScreenshotService()
    private let settingsStore = SettingsStore.shared
    private var latestScreenshotImage: UIImage?
    private var hasAutoLoadedLatestScreenshot = false

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "MaskShot"
        label.textColor = AppTheme.Color.primaryText
        label.font = AppTheme.Font.largeTitle
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Check screenshots before sharing."
        label.textColor = AppTheme.Color.secondaryText
        label.font = AppTheme.Font.body
        return label
    }()

    private let settingsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "gearshape.fill"), for: .normal)
        button.tintColor = AppTheme.Color.primaryText
        button.backgroundColor = AppTheme.Color.elevatedSurface
        button.layer.cornerRadius = AppTheme.Radius.medium
        return button
    }()

    private let previewCardView: UIView = {
        let view = UIView()
        view.backgroundColor = AppTheme.Color.secondaryBackground
        view.layer.cornerRadius = AppTheme.Radius.sheet
        view.layer.borderColor = AppTheme.Color.border.cgColor
        view.layer.borderWidth = 1
        return view
    }()

    private let previewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = AppTheme.Radius.large
        imageView.backgroundColor = AppTheme.Color.elevatedSurface
        return imageView
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Ready to check your screenshot"
        label.textColor = AppTheme.Color.primaryText
        label.font = AppTheme.Font.headline
        label.numberOfLines = 0
        return label
    }()

    private let detailLabel: UILabel = {
        let label = UILabel()
        label.text = "Choose an image, or let MaskShot find your latest screenshot. Processing stays on device."
        label.textColor = AppTheme.Color.secondaryText
        label.font = AppTheme.Font.body
        label.numberOfLines = 0
        return label
    }()

    private let checkLatestButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Check Latest Screenshot", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = AppTheme.Font.headline
        button.backgroundColor = AppTheme.Color.activeAccent
        button.layer.cornerRadius = AppTheme.Radius.medium
        return button
    }()

    private let chooseImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Choose Image", for: .normal)
        button.setTitleColor(AppTheme.Color.primaryText, for: .normal)
        button.titleLabel?.font = AppTheme.Font.headline
        button.backgroundColor = AppTheme.Color.elevatedSurface
        button.layer.cornerRadius = AppTheme.Radius.medium
        button.layer.borderColor = AppTheme.Color.border.cgColor
        button.layer.borderWidth = 1
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupLayout()
        showInitialState()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard settingsStore.autoLoadLatestScreenshot, !hasAutoLoadedLatestScreenshot else { return }
        hasAutoLoadedLatestScreenshot = true
        loadLatestScreenshotPreview(requestsAuthorization: false)
    }
}

private extension HomeViewController {
    func setupView() {
        view.backgroundColor = AppTheme.Color.mainBackground

        settingsButton.addTarget(self, action: #selector(onSettingsPressed), for: .touchUpInside)
        checkLatestButton.addTarget(self, action: #selector(onCheckLatestPressed), for: .touchUpInside)
        chooseImageButton.addTarget(self, action: #selector(onChooseImagePressed), for: .touchUpInside)

        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(settingsButton)
        view.addSubview(previewCardView)
        previewCardView.addSubview(previewImageView)
        previewCardView.addSubview(statusLabel)
        previewCardView.addSubview(detailLabel)
        view.addSubview(checkLatestButton)
        view.addSubview(chooseImageButton)
    }

    func setupLayout() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(AppTheme.Spacing.xl)
            make.left.equalTo(view.safeAreaLayoutGuide).offset(AppTheme.Spacing.lg)
            make.right.lessThanOrEqualTo(settingsButton.snp.left).offset(-AppTheme.Spacing.md)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(AppTheme.Spacing.xs)
            make.left.right.equalTo(titleLabel)
        }

        settingsButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.right.equalTo(view.safeAreaLayoutGuide).offset(-AppTheme.Spacing.lg)
            make.width.height.equalTo(44)
        }

        previewCardView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(AppTheme.Spacing.xl)
            make.left.right.equalTo(view.safeAreaLayoutGuide).inset(AppTheme.Spacing.lg)
        }

        previewImageView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(AppTheme.Spacing.md)
            make.height.equalTo(330)
        }

        statusLabel.snp.makeConstraints { make in
            make.top.equalTo(previewImageView.snp.bottom).offset(AppTheme.Spacing.md)
            make.left.right.equalToSuperview().inset(AppTheme.Spacing.lg)
        }

        detailLabel.snp.makeConstraints { make in
            make.top.equalTo(statusLabel.snp.bottom).offset(AppTheme.Spacing.sm)
            make.left.right.equalTo(statusLabel)
            make.bottom.equalToSuperview().offset(-AppTheme.Spacing.lg)
        }

        chooseImageButton.snp.makeConstraints { make in
            make.left.right.equalTo(view.safeAreaLayoutGuide).inset(AppTheme.Spacing.lg)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-AppTheme.Spacing.md)
            make.height.equalTo(54)
        }

        checkLatestButton.snp.makeConstraints { make in
            make.left.right.height.equalTo(chooseImageButton)
            make.bottom.equalTo(chooseImageButton.snp.top).offset(-AppTheme.Spacing.sm)
        }
    }

    func showInitialState() {
        latestScreenshotImage = nil
        previewImageView.image = Self.placeholderImage()
        statusLabel.text = "Ready to check your screenshot"
        detailLabel.text = "Choose an image, or tap Check Latest Screenshot to allow MaskShot to find your latest screenshot."
    }

    func loadLatestScreenshotPreview(requestsAuthorization: Bool) {
        statusLabel.text = "Looking for your latest screenshot..."

        latestScreenshotService.loadLatestScreenshot(requestsAuthorization: requestsAuthorization) { [weak self] result in
            guard let self else { return }

            switch result {
            case .image(let image, let date):
                latestScreenshotImage = image
                previewImageView.image = image
                statusLabel.text = "Latest screenshot ready"
                detailLabel.text = date.map { "Captured \(Self.relativeDateFormatter.localizedString(for: $0, relativeTo: Date())). Tap Check Latest Screenshot to review it." }
                    ?? "Tap Check Latest Screenshot to review it."
            case .noScreenshot:
                latestScreenshotImage = nil
                previewImageView.image = Self.placeholderImage()
                statusLabel.text = "No recent screenshots found"
                detailLabel.text = requestsAuthorization
                    ? "Take a screenshot or choose an image to start."
                    : "Tap Check Latest Screenshot to allow access, or choose an image manually."
            case .denied:
                latestScreenshotImage = nil
                previewImageView.image = Self.placeholderImage()
                statusLabel.text = "Photo access is needed to load your latest screenshot."
                detailLabel.text = "Choose Image still works without granting full photo access."
                showPhotoAccessOptions()
            }
        }
    }

    func openEditor(with image: UIImage) {
        let session = RedactionSession(
            originalImage: image.bitmapNormalized(),
            redactionStyle: settingsStore.defaultRedactionStyle
        )
        let editorViewController = EditorViewController(session: session)
        navigationController?.pushViewController(editorViewController, animated: true)
    }

    func showPhotoAccessOptions() {
        let alert = UIAlertController(
            title: "Photo access is needed to load your latest screenshot.",
            message: "You can choose a single image manually, or open Settings to allow screenshot lookup.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Choose Image", style: .default) { [weak self] _ in
            self?.onChooseImagePressed()
        })
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(url)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    @objc func onSettingsPressed() {
        navigationController?.pushViewController(SettingsViewController(), animated: true)
    }

    @objc func onCheckLatestPressed() {
        if let latestScreenshotImage {
            openEditor(with: latestScreenshotImage)
            return
        }

        loadLatestScreenshotPreview(requestsAuthorization: true)
    }

    @objc func onChooseImagePressed() {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = .images
        configuration.selectionLimit = 1

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }

    static let relativeDateFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter
    }()

    static func placeholderImage() -> UIImage? {
        let size = CGSize(width: 700, height: 900)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            AppTheme.Color.elevatedSurface.setFill()
            context.fill(CGRect(origin: .zero, size: size))

            AppTheme.Color.border.setFill()
            UIBezierPath(roundedRect: CGRect(x: 90, y: 120, width: 520, height: 54), cornerRadius: 18).fill()
            UIBezierPath(roundedRect: CGRect(x: 130, y: 230, width: 420, height: 38), cornerRadius: 14).fill()

            AppTheme.Color.blackout.setFill()
            UIBezierPath(roundedRect: CGRect(x: 160, y: 330, width: 360, height: 42), cornerRadius: 8).fill()
            UIBezierPath(roundedRect: CGRect(x: 110, y: 490, width: 460, height: 42), cornerRadius: 8).fill()

            AppTheme.Color.primaryAccent.setFill()
            UIBezierPath(ovalIn: CGRect(x: 88, y: 226, width: 44, height: 44)).fill()
        }
    }
}

extension HomeViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else {
            return
        }

        provider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
            guard let image = object as? UIImage else { return }
            DispatchQueue.main.async {
                self?.openEditor(with: image)
            }
        }
    }
}
