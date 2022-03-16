//
//  UIView+ReviewableDescribing.swift
//  
//
//  Created by Alex Lee on 3/3/22.
//

import UIKit

extension UIView.ContentMode: ReviewableDescribing {
  public static var allCases: [UIView.ContentMode] = {
    return [.left, .right, .top, .bottom, .bottomLeft, .bottomRight, .center, .topLeft, .topRight,
            .redraw, .scaleAspectFill, .scaleToFill, .scaleAspectFit]
  }()

  public var displayName: String {
    switch self {
    case .left:
      return "Left"
    case .right:
      return "Right"
    case .top:
      return "Top"
    case .bottom:
      return "Bottom"
    case .bottomLeft:
      return "BottomLeft"
    case .bottomRight:
      return "BottomRight"
    case .center:
      return "Center"
    case .topLeft:
      return "Top Left"
    case .topRight:
      return "Top Right"
    case .redraw:
      return "Redraw"
    case .scaleAspectFill:
      return "Scale Aspect Fill"
    case .scaleToFill:
      return "Scale to Fill"
    case .scaleAspectFit:
      return "Scale Aspect Fit"
    @unknown default:
      return "Unknown"
    }
  }
}

extension UIView.TintAdjustmentMode: ReviewableDescribing {
  public static var allCases: [UIView.TintAdjustmentMode] = {
    return [.automatic, .normal, .dimmed]
  }()

  public var displayName: String {
    switch self {
    case .automatic:
      return "Automatic"
    case .dimmed:
      return "Dimmed"
    case .normal:
      return "Normal"
    @unknown default:
      return "Unknown"
    }
  }
}
