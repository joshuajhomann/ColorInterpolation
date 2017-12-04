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
  private lazy var imageRenderer: UIGraphicsImageRenderer = {
    return UIGraphicsImageRenderer(bounds: view.bounds)
  }()
  private var previousPoint: CGPoint = .zero
  private var colorIndex = 0
  private var deltaColor: CGFloat = 0

  // MARK: - Constants
  private let repeatLength: CGFloat = 1000
  private let minimumStrokeWidth: CGFloat = 10
  private let maximumStrokeWidth: CGFloat = 100
  private let colors: [UIColor] = [.cyan, .blue, .purple, .magenta, .red, .orange, .yellow]

  // MARK: - UIViewController

  override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
    guard motion == .motionShake else {
      return
    }
    UIView.animate(withDuration: 0.25, animations: {
      self.view.alpha = 0
    }, completion: { _ in
      self.view.layer.contents = nil
      self.view.alpha = 1
    })

  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let location = touches.first?.location(in: view) else {
      return
    }
    previousPoint = location
  }

  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else {
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
    let color = colorFor(proportion: deltaColor / repeatLength)
    let image = imageRenderer.image { imageContext in
      let context = imageContext.cgContext
      self.view.layer.render(in: context)
      let path = CGMutablePath()
      path.move(to: previousPoint)
      path.addLine(to: point)
      context.addPath(path)
      context.setLineWidth(strokeWidth)
      context.setLineCap(.round)
      color.setStroke()
      context.strokePath()
    }
    view.layer.contents = image.cgImage
    previousPoint = point
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


