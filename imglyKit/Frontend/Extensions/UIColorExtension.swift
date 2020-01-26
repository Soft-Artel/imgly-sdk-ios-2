//
//  UIColorExtension.swift
//  imglyKit iOS
//
//  Created by Мурат Камалов on 26.01.2020.
//  Copyright © 2020 9elements GmbH. All rights reserved.
//

import UIKit

extension UIColor {

    convenience init(red: Int, green:Int, blue:Int, alpha:CGFloat = 1 ) {
        self.init(red:   CGFloat( red )   / 255,
                  green: CGFloat( green ) / 255,
                  blue:  CGFloat( blue )  / 255,
                  alpha: alpha )
    }

    convenience init(hex: String) {
        var value = hex.replacingOccurrences(of: "#", with: "")

        var alpha: CGFloat = 1.0
        var rgbValue: UInt32 = 0
        if hex.count > 7 && hex != "#NNNNNN00" {
            alpha = CGFloat(Float(hex.suffix(2)) ?? 100) / 100
            value = String(value.dropLast(2))
        }
        let scanner = Scanner(string: value)
        scanner.scanHexInt32(&rgbValue)

        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16)/255,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8)/255,
                  blue: CGFloat(rgbValue & 0x0000FF)/255,
                  alpha: alpha)
    }

    var hexString: String {
        let colorRef = cgColor.components
        let r = colorRef?[0] ?? 0
        let g = colorRef?[1] ?? 0
        let b = ((colorRef?.count ?? 0) > 2 ? colorRef?[2] : g) ?? 0
        let a = cgColor.alpha

        var color = String(
            format: "#%02lX%02lX%02lX",
            lroundf(Float(r * 255)),
            lroundf(Float(g * 255)),
            lroundf(Float(b * 255))
        )

        if a != 1 {
            color += String(Int(a * 100))
        }

        return color
    }
}
