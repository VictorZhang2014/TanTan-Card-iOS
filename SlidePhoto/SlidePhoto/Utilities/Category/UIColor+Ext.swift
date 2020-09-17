//
//  Ext.swift
//  SlidePhoto
//
//  Created by VictorZhang on 2020/9/5.
//  Copyright © 2020 VictorZhang. All rights reserved.
//

import UIKit

extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
    
    public static var mainGrayColor: UIColor {
        get {
            return UIColor(red: 249.0/255.0, green: 249.0/255.0, blue: 249.0/255.0, alpha: 1) // 浅灰色
        }
    }
    
    public static var Gray1Color: UIColor {
        get {
            return UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1) // 浅灰色1
        }
    }
    
    public static var Gray2Color: UIColor {
        get {
            return UIColor(red: 228/255.0, green: 228/255.0, blue: 228/255.0, alpha: 1) // 浅灰色2
        }
    }

}
