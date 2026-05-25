//
//  UIViewController+SGNavTab.swift
//  SGNavTabModule
//

import UIKit
import ObjectiveC

private var keyboardDismissTapKey: UInt8 = 0

public extension UIViewController {
    func presentController(fromStoryboard storyboardName: String) {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        guard let target = storyboard.instantiateInitialViewController() else { return }
        presentController(target)
    }

    func presentController(_ target: UIViewController) {
        if #available(iOS 13.0, *) {
            target.modalPresentationStyle = .fullScreen
        }
        present(target, animated: true)
    }

    func pushController(fromStoryboard storyboardName: String) {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        guard let target = storyboard.instantiateInitialViewController() else { return }
        pushController(target)
    }

    func pushController(_ target: UIViewController) {
        if let nav = self as? UINavigationController {
            nav.pushViewController(target, animated: true)
            return
        }

        target.hidesBottomBarWhenPushed = false
        navigationController?.pushSafely(target, animated: true)
    }

    func pushController(_ target: UIViewController, animated: Bool = true) {
        if let nav = self as? UINavigationController {
            nav.pushViewController(target, animated: animated)
            return
        }

        target.hidesBottomBarWhenPushed = false
        navigationController?.pushViewController(target, animated: animated)
    }

    func popCurrentController(_ animated: Bool = true) {
        if let nav = self as? UINavigationController {
            nav.popViewController(animated: animated)
        } else {
            navigationController?.popViewController(animated: animated)
        }
    }

    func popToRootController() {
        if let nav = self as? UINavigationController {
            nav.popToRootViewController(animated: true)
        } else {
            navigationController?.popToRootViewController(animated: true)
        }
    }

    func popBack(to controller: UIViewController) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            if let nav = self as? UINavigationController {
                nav.popToViewController(controller, animated: true)
            } else {
                self.navigationController?.popToViewController(controller, animated: true)
            }
        }
    }

    func searchFirstResponder(in containerView: UIView) -> UIView? {
        if containerView.isFirstResponder {
            return containerView
        }

        for child in containerView.subviews {
            if let responder = searchFirstResponder(in: child) {
                return responder
            }
        }
        return nil
    }

    func enableTapToDismissKeyboard() {
        guard objc_getAssociatedObject(self, &keyboardDismissTapKey) as? UITapGestureRecognizer == nil else {
            return
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(sg_handleTapToDismissKeyboard))
        tap.cancelsTouchesInView = false
        tap.delaysTouchesBegan = false
        tap.delaysTouchesEnded = false
        view.addGestureRecognizer(tap)
        objc_setAssociatedObject(self, &keyboardDismissTapKey, tap, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

private extension UIViewController {
    @objc func sg_handleTapToDismissKeyboard() {
        view.endEditing(true)
    }
}

public extension UINavigationController {
    func pushSafely(_ controller: UIViewController, animated: Bool) {
        if let currentTop = topViewController, currentTop == controller {
            return
        }
        pushViewController(controller, animated: animated)
    }
}

