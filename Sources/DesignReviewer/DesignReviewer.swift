//
//  DesignReviewer.swift
//
//
//  Created by Alex Lee on 3/3/22.
//

import Foundation
import UIKit

/**
 The app's interface with the `DesignReviewer` tool. Use this to present the reviewer whenever
 you wish (in response to a button press, a gesture, etc.).
 */
public class DesignReviewer {
  private static var coordinator: DesignReviewCoordinator?

  internal static var window: UIWindow?

  internal static var customAttributes = [String: DesignReviewCustomAttributeSet]()

  internal static var onFinish: (() -> Void)?

  /**
   Spins up the `DesignReviewer`.

   Assuming you've passed in your app/scene window, this should result in the floating eye becoming visible
   in the center of that window's bounds. It can then be dragged out of the way as needed, but while
   it remains visible you are in 'inspect' mode. Simply double tap the floating eye to dismiss and return
   to regular app execution.

   - Parameters:
     - appWindow: The target window through which the `DesignReviewer` should parse.
     - onFinish: Optionally, you can provide a closure you would like to execute when the DesignReviewer is dismissed.
   */
  public static func start(inAppWindow appWindow: UIWindow?, onFinish: (() -> Void)? = nil) {
    window = appWindow
    self.onFinish = onFinish
    initializeCoordinatorIfNeededAndStart()
  }

  private static func initializeCoordinatorIfNeededAndStart() {
    guard coordinator == nil else {
      coordinator?.userDefinedCustomAttributes = customAttributes
      coordinator?.onFinish = onFinish
      coordinator?.start()
      return
    }

    let viewModel = DesignReviewViewModel()
    coordinator = DesignReviewCoordinator(viewModel: viewModel, appWindow: window)
    coordinator?.userDefinedCustomAttributes = customAttributes
    coordinator?.onFinish = onFinish
    coordinator?.start()
  }

  /**
   Ends the current `DesignReviewer` session.

   Note: Unless you want additional control over when to dismiss, you shouldn't have to call this
   method directly. The tool can already be dismissed by double-tapping on the floating eye itself.
   */
  public static func finish() {
    coordinator?.finish()
    coordinator?.userDefinedCustomAttributes.values.forEach({ $0.removeAll() })
    coordinator?.userDefinedCustomAttributes.removeAll()
    coordinator = nil
    window = nil
  }

  // MARK: - Custom Attributes

  /**
   Add a custom mutable attribute that will be shown for reviewable objects in the DesignReviewer. For now,
   values must be key-value coding-compliant properties of the target reviewable!! In most cases, this
   is achievable by adding `@objc dynamic` in front of the property declaration for Swift properties. See
   the `dummyString` computed property in the UILabel+CustomAttribute of the sample project for an example.
   */
  public static func addCustomMutableAttribute<T: DesignReviewable>(_ attribute: DesignReviewCustomMutableAttribute,
                                                                    to reviewable: T.Type) {
    let key = String(describing: reviewable)
    if customAttributes[key] == nil {
      customAttributes[key] = DesignReviewCustomAttributeSet()
    }

    customAttributes[key]?.insert(attribute)
  }

  /**
   Add a custom enum-based attribute that will be shown for reviewable objects in the DesignReviewer. For now,
   values must be key-value coding-compliant properties of the target reviewable!! In most cases, this
   is achievable by adding `@objc dynamic` in front of the property declaration for Swift properties. See
   the `dummyEnum` computed property in the UILabel+CustomAttribute of the sample project for an example.
   */
  public static func addCustomEnumAttribute<T: DesignReviewable, EnumDescribing: ReviewableDescribing>(
    _ attribute: DesignReviewCustomEnumAttribute<EnumDescribing>,
    to reviewable: T.Type) {
      let key = String(describing: reviewable)
      if customAttributes[key] == nil {
        customAttributes[key] = DesignReviewCustomAttributeSet()
      }

      customAttributes[key]?.insert(attribute)
  }

  /**
   Wipes out the list of custom attributes that have been defined thus far for the given reviewable, if any
   such attributes exist.
   - Parameters:
     - reviewable: The type of reviewable object for which you wish to remove the attribute. Note: if no
     `reviewable` is specified, then **ALL** custom attributes will be removed.
   */
  public static func resetCustomAttributes<T: DesignReviewable>(for reviewable: T.Type? = nil) {
    guard let nilSafeReviewable = reviewable else {
      customAttributes.values.forEach({ $0.removeAll() })
      customAttributes.removeAll()
      return
    }

    let key = String(describing: nilSafeReviewable)
    customAttributes[key]?.removeAll()
  }
}

/// Wrapper around a set, to allow for generics to be utilized in conjunction with the AnyHashable needed for sets
internal class DesignReviewCustomAttributeSet {
  private(set) var set = Set<AnyHashable>()

  func iterate(performing action: ((DesignReviewCustomAttribute) -> Void)?) {
    for item in set {
      // cast should never fail since only the `insert` method can be used to add, and it only accepts that type
      action?(item as! DesignReviewCustomAttribute)
    }
  }

  func merge(with otherSet: DesignReviewCustomAttributeSet) {
    set = set.union(otherSet.set)
  }

  func insert<T>(_ item: T) where T: DesignReviewCustomAttribute & Hashable {
      set.insert(AnyHashable(item))
  }

  func removeAll() {
    set.removeAll()
  }
}
