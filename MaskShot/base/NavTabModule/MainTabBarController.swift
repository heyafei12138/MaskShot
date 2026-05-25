//
//  MainTabBarController.swift
//  SGNavTabModule
//

import UIKit
import SnapKit

public struct SGMainTabItem {
    public let title: String
    public let systemImage: String
    public let selectedSystemImage: String
    public let makeViewController: () -> UIViewController

    public init(
        title: String,
        systemImage: String,
        selectedSystemImage: String,
        makeViewController: @escaping () -> UIViewController
    ) {
        self.title = title
        self.systemImage = systemImage
        self.selectedSystemImage = selectedSystemImage
        self.makeViewController = makeViewController
    }

    var tabBarConfig: SGTabBarItemConfig {
        SGTabBarItemConfig(
            title: title,
            systemImage: systemImage,
            selectedSystemImage: selectedSystemImage
        )
    }
}

open class MainTabBarController: UITabBarController {
    public let customTabBar = CustomTabBar()
    public private(set) var tabItems: [SGMainTabItem] = []

    private var hasCheckedInfoDeclaration = false

    public convenience init(tabItems: [SGMainTabItem]) {
        self.init(nibName: nil, bundle: nil)
        self.tabItems = tabItems
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        setupCustomTabBar()
        setupAppearance()
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentInfoDeclarationIfNeeded()
    }

    open func makeNavigationController(for rootViewController: UIViewController) -> UINavigationController {
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.delegate = self
        rootViewController.title = ""
        return navController
    }

    open func setSelectedIndex(_ index: Int) {
        let safeIndex = max(0, min(index, (viewControllers?.count ?? 1) - 1))
        selectedIndex = safeIndex
        customTabBar.selectedIndex = safeIndex
    }

    open func presentInfoDeclarationIfNeeded() {
        guard hasCheckedInfoDeclaration == false else { return }

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            guard self.presentedViewController == nil else { return }
            self.hasCheckedInfoDeclaration = true
        }
    }

    public static func getCurrentNavigationController() -> UINavigationController? {
        guard let rootViewController = UIApplication.shared.activeWindow?.rootViewController else {
            return nil
        }

        if let tabBarController = rootViewController as? MainTabBarController,
           let selectedViewController = tabBarController.selectedViewController as? UINavigationController {
            return selectedViewController
        }

        if let navigationController = rootViewController as? UINavigationController {
            return navigationController
        }

        if let navigationController = rootViewController.navigationController {
            return navigationController
        }

        return nil
    }
}

private extension MainTabBarController {
    func setupAppearance() {
        tabBar.isUserInteractionEnabled = false
        tabBar.isHidden = true
        view.bringSubviewToFront(customTabBar)
    }

    func setupViewControllers() {
        viewControllers = tabItems.map { item in
            makeNavigationController(for: item.makeViewController())
        }
    }

    func setupCustomTabBar() {
        view.addSubview(customTabBar)
        customTabBar.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.height.equalTo(CustomTabBar.barHeight)
        }

        customTabBar.configureItems(tabItems.map(\.tabBarConfig))
        customTabBar.delegate = self
        customTabBar.selectedIndex = 0
    }
}

extension MainTabBarController: CustomTabBarDelegate {
    public func tabBar(_ tabBar: CustomTabBar, didSelectItemAt index: Int) {
        selectedIndex = index
    }
}

extension MainTabBarController: UINavigationControllerDelegate {
    public func navigationController(
        _ navigationController: UINavigationController,
        willShow viewController: UIViewController,
        animated: Bool
    ) {
        let hideTab = navigationController.viewControllers.count > 1
        customTabBar.isHidden = hideTab
    }
}

