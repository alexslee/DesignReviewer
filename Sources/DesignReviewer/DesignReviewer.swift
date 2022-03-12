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

  internal static var customAttributes = [String: Set<DesignReviewCustomAttribute>]()

  /**
   Spins up the `DesignReviewer`.

   Assuming you've passed in your app/scene window, this should result in the floating eye becoming visible
   in the center of that window's bounds. It can then be dragged out of the way as needed, but while
   it remains visible you are in 'inspect' mode. Simply double tap the floating eye to dismiss and return
   to regular app execution.

   - Parameters:
     - appWindow: The target window through which the `DesignReviewer` should parse.
   */
  public static func start(inAppWindow appWindow: UIWindow?) {
    window = appWindow
    initializeCoordinatorIfNeededAndStart()
  }

  private static func initializeCoordinatorIfNeededAndStart() {
    guard coordinator == nil else {
      coordinator?.start()
      return
    }

    let viewModel = DesignReviewViewModel()
    coordinator = DesignReviewCoordinator(viewModel: viewModel, appWindow: window)
    coordinator?.userDefinedCustomAttributes = customAttributes
    coordinator?.start()
  }

  /**
   Ends the current `DesignReviewer` session.

   Note: Unless you want additional control over when to dismiss, you shouldn't have to call this
   method directly. The tool can already be dismissed by double-tapping on the floating eye itself.
   */
  public static func finish() {
    coordinator?.finish()
    coordinator?.userDefinedCustomAttributes.removeAll()
    coordinator = nil
    window = nil
  }

  // MARK: - Custom Attributes

  /**
   Add a custom attribute that will be shown for reviewable objects in the DesignReviewer. For now,
   values must be key-value coding-compliant properties of the target reviewable!! In most cases, this
   is achievable by adding `@objc dynamic` in front of the property declaration for Swift properties. See
   the `dummyString` computed property in the UILabel+CustomAttribute of the sample project for an example.
   */
  public static func addCustomAttribute<T: DesignReviewable>(_ attribute: DesignReviewCustomAttribute,
                                                             to reviewable: T.Type) {
    let key = String(describing: reviewable)
    if customAttributes[key] == nil {
      customAttributes[key] = Set<DesignReviewCustomAttribute>()
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
      customAttributes.removeAll()
      return
    }

    let key = String(describing: nilSafeReviewable)
    customAttributes[key]?.removeAll()
  }
}

/// A custom attribute you wish to inspect.
public struct DesignReviewCustomAttribute: Hashable {
  /// The string that will be displayed in the main text label of the entry in the `DesignReviewer`
  public let title: String
  /// The keyPath for the given attribute. The property you wish to inspect MUST BE KVC-compliant!
  public let keyPath: String
  /// The group under which the attribute will be shown
  public let group: DesignReviewInspectorAttributeGroup

  public init(title: String, keyPath: String, group: DesignReviewInspectorAttributeGroup = .general) {
    self.title = title
    self.keyPath = keyPath
    self.group = group
  }

  internal func toMutableAttribute(for reviewable: DesignReviewable) -> DesignReviewMutableAttribute {
    DesignReviewMutableAttribute(title: title, keyPath: keyPath, reviewable: reviewable)
  }
}
