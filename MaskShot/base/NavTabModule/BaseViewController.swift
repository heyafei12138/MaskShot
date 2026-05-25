//
//  BaseViewController.swift
//  SGNavTabModule
//

import UIKit
import SafariServices
import SnapKit

open class BaseViewController: UIViewController {
    open var isCustomNavigationHidden = false
    open var enablesInteractivePopGesture = false
    open var showsRightNavigationActions = false
    open var allowsShowProBadge = true
    open var showsSettingsButton = false
    open var enablesTapToDismissKeyboard = true

    open lazy var navigationHeaderView: CustomNavigationBar = {
        CustomNavigationBar()
    }()

    open lazy var rightActionContainerView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()

    open lazy var settingsButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: NavTabImageName.settings) ?? UIImage(systemName: "gearshape.fill"), for: .normal)
        button.layer.cornerRadius = 18
        button.layer.masksToBounds = true
        return button
    }()

    open override var title: String? {
        didSet {
            guard isCustomNavigationHidden == false else { return }
            navigationHeaderView.setTitle(title)
        }
    }

    open override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        setupPageAppearance()
        if enablesTapToDismissKeyboard {
            enableTapToDismissKeyboard()
        }
        setupCustomNavigationIfNeeded()
        setupSubviews()
        bindViewModel()
        bringNavigationChromeToFrontIfNeeded()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        refreshRightNavigationActionsIfNeeded()
        bringNavigationChromeToFrontIfNeeded()
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateInteractivePopGestureState()
        fixContainerHeightIfNeeded()
    }

    deinit {
        debugPrint("deinit controller >>> \(self)")
    }
}

extension BaseViewController {
    @objc open func setupSubviews() { }
    @objc open func bindViewModel() { }

    @objc open func refreshRightNavigationActionsIfNeeded() {
        guard showsRightNavigationActions else {
            rightActionContainerView.isHidden = true
            return
        }

        rightActionContainerView.isHidden = false
        settingsButton.isHidden = showsSettingsButton == false
    }

    @objc open func onSettingsButtonPressed() { }

    @objc open func onProBadgePressed() {
        print("点击了 Pro Badge")
    }

    @objc open func reloadLeftNavigationButtonIfNeeded() {
        guard navigationHeaderView.leftActionButton.isHidden,
              (navigationController?.viewControllers.count ?? 0) > 1 else {
            return
        }

        navigationHeaderView.showLeftButton(
            image: UIImage(named: NavTabImageName.back) ?? UIImage()
        )
    }

    @objc open func onNavigationBackPressed() {
        popCurrentController()
    }

    @objc open func showLoginPageIfNeeded() { }

    @objc open func openWebPageInSafari(_ url: URL) {
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true)
    }
}

private extension BaseViewController {
    func setupPageAppearance() {
        view.backgroundColor = NavTabColor.background
    }

    func setupCustomNavigationIfNeeded() {
        setupRightNavigationActionsIfNeeded()

        guard isCustomNavigationHidden == false else { return }

        view.addSubview(navigationHeaderView)
        navigationHeaderView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(kNavHeight)
        }

        navigationHeaderView.onLeftAction = { [weak self] in
            self?.onNavigationBackPressed()
        }

        if (navigationController?.viewControllers.count ?? 0) > 1 {
            navigationHeaderView.showLeftButton(
                image: UIImage(named: NavTabImageName.back) ?? UIImage()
            )
        }
    }

    func setupRightNavigationActionsIfNeeded() {
        view.addSubview(rightActionContainerView)
        rightActionContainerView.addSubview(settingsButton)

        rightActionContainerView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(kStatusBarHeight + 5)
            make.height.equalTo(36)
        }

        settingsButton.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.bottom.right.equalToSuperview()
            make.width.height.equalTo(32)
        }

        settingsButton.addTarget(self, action: #selector(onSettingsButtonPressed), for: .touchUpInside)
    }

    func updateInteractivePopGestureState() {
        guard let gesture = navigationController?.interactivePopGestureRecognizer else { return }
        if gesture.isEnabled != enablesInteractivePopGesture {
            gesture.isEnabled = enablesInteractivePopGesture
        }
    }

    func fixContainerHeightIfNeeded() {
        let containerHeight = navigationController?.view.frame.size.height ?? kScreenHeight

        guard containerHeight - kScreenHeight == kStatusBarHeight else { return }

        navigationController?.viewControllers.forEach { vc in
            vc.view.frame.size.height = kScreenHeight
        }
        navigationController?.view.frame.size.height = kScreenHeight

        let rootNav = UIApplication.topViewController() as? UINavigationController
        let rootTab = rootNav?.viewControllers.first as? UITabBarController
        rootTab?.view.frame.size.height = kScreenHeight
    }

    func bringNavigationChromeToFrontIfNeeded() {
        guard isCustomNavigationHidden == false else { return }
        view.bringSubviewToFront(navigationHeaderView)
        if showsRightNavigationActions, !rightActionContainerView.isHidden {
            view.bringSubviewToFront(rightActionContainerView)
        }
    }
}

extension BaseViewController {
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}
