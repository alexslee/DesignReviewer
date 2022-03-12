//
//  NSLayoutConstraint+ReviewableDescribing.swift
//  
//
//  Created by Alex Lee on 3/3/22.
//

import UIKit

extension NSLayoutConstraint.Attribute: ReviewableDescribing, CaseIterable {
  public static var allCases: [NSLayoutConstraint.Attribute] = {
    return [.bottom, .bottomMargin, .centerX, .centerXWithinMargins, .centerY, .centerYWithinMargins,
            .firstBaseline, .height, .lastBaseline, .leading, .leadingMargin, .left, .leftMargin, .notAnAttribute,
            .right, .rightMargin, .top, .topMargin, .trailing, .trailingMargin, .width]
  }()

  public var displayName: String {
    switch self {
    case .bottom:
      return "Bottom"
    case .bottomMargin:
      return "Bottom Margin"
    case .centerX:
      return "Center X"
    case .centerXWithinMargins:
      return "Center X Within Margins"
    case .centerY:
      return "Center Y"
    case .centerYWithinMargins:
      return "Center Y Within Margins"
    case .firstBaseline:
      return "First Baseline"
    case .height:
      return "Height"
    case .lastBaseline:
      return "Last Baseline"
    case .leading:
      return "Leading"
    case .leadingMargin:
      return "Leading Margin"
    case .left:
      return "Left"
    case .leftMargin:
      return "Left Margin"
    case .notAnAttribute:
      return "Not An Attribute"
    case .right:
      return "Right"
    case .rightMargin:
      return "Right Margin"
    case .top:
      return "Top"
    case .topMargin:
      return "Top Margin"
    case .trailing:
      return "Trailing"
    case .trailingMargin:
      return "Trailing Margin"
    case .width:
      return "Width"
    @unknown default:
      return "Unknown"
    }
  }
}

extension NSLayoutConstraint.Axis: ReviewableDescribing, CaseIterable {
  public static var allCases: [NSLayoutConstraint.Axis] = {
    return [.horizontal, .vertical]
  }()

  public var displayName: String {
    switch self {
    case .horizontal:
      return "Horizontal"
    case .vertical:
      return "Vertical"
    @unknown default:
      return "Unknown"
    }
  }
}

extension NSLayoutConstraint.Relation: ReviewableDescribing, CaseIterable {
  public static var allCases: [NSLayoutConstraint.Relation] = {
    return []
  }()

  public var displayName: String {
    switch self {
    case .equal:
      return "="
    case .greaterThanOrEqual:
      return ">="
    case .lessThanOrEqual:
      return "<="
    @unknown default:
      return "Unknown"
    }
  }
}
