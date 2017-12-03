//
//  CGFloatExtension.swift
//  ColorInterpolation
//
//  Created by Joshua Homann on 12/3/17.
//  Copyright © 2017 Joshua Homann. All rights reserved.
//
import UIKit

extension CGFloat {
  func lerp(to: CGFloat, alpha: CGFloat) -> CGFloat {
    return (1 - alpha) * self + alpha * to
  }
}
