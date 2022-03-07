//
//  DesignReviewUIColorAccessoryView.swift
//  
//
//  Created by Alex Lee on 3/3/22.
//

import UIKit

class DesignReviewUIColorAccessoryView: UIView {
  private static let horizontalMargin: CGFloat = .extraSmall
  private static let size = CGSize(width: .large, height: .large)

  private let color: UIColor?

  override var intrinsicContentSize: CGSize {
    CGSize(width: Self.size.width + Self.horizontalMargin, height: Self.size.height)
  }

  init(color: UIColor?) {
    self.color = color
    super.init(frame: CGRect(x: 0, y: 0, width: Self.size.width, height: Self.size.height))
    accessibilityIgnoresInvertColors = true
    backgroundColor = color
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    layer.cornerRadius = Self.size.height / 2
    layer.borderWidth = 1
    layer.borderColor = UIColor.monochrome2.cgColor
  }
}
