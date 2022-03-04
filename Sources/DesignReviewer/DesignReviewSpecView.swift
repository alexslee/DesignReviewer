//
//  DesignReviewSpecView.swift
//
//
//  Created by Alex Lee on 3/3/22.
//

import Foundation
import UIKit

class DesignReviewSpecView: UIVisualEffectView {
  private lazy var label: UILabel = {
    let label = UILabel()

    label.font = .callOut
    label.lineBreakMode = .byWordWrapping
    label.numberOfLines = 0
    label.textAlignment = .center
    label.textColor = .monochrome5
    label.translatesAutoresizingMaskIntoConstraints = false

    label.setContentCompressionResistancePriority(.required, for: .horizontal)
    label.setContentCompressionResistancePriority(.required, for: .vertical)
    label.setContentHuggingPriority(.required, for: .horizontal)
    label.setContentHuggingPriority(.required, for: .vertical)

    return label
  }()

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init() {
    super.init(effect: UIBlurEffect(style: .light))

    layer.cornerRadius = .extraExtraSmall
    layer.masksToBounds = true
    layer.zPosition = 666

    contentView.addSubview(label)

    NSLayoutConstraint.activate(label.constraints(toView: contentView, withEqualInset: .extraExtraSmall))
  }

  func updateSpec(_ spec: CGFloat) {
    label.text = spec.toString()
    label.sizeToFit()
  }
}
