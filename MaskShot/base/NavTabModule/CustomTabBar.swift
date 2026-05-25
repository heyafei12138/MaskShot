//
//  CustomTabBar.swift
//  SGNavTabModule
//

import UIKit
import SnapKit

public protocol CustomTabBarDelegate: AnyObject {
    func tabBar(_ tabBar: CustomTabBar, didSelectItemAt index: Int)
}

public struct SGTabBarItemConfig {
    public let title: String
    public let systemImage: String
    public let selectedSystemImage: String

    public init(title: String, systemImage: String, selectedSystemImage: String) {
        self.title = title
        self.systemImage = systemImage
        self.selectedSystemImage = selectedSystemImage
    }
}

open class CustomTabBar: UIView {
    public static let barHeight: CGFloat = 60

    public weak var delegate: CustomTabBarDelegate?

    public var selectedIndex: Int = 0 {
        didSet {
            updateSelectedItem()
        }
    }

    private var tabBarItems: [CustomTabBarItem] = []

    private let backgroundContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = NavTabColor.tabBarTint
        view.layer.cornerRadius = barHeight * 0.5
        view.clipsToBounds = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 12
        view.layer.shadowOpacity = 0.35
        return view
    }()

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.alignment = .center
        stack.spacing = 0
        return stack
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    public func configureItems(_ items: [SGTabBarItemConfig]) {
        tabBarItems.forEach { $0.removeFromSuperview() }
        tabBarItems.removeAll()

        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)

        for (index, item) in items.enumerated() {
            let normalImage = UIImage(systemName: item.systemImage, withConfiguration: symbolConfig)
            let selectedImage = UIImage(systemName: item.selectedSystemImage, withConfiguration: symbolConfig)

            let tabBarItem = CustomTabBarItem(
                title: item.title,
                normalImage: normalImage,
                selectedImage: selectedImage
            )

            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(itemTapped(_:)))
            tabBarItem.addGestureRecognizer(tapGesture)
            tabBarItem.tag = index
            tabBarItem.isUserInteractionEnabled = true

            stackView.addArrangedSubview(tabBarItem)
            tabBarItems.append(tabBarItem)
        }

        updateSelectedItem()
    }
}

private extension CustomTabBar {
    func setupUI() {
        backgroundColor = .clear

        addSubview(backgroundContainerView)
        backgroundContainerView.addSubview(stackView)

        backgroundContainerView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-8)
            make.top.equalToSuperview()
            make.height.equalTo(CustomTabBar.barHeight)
        }

        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 2, left: 12, bottom: 2, right: 12))
        }
    }

    @objc func itemTapped(_ gesture: UITapGestureRecognizer) {
        guard let view = gesture.view else { return }
        let index = view.tag

        if index != selectedIndex {
            selectedIndex = index
            delegate?.tabBar(self, didSelectItemAt: index)

            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
    }

    func updateSelectedItem() {
        for (index, item) in tabBarItems.enumerated() {
            item.isSelectedItem = (index == selectedIndex)
        }
    }
}

final class CustomTabBarItem: UIView {
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 22
        view.clipsToBounds = true
        return view
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = NavTabColor.textSecondary
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.textColor = NavTabColor.textSecondary
        return label
    }()

    var isSelectedItem = false {
        didSet {
            updateAppearance(animated: true)
        }
    }

    private var normalImage: UIImage?
    private var selectedImage: UIImage?
    private var title: String?
    private var selfWidthConstraint: Constraint?

    init(title: String, normalImage: UIImage?, selectedImage: UIImage?) {
        self.title = title
        self.normalImage = normalImage?.withRenderingMode(.alwaysTemplate)
        self.selectedImage = selectedImage?.withRenderingMode(.alwaysTemplate)
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension CustomTabBarItem {
    func setupUI() {
        addSubview(backgroundView)
        backgroundView.addSubview(contentView)
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)

        snp.makeConstraints { make in
            make.height.equalTo(44)
            selfWidthConstraint = make.width.equalTo(44).constraint
        }

        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.greaterThanOrEqualToSuperview()
            make.right.lessThanOrEqualToSuperview()
        }

        iconImageView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(28)
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(iconImageView.snp.right).offset(4)
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        titleLabel.text = title
        titleLabel.alpha = 0
        titleLabel.isHidden = true

        updateAppearance(animated: false)
    }

    func updateAppearance(animated: Bool) {
        iconImageView.image = isSelectedItem ? selectedImage : normalImage

        if isSelectedItem {
            titleLabel.isHidden = false
            titleLabel.text = title

            let titleWidth = (title ?? "").size(withAttributes: [.font: titleLabel.font as Any]).width
            let targetWidth = ceil(28 + 4 + titleWidth + 16 + 4)
            selfWidthConstraint?.update(offset: targetWidth)

            let changes = {
                self.backgroundView.backgroundColor = NavTabColor.primary
                self.iconImageView.tintColor = .white
                self.titleLabel.textColor = .white
                self.titleLabel.alpha = 1
                self.superview?.layoutIfNeeded()
            }

            if animated {
                UIView.animate(
                    withDuration: 0.3,
                    delay: 0,
                    usingSpringWithDamping: 0.8,
                    initialSpringVelocity: 0.5,
                    options: [.curveEaseInOut, .beginFromCurrentState, .allowUserInteraction],
                    animations: changes
                )
            } else {
                changes()
            }
        } else {
            selfWidthConstraint?.update(offset: 44)
            titleLabel.text = ""

            let changes = {
                self.backgroundView.backgroundColor = .clear
                self.iconImageView.tintColor = NavTabColor.textSecondary
                self.titleLabel.textColor = NavTabColor.textSecondary
                self.titleLabel.alpha = 0
                self.superview?.layoutIfNeeded()
            }

            if animated {
                UIView.animate(
                    withDuration: 0.3,
                    delay: 0,
                    usingSpringWithDamping: 0.8,
                    initialSpringVelocity: 0.5,
                    options: [.curveEaseInOut, .beginFromCurrentState, .allowUserInteraction],
                    animations: changes
                ) { finished in
                    if finished && !self.isSelectedItem {
                        self.titleLabel.isHidden = true
                    }
                }
            } else {
                changes()
                titleLabel.isHidden = true
            }
        }
    }
}

