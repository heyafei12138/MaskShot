import SnapKit
import UIKit

final class SettingsViewController: UIViewController {
    private let store = SettingsStore.shared
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let titleLabel = UILabel()
    private let styleValueLabel = UILabel()
    private let autoLoadSwitch = UISwitch()
    private let metadataSwitch = UISwitch()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupLayout()
        reloadValues()
    }
}

private extension SettingsViewController {
    func setupView() {
        view.backgroundColor = AppTheme.Color.mainBackground

        titleLabel.text = "Settings"
        titleLabel.textColor = AppTheme.Color.primaryText
        titleLabel.font = AppTheme.Font.title

        contentStack.axis = .vertical
        contentStack.spacing = AppTheme.Spacing.md

        autoLoadSwitch.onTintColor = AppTheme.Color.primaryAccent
        metadataSwitch.onTintColor = AppTheme.Color.primaryAccent
        autoLoadSwitch.addTarget(self, action: #selector(onAutoLoadChanged), for: .valueChanged)
        metadataSwitch.addTarget(self, action: #selector(onMetadataChanged), for: .valueChanged)

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
    }

    func setupLayout() {
        let backButton = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "chevron.left")
        config.cornerStyle = .medium
        config.baseBackgroundColor = AppTheme.Color.elevatedSurface
        config.baseForegroundColor = AppTheme.Color.primaryText
        backButton.configuration = config
        backButton.addTarget(self, action: #selector(onBackPressed), for: .touchUpInside)

        view.addSubview(backButton)
        view.addSubview(titleLabel)

        backButton.snp.makeConstraints { make in
            make.left.equalTo(view.safeAreaLayoutGuide).offset(AppTheme.Spacing.md)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(AppTheme.Spacing.md)
            make.width.height.equalTo(44)
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(backButton.snp.right).offset(AppTheme.Spacing.md)
            make.centerY.equalTo(backButton)
            make.right.lessThanOrEqualTo(view.safeAreaLayoutGuide).offset(-AppTheme.Spacing.md)
        }

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(AppTheme.Spacing.lg)
            make.left.right.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        contentStack.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide).inset(AppTheme.Spacing.md)
            make.width.equalTo(scrollView.frameLayoutGuide).offset(-AppTheme.Spacing.md * 2)
        }

        contentStack.addArrangedSubview(makeDisclosureRow(title: "Default Redaction Style", detailLabel: styleValueLabel, action: #selector(onStylePressed)))
        contentStack.addArrangedSubview(makeSwitchRow(title: "Auto-load Latest Screenshot", detail: "Ask for photo access only when needed.", control: autoLoadSwitch))
        contentStack.addArrangedSubview(makeSwitchRow(title: "Remove Metadata on Export", detail: "Generated images are new bitmaps.", control: metadataSwitch))
        contentStack.addArrangedSubview(makeStaticRow(title: "Appearance", detail: store.appearance))
        contentStack.addArrangedSubview(makeDisclosureRow(title: "Privacy Policy", detail: "Local document", action: #selector(onPrivacyPressed)))
        contentStack.addArrangedSubview(makeDisclosureRow(title: "Terms of Use", detail: "Local document", action: #selector(onTermsPressed)))
        contentStack.addArrangedSubview(makeStaticRow(title: "Version", detail: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"))
        contentStack.addArrangedSubview(makeDisclosureRow(title: "Contact", detail: "support@maskshot.app", action: #selector(onContactPressed)))
    }

    func reloadValues() {
        styleValueLabel.text = store.defaultRedactionStyle.displayName
        autoLoadSwitch.isOn = store.autoLoadLatestScreenshot
        metadataSwitch.isOn = store.removeMetadataOnExport
    }

    func makeCard() -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = AppTheme.Spacing.xs
        stack.layoutMargins = UIEdgeInsets(top: AppTheme.Spacing.md, left: AppTheme.Spacing.md, bottom: AppTheme.Spacing.md, right: AppTheme.Spacing.md)
        stack.isLayoutMarginsRelativeArrangement = true
        stack.backgroundColor = AppTheme.Color.secondaryBackground
        stack.layer.cornerRadius = AppTheme.Radius.medium
        stack.layer.borderColor = AppTheme.Color.border.cgColor
        stack.layer.borderWidth = 1
        return stack
    }

    func makeSwitchRow(title: String, detail: String, control: UISwitch) -> UIView {
        let container = UIView()
        let labels = makeCard()
        let titleLabel = makeLabel(title, font: AppTheme.Font.headline, color: AppTheme.Color.primaryText)
        let detailLabel = makeLabel(detail, font: AppTheme.Font.caption, color: AppTheme.Color.secondaryText)

        container.addSubview(labels)
        container.addSubview(control)
        labels.addArrangedSubview(titleLabel)
        labels.addArrangedSubview(detailLabel)

        labels.snp.makeConstraints { make in
            make.top.left.bottom.equalToSuperview()
            make.right.equalTo(control.snp.left).offset(-AppTheme.Spacing.md)
        }
        control.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-AppTheme.Spacing.md)
            make.centerY.equalToSuperview()
        }
        return container
    }

    func makeStaticRow(title: String, detail: String) -> UIView {
        let stack = makeCard()
        stack.addArrangedSubview(makeLabel(title, font: AppTheme.Font.headline, color: AppTheme.Color.primaryText))
        stack.addArrangedSubview(makeLabel(detail, font: AppTheme.Font.caption, color: AppTheme.Color.secondaryText))
        return stack
    }

    func makeDisclosureRow(title: String, detail: String, action: Selector) -> UIView {
        let label = UILabel()
        label.text = detail
        return makeDisclosureRow(title: title, detailLabel: label, action: action)
    }

    func makeDisclosureRow(title: String, detailLabel: UILabel, action: Selector) -> UIView {
        let button = UIButton(type: .system)
        button.backgroundColor = AppTheme.Color.secondaryBackground
        button.layer.cornerRadius = AppTheme.Radius.medium
        button.layer.borderColor = AppTheme.Color.border.cgColor
        button.layer.borderWidth = 1
        button.addTarget(self, action: action, for: .touchUpInside)

        let titleLabel = makeLabel(title, font: AppTheme.Font.headline, color: AppTheme.Color.primaryText)
        detailLabel.textColor = AppTheme.Color.secondaryText
        detailLabel.font = AppTheme.Font.caption
        detailLabel.textAlignment = .left
        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = AppTheme.Color.secondaryText

        button.addSubview(titleLabel)
        button.addSubview(detailLabel)
        button.addSubview(chevron)

        titleLabel.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(AppTheme.Spacing.md)
            make.right.lessThanOrEqualTo(chevron.snp.left).offset(-AppTheme.Spacing.sm)
        }
        detailLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(AppTheme.Spacing.xs)
            make.left.equalTo(titleLabel)
            make.right.lessThanOrEqualTo(chevron.snp.left).offset(-AppTheme.Spacing.sm)
            make.bottom.equalToSuperview().offset(-AppTheme.Spacing.md)
        }
        chevron.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-AppTheme.Spacing.md)
            make.centerY.equalToSuperview()
            make.width.equalTo(10)
        }
        return button
    }

    func makeLabel(_ text: String, font: UIFont, color: UIColor) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = color
        label.numberOfLines = 0
        return label
    }

    func showLocalDocument(title: String, body: String) {
        let alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc func onBackPressed() {
        navigationController?.popViewController(animated: true)
    }

    @objc func onStylePressed() {
        let alert = UIAlertController(title: "Default Redaction Style", message: nil, preferredStyle: .actionSheet)
        RedactionStyle.allCases.forEach { style in
            alert.addAction(UIAlertAction(title: style.displayName, style: .default) { [weak self] _ in
                self?.store.defaultRedactionStyle = style
                self?.reloadValues()
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    @objc func onAutoLoadChanged() {
        store.autoLoadLatestScreenshot = autoLoadSwitch.isOn
    }

    @objc func onMetadataChanged() {
        store.removeMetadataOnExport = metadataSwitch.isOn
    }

    @objc func onPrivacyPressed() {
        showLocalDocument(title: "Privacy Policy", body: "MaskShot processes images on device. The app does not create accounts, upload screenshots, or store image history.")
    }

    @objc func onTermsPressed() {
        showLocalDocument(title: "Terms of Use", body: "MaskShot is provided for personal screenshot review. You are responsible for reviewing exported images before sharing.")
    }

    @objc func onContactPressed() {
        showLocalDocument(title: "Contact", body: "For support, contact support@maskshot.app.")
    }
}
