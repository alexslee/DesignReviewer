//
//  DesignReviewCustomMutableAttribute.swift
//  
//
//  Created by Alex Lee on 3/16/22.
//

import Foundation

/// Wrapper protocol for custom attributes you wish to inspect.
protocol DesignReviewCustomAttribute {
  var group: DesignReviewInspectorAttributeGroup { get }
  func toMutableAttribute(for reviewable: DesignReviewable) -> DesignReviewInspectorAttribute
}

/// A mutable custom attribute you wish to inspect.
public struct DesignReviewCustomMutableAttribute: DesignReviewCustomAttribute, Hashable {
  /// The string that will be displayed in the main text label of the entry in the `DesignReviewer`
  public let title: String
  /// The keyPath for the given attribute. The property you wish to inspect MUST BE KVC-compliant!
  public let keyPath: String
  /// The group under which the attribute will be shown
  public let group: DesignReviewInspectorAttributeGroup
  /// The closure that runs when you try to mutate the value of the attribute. Use this to properly change the value, and its updated contents
  /// will be automatically fetched by the inspector (since it uses keypath).
  public let modifier: ((_ newValue: Any?, _ reviewable: DesignReviewable?) -> Void)?
  /// Whether or not the editing should be displayed as an alert. Alerts support enums conforming to `ReviewableDescribing`, as well as Strings.
  public let shouldModifyViaAlert: Bool

  public init(title: String,
              keyPath: String,
              group: DesignReviewInspectorAttributeGroup = .general,
              modifier: ((Any?, DesignReviewable?) -> Void)? = nil,
              shouldModifyViaAlert: Bool = false) {
    self.title = title
    self.keyPath = keyPath
    self.group = group
    self.modifier = modifier
    self.shouldModifyViaAlert = shouldModifyViaAlert
  }

  internal func toMutableAttribute(for reviewable: DesignReviewable) -> DesignReviewInspectorAttribute {
      return DesignReviewMutableAttribute(title: title,
                                          keyPath: keyPath,
                                          reviewable: reviewable,
                                          modifier: modifier,
                                          shouldModifyViaAlert: shouldModifyViaAlert)
  }

  public static func ==(lhs: DesignReviewCustomMutableAttribute, rhs: DesignReviewCustomMutableAttribute) -> Bool {
    return lhs.title == rhs.title && lhs.keyPath == rhs.keyPath && lhs.group == rhs.group
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(title)
    hasher.combine(keyPath)
    hasher.combine(group)
  }
}
