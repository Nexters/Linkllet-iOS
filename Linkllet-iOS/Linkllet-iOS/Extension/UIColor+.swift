//
//  UIColor+.swift
//  Linkllet-iOS
//
//  Created by 최동규 on 2023/07/17.
//

import UIKit

extension UIColor {

    convenience init(_ hexString: String) {
        var cString:String = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            self.init(white: 0, alpha: 1)
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    @nonobjc class var blue_01: UIColor {
        return .init("#DAE3FB")
    }
    
    @nonobjc class var blue_02: UIColor {
        return .init("#779CFF")
    }
    
    @nonobjc class var blue_03: UIColor {
        return .init("#4F7EFE")
    }
    
    @nonobjc class var blue_04: UIColor {
        return .init("#3467F0")
    }
    
    @nonobjc class var red: UIColor {
        return .init("#F34A3F")
    }
    
    @nonobjc class var gray_01: UIColor {
        return .init("#F4F4F4")
    }
    
    @nonobjc class var gray_02: UIColor {
        return .init("#EDEDED")
    }
    
    @nonobjc class var gray_03: UIColor {
        return .init("#BCBCBC")
    }
    
    @nonobjc class var gray_04: UIColor {
        return .init("#878787")
    }
}
