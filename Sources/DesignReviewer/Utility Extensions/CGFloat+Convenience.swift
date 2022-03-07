//
//  CGFloat+Convenience.swift
//  
//
//  Created by Alex Lee on 3/3/22.
//

import UIKit

// MARK: - Spacing

extension CGFloat {
  /// 4
  static let extraExtraSmall: CGFloat = 4

  /// 8
  static let extraSmall: CGFloat = 8

  /// 12
  static let small: CGFloat = 12

  /// 16
  static let medium: CGFloat = 16

  /// 24
  static let large: CGFloat = 24

  /// 32
  static let extraLarge: CGFloat = 32

  /// 48
  static let extraExtraLarge: CGFloat = 48
}

// MARK: - String formatting

extension CGFloat {
  func toString(prepending: String? = nil, appending: String? = nil, separator: String = "") -> String {
    let formatter = NumberFormatter()
    formatter.maximumFractionDigits = 2
    formatter.minimumFractionDigits = 1
    formatter.numberStyle = .decimal

    guard let formattedNumber = formatter.string(from: self as NSNumber) else { return "" }

    let rawStringBuild = [prepending, formattedNumber, appending]
    let nilSafeBuild = rawStringBuild.compactMap { $0 }

    return nilSafeBuild.joined(separator: separator)
  }
}
