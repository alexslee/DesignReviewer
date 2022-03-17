//
//  DesignReviewCustomEnumAttribute.swift
//  
//
//  Created by Alex Lee on 3/16/22.
//

import Foundation

/// An enum custom attribute you wish to inspect.
public struct DesignReviewCustomEnumAttribute<T>: DesignReviewCustomAttribute, Hashable where T: ReviewableDescribing, T.RawValue == Int {
  /// The string that will be displayed in the main text label of the entry in the `DesignReviewer`
  public let title: String
  /// The keyPath for the given attribute. The property you wish to inspect MUST BE KVC-compliant!
  public let keyPath: String
  /// The group under which the attribute will be shown
  public let group: DesignReviewInspectorAttributeGroup
  /// The closure that runs when you try to mutate the value of the attribute. Use this to properly change the value, and its updated contents
  /// will be automatically fetched by the inspector (since it uses keypath).
  public let modifier: ((_ newValue: Any?, _ reviewable: DesignReviewable?) -> Void)?
  /// An enum value from which the DesignReviewer is able to extract the type. Due to Swift constraints around generics and Alex not wanting
  /// to completely implement type erasure, you just need to provide any random value here for the given enum you're tracking.
  private let associatedEnum: T

  /**
   Initializer for the `DesignReviewCustomEnumAttribute`.

   - Parameters:
     - title: The string that will be displayed in the main text label of the entry in the `DesignReviewer`
     - keyPath: The keyPath for the given attribute. The property you wish to inspect MUST BE KVC-compliant!
     - group: The group under which the attribute will be shown
     - modifier: The closure that runs when you try to mutate the value of the attribute. Use this to properly change the value,
     and its updated contents will be automatically fetched by the inspector (since it uses keypath).
     - associatedEnum: An enum value from which the DesignReviewer is able to extract the type. Due to Swift constraints around generics
     and Alex not wanting to completely implement type erasure because he's a lazy P.O.S., you just need to provide any random value here
     for the given enum you're tracking.
   */
  public init(title: String,
              keyPath: String,
              group: DesignReviewInspectorAttributeGroup = .general,
              modifier: ((Any?, DesignReviewable?) -> Void)? = nil,
              shouldModifyViaAlert: Bool = false,
              associatedEnum: T) {
    self.title = title
    self.keyPath = keyPath
    self.group = group
    self.modifier = modifier
    self.associatedEnum = associatedEnum
  }

  internal func toMutableAttribute(for reviewable: DesignReviewable) -> DesignReviewInspectorAttribute {
    return toEnumAttribute(associatedEnum, for: reviewable)
  }

  private func toEnumAttribute<T>(
    _ item: T,
    for reviewable: DesignReviewable) -> DesignReviewInspectorAttribute where T: ReviewableDescribing, T.RawValue == Int {
    return DesignReviewEnumAttribute<T>(title: title,
                                        subtitle: nil,
                                        keyPath: keyPath,
                                        reviewable: reviewable,
                                        modifier: modifier)
  }

  public static func ==(lhs: DesignReviewCustomEnumAttribute, rhs: DesignReviewCustomEnumAttribute) -> Bool {
    return lhs.title == rhs.title && lhs.keyPath == rhs.keyPath && lhs.group == rhs.group
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(title)
    hasher.combine(keyPath)
    hasher.combine(group)
  }
}
