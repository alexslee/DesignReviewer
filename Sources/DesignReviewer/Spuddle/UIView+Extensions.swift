//
//  UIView+Extensions.swift
//  
//
//  Created by Alexander Lee on 2022-08-15.
//

import Foundation
import UIKit

extension UIView {
  var fakeWindowView: SpuddleFakeWindowView? {
    if let view = self as? SpuddleFakeWindowView {
      return view
    } else {
      for subview in subviews {
        if let fakeView = subview.fakeWindowView { return fakeView }
      }

      return nil
    }
  }

  /// Express view's frame in global coordinate space
  func windowFrame() -> CGRect {
    return convert(bounds, to: nil)
  }
}

extension Optional where Wrapped: UIView {
  func windowFrame() -> CGRect {
    if let view = self { return view.windowFrame() }
    return .zero
  }
}
