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
  case preview

  case accessibility
  case typography
  case appearance
  case behaviour
  case general

  case horizontal
  case vertical
  case hugging
  case resistance
  case constraints
  case layout

  case classes
  case views
  case controllers

  var title: String { rawValue.localizedCapitalized }
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
