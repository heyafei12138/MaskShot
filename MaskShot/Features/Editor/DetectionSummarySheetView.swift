import SnapKit
import UIKit

protocol DetectionSummarySheetViewDelegate: AnyObject {
    func detectionSummarySheetDidSelectAll(_ view: DetectionSummarySheetView)
    func detectionSummarySheetDidSelectManual(_ view: DetectionSummarySheetView)
    func detectionSummarySheetDidSelectStyle(_ view: DetectionSummarySheetView)
    func detectionSummarySheetDidSelectRedact(_ view: DetectionSummarySheetView)
}

final class DetectionSummarySheetView: UIView {
    weak var delegate: DetectionSummarySheetViewDelegate?

    private let titleLabel = UILabel()
    private let chipsStack = UIStackView()
    private let actionsStack = UIStackView()
    private let selectAllButton = UIButton(type: .system)
    private let manualButton = UIButton(type: .system)
    private let styleButton = UIButton(type: .system)
    private let redactButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupLayout()
        update(items: [], style: .blackout, isScanning: false)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(items: [SensitiveItem], style: RedactionStyle, isScanning: Bool) {
        let selectedCount = items.filter(\.isSelected).count
        titleLabel.text = isScanning ? "Scanning screenshot..." : "Found \(items.count) possible leaks · \(selectedCount) selected"
        styleButton.setTitle(style.displayName, for: .normal)
        redactButton.isEnabled = selectedCount > 0
        redactButton.alpha = selectedCount > 0 ? 1 : 0.5

        chipsStack.arrangedSubviews.forEach { view in
            chipsStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        let grouped = Dictionary(grouping: items, by: \.type)
        let sortedTypes = grouped.keys.sorted { $0.displayName < $1.displayName }
        if sortedTypes.isEmpty {
            chipsStack.addArrangedSubview(makeChip("No leaks yet"))
        } else {
            sortedTypes.forEach { type in
                chipsStack.addArrangedSubview(makeChip("\(type.displayName) \(grouped[type]?.count ?? 0)"))
            }
        }
    }
}

private extension DetectionSummarySheetView {
    func setupView() {
        backgroundColor = AppTheme.Color.secondaryBackground
        layer.cornerRadius = AppTheme.Radius.sheet
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        layer.borderColor = AppTheme.Color.border.cgColor
        layer.borderWidth = 1

        titleLabel.textColor = AppTheme.Color.primaryText
        titleLabel.font = AppTheme.Font.headline
        titleLabel.numberOfLines = 2

        chipsStack.axis = .horizontal
        chipsStack.spacing = AppTheme.Spacing.sm
        chipsStack.alignment = .leading

        actionsStack.axis = .horizontal
        actionsStack.spacing = AppTheme.Spacing.sm
        actionsStack.distribution = .fillEqually

        configureButton(selectAllButton, title: "Select All", image: "checklist")
        configureButton(manualButton, title: "Manual", image: "square.dashed")
        configureButton(styleButton, title: "Blackout", image: "circle.lefthalf.filled")
        configureButton(redactButton, title: "Redact", image: "eye.slash.fill", emphasized: true)

        selectAllButton.addTarget(self, action: #selector(onSelectAll), for: .touchUpInside)
        manualButton.addTarget(self, action: #selector(onManual), for: .touchUpInside)
        styleButton.addTarget(self, action: #selector(onStyle), for: .touchUpInside)
        redactButton.addTarget(self, action: #selector(onRedact), for: .touchUpInside)

        addSubview(titleLabel)
        addSubview(chipsStack)
        addSubview(actionsStack)

        [selectAllButton, manualButton, styleButton, redactButton].forEach(actionsStack.addArrangedSubview)
    }

    func setupLayout() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(AppTheme.Spacing.lg)
            make.left.right.equalToSuperview().inset(AppTheme.Spacing.lg)
        }

        chipsStack.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(AppTheme.Spacing.md)
            make.left.right.equalToSuperview().inset(AppTheme.Spacing.lg)
            make.height.equalTo(30)
        }

        actionsStack.snp.makeConstraints { make in
            make.top.equalTo(chipsStack.snp.bottom).offset(AppTheme.Spacing.md)
            make.left.right.equalToSuperview().inset(AppTheme.Spacing.md)
            make.bottom.equalTo(safeAreaLayoutGuide).offset(-AppTheme.Spacing.md)
            make.height.equalTo(48)
        }
    }

    func configureButton(_ button: UIButton, title: String, image: String, emphasized: Bool = false) {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.image = UIImage(systemName: image)
        config.imagePadding = 6
        config.cornerStyle = .medium
        config.baseBackgroundColor = emphasized ? AppTheme.Color.primaryAccent : AppTheme.Color.elevatedSurface
        config.baseForegroundColor = AppTheme.Color.primaryText
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = AppTheme.Font.caption
            return outgoing
        }
        button.configuration = config
    }

    func makeChip(_ title: String) -> UILabel {
        let label = UILabel()
        label.text = title
        label.textColor = AppTheme.Color.primaryText
        label.font = AppTheme.Font.caption
        label.backgroundColor = AppTheme.Color.elevatedSurface
        label.layer.cornerRadius = 15
        label.layer.masksToBounds = true
        label.textAlignment = .center
        label.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.width.greaterThanOrEqualTo(72)
        }
        return label
    }

    @objc func onSelectAll() {
        delegate?.detectionSummarySheetDidSelectAll(self)
    }

    @objc func onManual() {
        delegate?.detectionSummarySheetDidSelectManual(self)
    }

    @objc func onStyle() {
        delegate?.detectionSummarySheetDidSelectStyle(self)
    }

    @objc func onRedact() {
        delegate?.detectionSummarySheetDidSelectRedact(self)
    }
}
