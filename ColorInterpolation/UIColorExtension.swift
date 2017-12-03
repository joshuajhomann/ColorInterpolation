//
//  UIColorExtension.swift
//  ColorInterpolation
//
//  Created by Joshua Homann on 12/3/17.
//  Copyright © 2017 Joshua Homann. All rights reserved.
//

import UIKit

extension UIColor {
  func rgba() -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
    var r = CGFloat(0)
    var g = CGFloat(0)
    var b = CGFloat(0)
    var a = CGFloat(0)
    getRed(&r, green: &g, blue: &b, alpha: &a)
    return (r, g, b, a)
  }
  func mix(with color: UIColor, proportion: CGFloat) -> UIColor {
    let lhs = rgba()
    let rhs = color.rgba()
    let color = UIColor(red: lhs.r.lerp(to: rhs.r, alpha: proportion),
                        green: lhs.g.lerp(to: rhs.g, alpha: proportion),
                        blue: lhs.b.lerp(to: rhs.b, alpha: proportion),
                        alpha: 1)
    return color
  }
}
