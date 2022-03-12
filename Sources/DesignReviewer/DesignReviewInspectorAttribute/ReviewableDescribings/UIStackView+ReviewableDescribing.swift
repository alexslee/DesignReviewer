//
//  UIStackView+ReviewableDescribing.swift
//  
//
//  Created by Alex Lee on 3/3/22.
//

import UIKit

extension UIStackView.Alignment: ReviewableDescribing, CaseIterable {
  public static var allCases: [UIStackView.Alignment] = {
    return [.bottom, .center, .fill, .firstBaseline, .lastBaseline, .leading, .top, .trailing]
  }()

  public var displayName: String {
    switch self {
    case .bottom:
      return "Bottom"
    case .center:
      return "Center"
    case .fill:
      return "Fill"
    case .firstBaseline:
      return "First Baseline"
    case .lastBaseline:
      return "Last Baseline"
    case .leading:
      return "Leading"
    case .top:
      return "Top"
    case .trailing:
      return "Trailing"
    @unknown default:
      return "Unknown"
    }
  }
}

extension UIStackView.Distribution: ReviewableDescribing, CaseIterable {
  public static var allCases: [UIStackView.Distribution] = {
    return [.equalCentering, .equalSpacing, .fill, .fillEqually, .fillProportionally]
  }()

  public var displayName: String {
    switch self {
    case .equalCentering:
      return "Equal Centering"
    case .equalSpacing:
      return "Equal Spacing"
    case .fill:
      return "Fill"
    case .fillEqually:
      return "Fill Equally"
    case .fillProportionally:
      return "Fill Proportionally"
    @unknown default:
      return "Unknown"
    }
  }
}
