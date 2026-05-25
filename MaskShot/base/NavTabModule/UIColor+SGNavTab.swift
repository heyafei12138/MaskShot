//
//  UIColor+SGNavTab.swift
//  SGNavTabModule
//

import UIKit

public extension UIColor {
    static func hexString(_ color: String, alpha: CGFloat = 1) -> UIColor {
        colorString(color, alpha: alpha)
    }

    static func RGBHexNum(_ num: CGFloat, alpha: CGFloat) -> UIColor {
        let red = num / (256.0 * 256.0)
        let green = (num.truncatingRemainder(dividingBy: (256.0 * 256.0))) / 256.0
        let blue = num.truncatingRemainder(dividingBy: 256.0)
        return UIColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: alpha)
    }

    static func randomColor() -> UIColor {
        UIColor(
            red: CGFloat(arc4random_uniform(256)) / 255.0,
            green: CGFloat(arc4random_uniform(256)) / 255.0,
            blue: CGFloat(arc4random_uniform(256)) / 255.0,
            alpha: 1
        )
    }

    static func colorString(_ colorStr: String, alpha: CGFloat = 1) -> UIColor {
        var color = UIColor.clear
        var cStr = colorStr.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cStr.hasPrefix("#") {
            cStr = String(cStr.dropFirst())
        }

        if cStr.hasPrefix("0X") {
            cStr = String(cStr.dropFirst(2))
        }

        guard cStr.count == 6 else {
            return UIColor.clear
        }

        let scanner = Scanner(string: cStr)
        var value: UInt64 = 0
        guard scanner.scanHexInt64(&value) else {
            return UIColor.clear
        }

        let red = CGFloat((value & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((value & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(value & 0x0000FF) / 255.0

        color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return color
    }

    static func RGB(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1) -> UIColor {
        UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a)
    }

    static func inthexColor(_ hexColor: Int64) -> UIColor {
        let red = CGFloat((hexColor & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hexColor & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(hexColor & 0x0000FF) / 255.0
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }

    static func RANDCOLOR() -> UIColor {
        RGB(
            CGFloat(arc4random_uniform(255)),
            CGFloat(arc4random_uniform(255)),
            CGFloat(arc4random_uniform(255))
        )
    }
}

