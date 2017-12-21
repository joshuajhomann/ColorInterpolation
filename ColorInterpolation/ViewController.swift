//
//  ViewController.swift
//  ColorInterpolation
//
//  Created by Joshua Homann on 12/3/17.
//  Copyright © 2017 Joshua Homann. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  // MARK: - Variables
  private var lineView = LineView()
  private var points: [ColorPoint] = []
  private var colorIndex = 0
  private var deltaColor: CGFloat = 0
  private var timer = Timer()

  // MARK: - Constants
  private let repeatLength: CGFloat = 1000
  private let minimumStrokeWidth: CGFloat = 10
  private let maximumStrokeWidth: CGFloat = 100
  private let colors: [UIColor] = [.cyan, .blue, .purple, .magenta, .red, .orange, .yellow, .green]

  // MARK: - UIViewController
  override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(lineView)
    lineView.backgroundColor = .clear
    lineView.translatesAutoresizingMaskIntoConstraints = false
    let attributes: [NSLayoutAttribute] = [.top, .bottom, .leading, .trailing]
    NSLayoutConstraint.activate(attributes.map {
      NSLayoutConstraint(item: lineView, attribute: $0, relatedBy: .equal, toItem: self.view, attribute: $0, multiplier: 1, constant: 0)
    })
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    timer.invalidate()
    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
      self.points = self.points.filter { $0.created.timeIntervalSinceNow > -10 }
      self.lineView.points = self.points
    }
  }

  override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
    guard motion == .motionShake else {
      return
    }
    UIView.animate(withDuration: 0.25, animations: {
      self.view.alpha = 0
    }, completion: { _ in
      self.view.layer.contents = nil
      self.view.alpha = 1
      if let last = self.points.last {
        self.points = [last]
      }
    })
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let location = touches.first?.location(in: view) else {
      return
    }
    points.append(ColorPoint(coordinate: location))
  }

  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first,
          let previousPoint = points.last?.coordinate else {
      return
    }
    let strokeWidth: CGFloat
    if view.traitCollection.forceTouchCapability == .available {
      strokeWidth = minimumStrokeWidth.lerp(to: maximumStrokeWidth, alpha: touch.force / touch.maximumPossibleForce)
    } else {
      strokeWidth = minimumStrokeWidth * 2
    }
    let point = touch.location(in: view)
    let distance = hypot(point.x - previousPoint.x, point.y - previousPoint.y)
    deltaColor = CGFloat(fmod(Double(deltaColor + distance), Double(repeatLength)))
    points.append(ColorPoint(coordinate: point,
                             color: colorFor(proportion: deltaColor / repeatLength),
                             strokeWidth: strokeWidth))
    lineView.points = points
  }

  // MARK: Instance Methods
  private func colorFor(proportion: CGFloat) -> UIColor {
    let count = CGFloat(colors.count)
    let lowerIndex = Int(proportion * count)
    let upperIndex = (lowerIndex + 1) % colors.count
    let remainder = proportion * count - CGFloat(lowerIndex)
    return colors[lowerIndex].mix(with: colors[upperIndex], proportion: remainder)
  }

}


