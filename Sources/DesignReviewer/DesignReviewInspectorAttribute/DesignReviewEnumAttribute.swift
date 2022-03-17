//
//  DesignReviewEnumAttribute.swift
//
//
//  Created by Alex Lee on 3/4/22.
//

import Foundation

/// Protocol that any enum must conform to if it is to be displayed in the inspector VC's table.
public protocol ReviewableDescribing: DesignReviewAttributeOptionSelectable, CaseIterable, Hashable, RawRepresentable {
  var displayName: String { get }
}

/// Pretty much the same as a dynamic attribute, but for an enum value.
class DesignReviewEnumAttribute<T>: DesignReviewInspectorAttribute,
                                    Equatable where T: ReviewableDescribing, T.RawValue == Int {
  let keyPath: String
  let subtitle: String?
  let title: String

  var value: Any? {
    guard let value = reviewable?.value(forKeyPath: keyPath) as? Int,
      let enumRep = T(rawValue: value) else {
        fatalError()
    }

    return enumRep.displayName
  }

  var isModifiable: Bool { modifier != nil }
  var isAlertable: Bool { isModifiable }

  private(set) var modifier: ((Any?, DesignReviewable?) -> Void)?

  var alertableOptions: [DesignReviewAttributeOptionSelectable] {
    T.allCases.compactMap({ $0 as DesignReviewAttributeOptionSelectable })
  }

  private(set) weak var reviewable: DesignReviewable?

  init(title: String?,
       subtitle: String? = nil,
       keyPath: String,
       reviewable: DesignReviewable,
       modifier: ((Any?, DesignReviewable?) -> Void)? = nil) {
    self.title = title ?? keyPath.capitalized
    self.subtitle = subtitle
    self.keyPath = keyPath
    self.reviewable = reviewable
    self.modifier = modifier
  }

  static func == (lhs: DesignReviewEnumAttribute<T>, rhs: DesignReviewEnumAttribute<T>) -> Bool {
    return lhs.reviewable === rhs.reviewable && lhs.keyPath == rhs.keyPath
  }
}
