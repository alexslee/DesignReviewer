//
//  DesignReviewable.swift
//
//
//  Created by Alex Lee on 3/3/22.
//

import Foundation
import UIKit

/**
 Defines methods + properties that are necessary for the Design Review tool to display content to the
 reviewer.

 Any class that conforms to this protocol, becomes a candidate to be inspected by the Design Review tool.
 However, in order to appear in the inspector, it must either:
 1) be iterable in the view hierarchy/be visible on-screen (e.g. a UIButton, a UIStackView, etc.)
 2) be an attribute that is part of a different class that is inspected (e.g. a layout constraint
    on a view).

 Currently provided `DesignReviewable` implementations:
 - NSLayoutConstraint
 - NSString
 - UIColor
 - UIImage
 - UIView
 */
public protocol DesignReviewable: AnyObject {
  /**
   Helps construct strings (and by extension, labels) of the object's actual class name, for display
   in the Design Review tool's table.
   */
  var classForCoder: AnyClass { get }

  /**
   Whether the reviewable object is visible within the current Design Review overlay (read: whether
   it is currently visible on screen).
   */
  var isOnScreen: Bool { get }

  /**
   Defines list of child objects that can the Design Review tool can also inspect. E.g. for views,
   this would typically be its subviews.
   */
  var subReviewables: [DesignReviewable] { get }

  /// Transforms the reviewable object's bounds to the coordinate space of a given target.
  func convertBounds(to target: UIView) -> CGRect

  /// Defines the data source that will power the Design Review tool's table when inspecting the object.
  func createReviewableAttributes() -> [DesignReviewInspectorAttributeGroup: [DesignReviewInspectorAttribute]]

  /**
   Allows for keypath access to arbitrary properties on objects conforming to `DesignReviewable`.
   Intended for the inspector to be able to obtain reviewable attributes dynamically.
   */
  func value(forKeyPath: String) -> Any?
}

// MARK: - Default implementations

extension DesignReviewable {
  public var isOnScreen: Bool { false }

  public var subReviewables: [DesignReviewable] { [] }

  public func convertBounds(to target: UIView) -> CGRect {
    return .zero
  }
}
