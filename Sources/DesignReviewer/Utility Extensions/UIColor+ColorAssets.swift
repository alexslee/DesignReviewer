//
//  UIColor+ColorAssets.swift
//  
//
//  Created by Alex Lee on 3/3/22.
//

import UIKit

extension UIColor {
  static func color(named name: String) -> UIColor {
    guard let color = UIColor(named: name, in: .module, compatibleWith: nil) else {
      preconditionFailure("Missing color from asset catalog")
    }

    return color
  }

  static var background: UIColor { color(named: "background") }

  static var monochrome0: UIColor { color(named: "monochrome0") }
  static var monochrome1: UIColor { color(named: "monochrome1") }
  static var monochrome2: UIColor { color(named: "monochrome2") }
  static var monochrome4: UIColor { color(named: "monochrome4") }
  static var monochrome5: UIColor { color(named: "monochrome5") }

  static var primary2: UIColor { color(named: "primary2") }
  static var primary3: UIColor { color(named: "primary3") }
  static var primary4: UIColor { color(named: "primary4") }

  static var success3: UIColor { color(named: "success3") }

  var hexString: String {
    return "#" + String(format: "%02X%02X%02X", Int(rgba.red * 255), Int(rgba.green * 255), Int(rgba.blue * 255))
  }

  var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    getRed(&red, green: &green, blue: &blue, alpha: &alpha)

    return (red, green, blue, alpha)
  }
}

class UIColorValueTransformer: ValueTransformer {
  override func transformedValue(_ value: Any?) -> Any? {
    if let value = value as? UIColor {
      if value == .clear {
        return "Clear"
      } else if value.cgColor.pattern != nil {
        return "Pattern"
      }

      return value.rgba.alpha == 0 ? "Transparent" : value.hexString
    } else if CFGetTypeID(value as CFTypeRef) == CGColor.typeID {
      // swiftlint:disable force_cast
      let cgValue = value as! CGColor
      let color = UIColor(cgColor: cgValue)
      return color.rgba.alpha == 0 ? "Clear" : color.hexString
    }

    return "nil"
  }

  override class func allowsReverseTransformation() -> Bool {
    return false
  }
}
