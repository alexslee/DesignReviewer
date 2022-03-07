//
//  DesignReviewInspectorAttribute.swift
//  
//
//  Created by Alex Lee on 3/3/22.
//

import Foundation
import UIKit

/// Represents a section of the inspector VC's table view.
/// Each section is a collection of `DesignReviewInspectorAttribute`s.
enum DesignReviewInspectorAttributeGroup: String, CaseIterable {
  // these aren't alphabetical because they are iterated upon via CaseIterable, to construct the table
  case summary
  case screenshot

  case typography
  case styling
  case general
  case accessibility

  case contentHugging
  case compressionResistance
  case constraints
  case generalLayout

  case viewHierarchy
  case classHierarchy

  var title: String {
    switch self {
    case .screenshot:
      return "Live Screenshot"
    case .contentHugging:
      return "Content Hugging"
    case .compressionResistance:
      return "Compression Resistance"
    case .generalLayout:
      return "Other Layout Values"
    case .viewHierarchy:
      return "Nearby View Hierarchy"
    case .classHierarchy:
      return "🦸🏻 Superclass Chain"
    default:
      return rawValue.localizedCapitalized
    }
  }
}

/// Any property of a `DesignReviewable` that is displayable in the Design Review inspector.
protocol DesignReviewInspectorAttribute: CustomStringConvertible {
  /// Keypath of the attribute. Used to fetch the values of dynamic + enum attributes via `value(forKeyPath:)`.
  var keyPath: String { get }

  /// Copy displayed in the detail label of the attribute's cell in the Design Review inspector.
  var subtitle: String? { get }

  /// Copy displayed in the title label of the attribute's cell in the Design Review inspector.
  var title: String { get }

  /// Value of the attribute. Used to provide the value for static attributes, rather than the keypath access.
  var value: Any? { get }

  /// Whether or not the attribute can be mutated (requires the attribute to have a dedicated closure to handle the change).
  var isModifiable: Bool { get }
}

// MARK: - CustomStringConvertible

extension DesignReviewInspectorAttribute {
  var description: String {
    let valueStr: String
    if let value = value {
      valueStr = "\(value)"
    } else {
      valueStr = "nil"
    }

    return "\(title) – \(keyPath) | " + valueStr
  }
}

// MARK: - Default implementation

extension DesignReviewInspectorAttribute {
  var isModifiable: Bool { false }
}
