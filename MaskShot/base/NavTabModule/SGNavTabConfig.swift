//
//  SGNavTabConfig.swift
//  SGNavTabModule
//
//  Drop this folder into an UIKit project that already has SnapKit.
//

import UIKit
import SnapKit

// MARK: - Screen Metrics

public var kScreenWidth: CGFloat {
    UIScreen.main.bounds.width
}

public var kScreenHeight: CGFloat {
    UIScreen.main.bounds.height
}

public var kStatusBarHeight: CGFloat {
    if #available(iOS 13.0, *) {
        let scenes = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }

        let foregroundScene = scenes.first { $0.activationState == .foregroundActive }
        let scene = foregroundScene ?? scenes.first

        if let height = scene?.statusBarManager?.statusBarFrame.height, height > 0 {
            return height
        }
    }

    return UIApplication.shared.activeWindow?.safeAreaInsets.top ?? 0
}

public var kNavHeight: CGFloat {
    44 + kStatusBarHeight
}

public var ksafebottom: CGFloat {
    UIApplication.shared.activeWindow?.safeAreaInsets.bottom ?? 0
}

// MARK: - Resource Names

public enum NavTabImageName {
    /// Replace this with the back icon name in the host project.
    public static var back = "back_black"

    /// Replace this with the settings icon name in the host project.
    public static var settings = "setting_icon"
}

// MARK: - Color Tokens

public enum NavTabColor {
    public static var primaryHex = "#8AA86B"
    public static var primaryDarkHex = "#5F7D46"
    public static var primaryLightHex = "#DDE8D2"
    public static var backgroundHex = "#F7F5EA"
    public static var textDarkHex = "#31412B"
    public static var separatorHex = "#DDDDDD"

    public static var primary: UIColor {
        .hexString(primaryHex)
    }

    public static var primaryDark: UIColor {
        .hexString(primaryDarkHex)
    }

    public static var primaryLight: UIColor {
        .hexString(primaryLightHex)
    }

    public static var background: UIColor {
        .hexString(backgroundHex)
    }

    public static var textDark: UIColor {
        .hexString(textDarkHex)
    }

    public static var textSecondary: UIColor {
        textDark.withAlphaComponent(0.65)
    }

    public static var textTertiary: UIColor {
        textDark.withAlphaComponent(0.4)
    }

    public static var separator: UIColor {
        .hexString(separatorHex)
    }

    public static var tabBarTint: UIColor {
        UIColor.black.withAlphaComponent(0.08)
    }
}
