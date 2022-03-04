//
//  UIFont+Presets.swift
//  
//
//  Created by Alex Lee on 3/3/22.
//

import UIKit

extension UIFont {
  private static func font(size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
    return .systemFont(ofSize: size, weight: weight)
  }

  static var title: UIFont { font(size: 24, weight: .semibold) }
  static var titleSubdued: UIFont { font(size: 24) }
  static var header: UIFont { font(size: 18, weight: .semibold) }
  static var subHeader: UIFont { font(size: 14, weight: .semibold) }
  static var body: UIFont { font(size: 16) }
  static var bodyStrong: UIFont { font(size: 16, weight: .semibold) }
  static var bodySmall: UIFont { font(size: 14) }
  static var bodySmallStrong: UIFont { font(size: 14, weight: .semibold) }
  static var price: UIFont { font(size: 18, weight: .semibold) }
  static var callOut: UIFont { font(size: 12, weight: .semibold) }
  static var finePrint: UIFont { font(size: 12) }
}
