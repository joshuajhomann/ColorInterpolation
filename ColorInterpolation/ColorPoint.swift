//
//  ColorPoint.swift
//  ColorInterpolation
//
//  Created by Joshua Homann on 12/18/17.
//  Copyright © 2017 Joshua Homann. All rights reserved.
//

import UIKit

struct ColorPoint {
  let coordinate: CGPoint
  var color: UIColor
  let strokeWidth: CGFloat
  let created = Date()
}

extension ColorPoint {
  init(coordinate: CGPoint) {
    self.coordinate = coordinate
    color = .clear
    strokeWidth = 1
  }
}
