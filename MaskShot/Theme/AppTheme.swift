import UIKit

enum AppTheme {
    enum Color {
        static let mainBackground = UIColor(hex: "020617")
        static let secondaryBackground = UIColor(hex: "0F172A")
        static let elevatedSurface = UIColor(hex: "111827")
        static let border = UIColor(hex: "1E293B")
        static let primaryText = UIColor(hex: "F8FAFC")
        static let secondaryText = UIColor(hex: "94A3B8")
        static let disabledText = UIColor(hex: "475569")
        static let primaryAccent = UIColor(hex: "3B82F6")
        static let activeAccent = UIColor(hex: "2563EB")
        static let success = UIColor(hex: "4ADE80")
        static let warning = UIColor(hex: "FBBF24")
        static let danger = UIColor(hex: "F87171")
        static let blackout = UIColor.black
    }

    enum Radius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let sheet: CGFloat = 28
    }

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
    }

    enum Font {
        static let largeTitle = UIFont.systemFont(ofSize: 34, weight: .bold)
        static let title = UIFont.systemFont(ofSize: 28, weight: .bold)
        static let headline = UIFont.systemFont(ofSize: 18, weight: .semibold)
        static let body = UIFont.systemFont(ofSize: 15, weight: .regular)
        static let label = UIFont.systemFont(ofSize: 13, weight: .semibold)
        static let caption = UIFont.systemFont(ofSize: 12, weight: .medium)
    }
}

