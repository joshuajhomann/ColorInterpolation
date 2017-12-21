//
//  LineLayer.swift
//  ColorInterpolation
//
//  Created by Joshua Homann on 12/18/17.
//  Copyright © 2017 Joshua Homann. All rights reserved.
//

import UIKit

class LineView: UIView {
  lazy var displayLink = CADisplayLink(target: self, selector: #selector(update))
  var points: [ColorPoint] = []
  override func willMove(toSuperview newSuperview: UIView?) {
    super.willMove(toSuperview: newSuperview)
    switch newSuperview {
    case .some(_):
      displayLink.add(to: .current, forMode: .defaultRunLoopMode)
    case .none:
      displayLink.remove(from: .current, forMode: .defaultRunLoopMode)
    }
  }
  override func draw(_ rect: CGRect) {
    guard var origin = points.first?.coordinate else {
      return
    }
    for point in points.dropFirst() {
      let path = UIBezierPath()
      path.move(to: origin)
      path.addLine(to: point.coordinate)
      path.lineWidth = point.strokeWidth
      path.lineCapStyle = .round
      let alpha = CGFloat(max(point.created.timeIntervalSinceNow + 10, 0) / 10)
      point.color.withAlphaComponent(alpha).setStroke()
      path.stroke()
      origin = point.coordinate
    }
  }
  @objc private func update() {
    setNeedsDisplay()
  }
}
