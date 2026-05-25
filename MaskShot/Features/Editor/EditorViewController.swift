import SnapKit
import UIKit

final class EditorViewController: UIViewController {
    private var session: RedactionSession
    private let analyzer = ImageAnalyzer()
    private let exportService = ExportService()
    private var isScanning = false
    private var isManualMode = false
    private var itemHistory: [[SensitiveItem]] = []

    private let topBar = UIView()
    private let backButton = UIButton(type: .system)
    private let undoButton = UIButton(type: .system)
    private let shareButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let statusLabel = UILabel()
    private let imagePreview = RedactionImageView()
    private let overlayView = DetectionOverlayView()
    private let summarySheet = DetectionSummarySheetView()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    init(session: RedactionSession) {
        self.session = session
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupLayout()
        updateContent()
        startAnalysis()
    }
}

private extension EditorViewController {
    func setupView() {
        view.backgroundColor = AppTheme.Color.mainBackground

        configureIconButton(backButton, imageName: "chevron.left")
        configureIconButton(undoButton, imageName: "arrow.uturn.backward")
        configureIconButton(shareButton, imageName: "square.and.arrow.up")
        undoButton.isEnabled = false
        undoButton.alpha = 0.45

        backButton.addTarget(self, action: #selector(onBackPressed), for: .touchUpInside)
        undoButton.addTarget(self, action: #selector(onUndoPressed), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(onSharePressed), for: .touchUpInside)

        titleLabel.text = "Review"
        titleLabel.textColor = AppTheme.Color.primaryText
        titleLabel.font = AppTheme.Font.headline

        statusLabel.textColor = AppTheme.Color.secondaryText
        statusLabel.font = AppTheme.Font.caption
        statusLabel.numberOfLines = 2

        imagePreview.image = session.originalImage
        imagePreview.delegate = self

        overlayView.onToggleItem = { [weak self] id in
            self?.toggleItem(id)
        }
        overlayView.onAddManualItem = { [weak self] normalizedRect in
            self?.addManualItem(normalizedRect)
        }
        overlayView.onDeleteItem = { [weak self] id in
            self?.deleteManualItem(id)
        }

        summarySheet.delegate = self

        activityIndicator.color = AppTheme.Color.primaryAccent
        activityIndicator.hidesWhenStopped = true

        view.addSubview(topBar)
        topBar.addSubview(backButton)
        topBar.addSubview(titleLabel)
        topBar.addSubview(statusLabel)
        topBar.addSubview(undoButton)
        topBar.addSubview(shareButton)
        view.addSubview(imagePreview)
        view.addSubview(overlayView)
        view.addSubview(activityIndicator)
        view.addSubview(summarySheet)
    }

    func setupLayout() {
        topBar.snp.makeConstraints { make in
            make.top.left.right.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(72)
        }

        backButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(AppTheme.Spacing.md)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }

        shareButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-AppTheme.Spacing.md)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }

        undoButton.snp.makeConstraints { make in
            make.right.equalTo(shareButton.snp.left).offset(-AppTheme.Spacing.sm)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(backButton.snp.right).offset(AppTheme.Spacing.md)
            make.right.lessThanOrEqualTo(undoButton.snp.left).offset(-AppTheme.Spacing.md)
            make.top.equalToSuperview().offset(AppTheme.Spacing.md)
        }

        statusLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.right.lessThanOrEqualTo(undoButton.snp.left).offset(-AppTheme.Spacing.md)
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
        }

        imagePreview.snp.makeConstraints { make in
            make.top.equalTo(topBar.snp.bottom).offset(AppTheme.Spacing.sm)
            make.left.right.equalTo(view.safeAreaLayoutGuide).inset(AppTheme.Spacing.md)
            make.bottom.equalTo(summarySheet.snp.top).offset(-AppTheme.Spacing.md)
        }

        overlayView.snp.makeConstraints { make in
            make.edges.equalTo(imagePreview)
        }

        activityIndicator.snp.makeConstraints { make in
            make.center.equalTo(imagePreview)
        }

        summarySheet.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.greaterThanOrEqualTo(178)
        }
    }

    func configureIconButton(_ button: UIButton, imageName: String) {
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: imageName)
        config.cornerStyle = .medium
        config.baseBackgroundColor = AppTheme.Color.elevatedSurface
        config.baseForegroundColor = AppTheme.Color.primaryText
        button.configuration = config
    }

    func startAnalysis() {
        guard session.sensitiveItems.isEmpty else { return }
        isScanning = true
        updateContent()
        activityIndicator.startAnimating()

        analyzer.analyze(session.originalImage) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isScanning = false
                self.activityIndicator.stopAnimating()

                switch result {
                case .success(let items):
                    self.session.sensitiveItems = items
                    if items.isEmpty {
                        self.statusLabel.text = "No possible sensitive items found."
                        self.showNoResultsOptions()
                    } else {
                        self.statusLabel.text = "Tap a box to include or exclude it."
                    }
                case .failure:
                    self.statusLabel.text = "Couldn’t scan this image."
                    self.showScanFailureOptions()
                }

                self.updateContent()
            }
        }
    }

    func updateContent() {
        overlayView.items = session.sensitiveItems
        overlayView.isManualMode = isManualMode
        summarySheet.update(items: session.sensitiveItems, style: session.redactionStyle, isScanning: isScanning)
        updateUndoButton()

        if isScanning {
            statusLabel.text = "Checking text, faces, and codes on device."
        } else if isManualMode {
            statusLabel.text = "Drag on the image to add a manual mask."
        } else if session.sensitiveItems.isEmpty {
            statusLabel.text = "No results yet."
        }
    }

    func toggleItem(_ id: SensitiveItem.ID) {
        pushHistory()
        session.toggleSelection(for: id)
        updateContent()
    }

    func addManualItem(_ normalizedRect: CGRect) {
        pushHistory()
        session.addManualItem(in: normalizedRect)
        isManualMode = false
        statusLabel.text = "Manual mask added. Tap it to include or exclude it."
        updateContent()
    }

    func deleteManualItem(_ id: SensitiveItem.ID) {
        guard session.sensitiveItems.contains(where: { $0.id == id && $0.type == .manual }) else { return }
        pushHistory()
        session.removeItem(id: id)
        statusLabel.text = "Manual mask removed."
        updateContent()
    }

    func pushHistory() {
        itemHistory.append(session.sensitiveItems)
        if itemHistory.count > 30 {
            itemHistory.removeFirst()
        }
        updateUndoButton()
    }

    func updateUndoButton() {
        undoButton.isEnabled = !itemHistory.isEmpty
        undoButton.alpha = itemHistory.isEmpty ? 0.45 : 1
    }

    @objc func onBackPressed() {
        navigationController?.popViewController(animated: true)
    }

    @objc func onUndoPressed() {
        guard let previousItems = itemHistory.popLast() else { return }
        session.sensitiveItems = previousItems
        isManualMode = false
        statusLabel.text = "Last change undone."
        updateContent()
    }

    @objc func onSharePressed() {
        presentExportOptions()
    }

    func presentExportOptions() {
        let renderedImage = exportService.render(session: session)
        session.renderedImage = renderedImage

        let alert = UIAlertController(title: "Export Redacted Image", message: "A new image will be generated without editing the original.", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Save to Photos", style: .default) { [weak self] _ in
            self?.saveRenderedImage(renderedImage)
        })
        alert.addAction(UIAlertAction(title: "Copy Image", style: .default) { [weak self] _ in
            self?.exportService.copyToPasteboard(renderedImage)
            self?.showToast(title: "Image copied", message: "The redacted bitmap is ready to paste.")
        })
        alert.addAction(UIAlertAction(title: "Share...", style: .default) { [weak self] _ in
            self?.presentShareSheet(with: renderedImage)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        if let popover = alert.popoverPresentationController {
            popover.sourceView = shareButton
            popover.sourceRect = shareButton.bounds
        }
        present(alert, animated: true)
    }

    func saveRenderedImage(_ image: UIImage) {
        exportService.saveToPhotoLibrary(image) { [weak self] result in
            switch result {
            case .success:
                self?.showToast(title: "Saved", message: "The redacted image was saved to Photos.")
            case .failure:
                self?.showToast(title: "Couldn’t save the image.", message: "You can still copy or share it.")
            }
        }
    }

    func presentShareSheet(with image: UIImage) {
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        if let popover = activityViewController.popoverPresentationController {
            popover.sourceView = shareButton
            popover.sourceRect = shareButton.bounds
        }
        present(activityViewController, animated: true)
    }

    func showToast(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func showScanFailureOptions() {
        let alert = UIAlertController(
            title: "Couldn’t scan this image.",
            message: "You can add manual masks or choose another image.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Manual Redact", style: .default) { [weak self] _ in
            self?.isManualMode = true
            self?.updateContent()
        })
        alert.addAction(UIAlertAction(title: "Choose Another Image", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }

    func showNoResultsOptions() {
        let alert = UIAlertController(
            title: "No possible sensitive items found.",
            message: "You can add a manual redaction or share anyway.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Add Manual Redaction", style: .default) { [weak self] _ in
            self?.isManualMode = true
            self?.updateContent()
        })
        alert.addAction(UIAlertAction(title: "Share Anyway", style: .default) { [weak self] _ in
            self?.presentExportOptions()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}

extension EditorViewController: RedactionImageViewDelegate {
    func redactionImageView(_ view: RedactionImageView, didUpdate geometry: ImageDisplayGeometry) {
        overlayView.imageRect = geometry.displayedImageRect
    }
}

extension EditorViewController: DetectionSummarySheetViewDelegate {
    func detectionSummarySheetDidSelectAll(_ view: DetectionSummarySheetView) {
        pushHistory()
        session.selectAllItems()
        isManualMode = false
        updateContent()
    }

    func detectionSummarySheetDidSelectManual(_ view: DetectionSummarySheetView) {
        isManualMode.toggle()
        updateContent()
    }

    func detectionSummarySheetDidSelectStyle(_ view: DetectionSummarySheetView) {
        let styles = RedactionStyle.allCases
        guard let currentIndex = styles.firstIndex(of: session.redactionStyle) else { return }
        session.redactionStyle = styles[(currentIndex + 1) % styles.count]
        updateContent()
    }

    func detectionSummarySheetDidSelectRedact(_ view: DetectionSummarySheetView) {
        presentExportOptions()
    }
}
