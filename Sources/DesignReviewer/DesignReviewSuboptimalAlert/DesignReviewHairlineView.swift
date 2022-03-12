//
//  DesignReviewHairlineView.swift
//  
//
//  Created by Alex Lee on 3/12/22.
//

import Foundation
import UIKit

class DesignReviewHairlineView: UIView {
  convenience init() {
    self.init(withDirection: .horizontal)
  }

  convenience init(withDirection direction: NSLayoutConstraint.Axis) {
    self.init(frame: .zero)

    translatesAutoresizingMaskIntoConstraints = false

    backgroundColor = .monochrome2

    switch direction {
    case .horizontal:
      heightAnchor.constraint(equalToConstant: 1.0 / UIScreen.main.scale).isActive = true
    case .vertical:
      widthAnchor.constraint(equalToConstant: 1.0 / UIScreen.main.scale).isActive = true
    @unknown default:
      fatalError()
    }
  }
}
