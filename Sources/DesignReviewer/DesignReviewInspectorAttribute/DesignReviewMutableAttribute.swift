//
//  DesignReviewMutableAttribute.swift
//
//
//  Created by Alex Lee on 3/3/22.
//

import Foundation

/**
 An attribute that is fetched on-demand when required for display in the inspector.

 It's named 'mutable' as this refers to an inspectable attribute whose value is:
 1) fetched when it is needed to be shown, rather than storing a static value on initialization.
 2) able to be configured such that it becomes mutable at runtime (values such as constraint constants
 could be adjusted for quick tests of layout changes).
 */
class DesignReviewMutableAttribute: DesignReviewInspectorAttribute, Equatable {
  let keyPath: String
  let subtitle: String?
  let title: String

  var value: Any? {
    return reviewable?.value(forKeyPath: keyPath)
  }

  var isModifiable: Bool { modifier != nil }
  let isAlertable: Bool
  let modifierIncrementSize: Double
  let modifierRange: ClosedRange<Double>?
  private(set) var modifier: ((Any) -> Void)?

  private(set) weak var reviewable: DesignReviewable?

  init(title: String?,
       subtitle: String? = nil,
       keyPath: String,
       reviewable: DesignReviewable,
       modifier: ((Any) -> Void)? = nil,
       modifierIncrementSize: Double = 4,
       modifierRange: ClosedRange<Double>? = nil,
       shouldModifyViaAlert: Bool = false) {
    self.title = title ?? keyPath.localizedCapitalized
    self.subtitle = subtitle
    self.keyPath = keyPath
    self.reviewable = reviewable
    self.modifier = modifier
    self.modifierIncrementSize = modifierIncrementSize
    self.modifierRange = modifierRange
    self.isAlertable = shouldModifyViaAlert
  }

  static func == (lhs: DesignReviewMutableAttribute, rhs: DesignReviewMutableAttribute) -> Bool {
    return lhs.reviewable === rhs.reviewable && lhs.keyPath == rhs.keyPath
  }
}
