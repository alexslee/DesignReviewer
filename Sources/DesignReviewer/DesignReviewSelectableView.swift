//
//  DesignReviewSelectableView.swift
//
//
//  Created by Alex Lee on 3/3/22.
//

import Foundation
import UIKit

class DesignReviewSelectableView: UIView {
  enum SelectableStyle {
    case solid, dashed
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private let borderColor: UIColor
  private let borderWidth: CGFloat
  private var existingStroke: UIBezierPath?
  private let selectableStyle: SelectableStyle

  init(borderColor: UIColor = .white,
       borderWidth: CGFloat = .extraExtraSmall,
       selectableStyle: SelectableStyle = .solid) {
    self.borderColor = borderColor
    self.borderWidth = borderWidth
    self.selectableStyle = selectableStyle

    super.init(frame: .zero)

    backgroundColor = .clear

    layer.borderColor = borderColor.cgColor
    layer.borderWidth = borderWidth
  }
}
