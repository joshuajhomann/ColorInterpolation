//
//  LineLayer.swift
//  ColorInterpolation
//
//  Created by Joshua Homann on 12/18/17.
//  Copyright © 2017 Joshua Homann. All rights reserved.
//

import UIKit

class LineView: UIView {
  // MARK: - Variables
  private lazy var displayLink = CADisplayLink(target: self, selector: #selector(update))
  private var points: [ColorPoint] = []
  private var colorIndex = 0
  private var deltaColor: CGFloat = 0
  private var timer = Timer()
  
  // MARK: - Constants
  private let repeatLength: CGFloat = 1000
  private let minimumStrokeWidth: CGFloat = 10
  private let maximumStrokeWidth: CGFloat = 100
  private let colors: [UIColor] = [.cyan, .blue, .purple, .magenta, .red, .orange, .yellow, .green]

  override func willMove(toSuperview newSuperview: UIView?) {
    super.willMove(toSuperview: newSuperview)
    timer.invalidate()
    switch newSuperview {
    case .some(_):
      displayLink.add(to: .current, forMode: .defaultRunLoopMode)
      timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
        self.points = self.points.filter { $0.created.timeIntervalSinceNow > -10 }
      }
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
      if point.color == .clear {
        UIColor.clear.setStroke()
      } else {
        point.color.withAlphaComponent(alpha).setStroke()
      }
      path.stroke()
      origin = point.coordinate
    }
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let location = touches.first?.location(in: self) else {
      return
    }
    points.append(ColorPoint(coordinate: location))
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else {
        return
    }
    if let coalesced = event?.coalescedTouches(for: touch) {
      coalesced.forEach { self.add(touch: $0) }
    } else {
      add(touch: touch)
    }
  }
  
  override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
    guard motion == .motionShake else {
      return
    }
    UIView.animate(withDuration: 0.25, animations: {
      self.alpha = 0
    }, completion: { _ in
      self.layer.contents = nil
      self.alpha = 1
      if let last = self.points.last {
        self.points = [last]
      }
    })
  }
  
  // MARK: Instance Methods
  private func add(touch: UITouch) {
    guard let previousPoint = points.last?.coordinate else {
      return
    }
    let strokeWidth: CGFloat
    if touch.force > 0 {
      strokeWidth = minimumStrokeWidth.lerp(to: maximumStrokeWidth, alpha: touch.force / touch.maximumPossibleForce)
    } else {
      strokeWidth = minimumStrokeWidth * 2
    }
    let point = touch.location(in: self)
    let distance = hypot(point.x - previousPoint.x, point.y - previousPoint.y)
    deltaColor = CGFloat(fmod(Double(deltaColor + distance), Double(repeatLength)))
    points.append(ColorPoint(coordinate: point,
                             color: colorFor(proportion: deltaColor / repeatLength),
                             strokeWidth: strokeWidth))
  }

  private func colorFor(proportion: CGFloat) -> UIColor {
    let count = CGFloat(colors.count)
    let lowerIndex = Int(proportion * count)
    let upperIndex = (lowerIndex + 1) % colors.count
    let remainder = proportion * count - CGFloat(lowerIndex)
    return colors[lowerIndex].mix(with: colors[upperIndex], proportion: remainder)
  }
  
  @objc private func update() {
    setNeedsDisplay()
  }
}
