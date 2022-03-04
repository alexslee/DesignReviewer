//
//  UIEdgeInsets+Convenience.swift
//  
//
//  Created by Alex Lee on 3/3/22.
//

import UIKit

extension UIEdgeInsets {
  /// Convenience initializer that applies the same inset value to each edge
  init(inset: CGFloat) {
    self.init(top: inset, left: inset, bottom: inset, right: inset)
  }
}
