//
//  ViewController.swift
//  ColorInterpolation
//
//  Created by Joshua Homann on 12/3/17.
//  Copyright © 2017 Joshua Homann. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  var imageRenderer: UIGraphicsImageRenderer!
  var previousPoint: CGPoint = .zero
  var colorIndex = 0
  var deltaColor: CGFloat = 0
  let repeatLength: CGFloat = 250
  let colors: [UIColor] = [.cyan, .blue, .purple, .magenta, .red, .orange, .yellow]

  override func viewDidLoad() {
    super.viewDidLoad()
    let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
    recognizer.minimumPressDuration = 0
    view.addGestureRecognizer(recognizer)
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    imageRenderer = UIGraphicsImageRenderer(bounds: view.bounds)
  }

  func colorFor(proportion: CGFloat) -> UIColor {
    let count = CGFloat(colors.count)
    let lowerIndex = Int(proportion * count)
    let upperIndex = (lowerIndex + 1) % colors.count
    let remainder = proportion * count - CGFloat(lowerIndex)
    return colors[lowerIndex].mix(with: colors[upperIndex], proportion: remainder)
  }

  @objc func longPress(_ recognizer: UILongPressGestureRecognizer) {
    switch recognizer.state {
    case .began:
      previousPoint = recognizer.location(in: self.view)
    case .changed:
      let point = recognizer.location(in: self.view)
      let distance = hypot(point.x - previousPoint.x, point.y - previousPoint.y)
      deltaColor = CGFloat(fmod(Double(deltaColor + distance), Double(repeatLength)))
      let color = colorFor(proportion: deltaColor / repeatLength)
      let image = imageRenderer.image { imageContext in
        let context = imageContext.cgContext
        self.view.layer.render(in: context)
        color.setStroke()
        let path = CGMutablePath()
        path.move(to: previousPoint)
        path.addLine(to: point)
        context.addPath(path)
        context.setLineWidth(20)
        context.setLineCap(.round)
        context.strokePath()
        self.previousPoint = point
      }
      view.layer.contents = image.cgImage
    default:
      return
    }

  }

}
