//
//  UIView+StringBuilding.swift
//  
//
//  Created by Alex Lee on 3/4/22.
//

import Foundation
import UIKit

extension UIView {
  /// convenience computed property that grabs the full tree of subviews, not just immediate children
  private var allSubviews: [UIView] {
    subviews.reversed().flatMap { [$0] + $0.allSubviews }
  }

  /// Constructs a string for the view's bounds
  private var boundsDescription: String {
    let boundsString = [
      bounds.origin.x.toString(prepending: "(x:", separator: " "),
      bounds.origin.y.toString(prepending: "y:", separator: " "),
      bounds.size.width.toString(prepending: "w:", separator: " "),
      bounds.size.height.toString(prepending: "h:", separator: " ")
    ].joined(separator: ", ")
    return "Bounds: \(boundsString))"
  }

  /// Constructs a string for the view's counts of immediate children + complete set of subviews
  private var childrenAndSubviewsDescription: String? {
    guard !subviews.isEmpty else { return nil }

    // count of immediate children
    let children = subviews.count == 1 ? "1 child" : "\(subviews.count) children"
    // count of fully traversed subviews
    let traversedSubviews = allSubviews
    let subviews = traversedSubviews.count == 1 ? "1 subview" : "\(traversedSubviews.count) subviews"

    return "\(children); \(subviews) overall"
  }

  /// Constructs a string for the view's frame
  private var frameDescription: String {
    let frameString = [
      frame.origin.x.toString(prepending: "(x:", separator: " "),
      frame.origin.y.toString(prepending: "y:", separator: " "),
      frame.size.width.toString(prepending: "w:", separator: " "),
      frame.size.height.toString(prepending: "h:", separator: " ")
    ].joined(separator: ", ")
    return "Frame: \(frameString))"
  }

  /// Removes any weird garbled mess that can come with classForCoder
  private var strippedClassName: String {
    let className = String(describing: classForCoder)
    guard let nameWithoutQualifiers = className.split(separator: "<").first else { return className }

    return String(nameWithoutQualifiers)
  }

  /// Concatenates some of the strings in this extension for use in the summary view
  var summaryDescription: String {
    let desc = [childrenAndSubviewsDescription, frameDescription, boundsDescription, superclassName]
    return desc.compactMap({ $0 }).joined(separator: "\n")
  }

  /// Concatenates the strippedClassName with accessibility info, if there is any
  var summaryDisplayName: String {
    if let textContainer = self as? TextContainingView {
      let name = truncatedAccessibilityIdentifier ?? textContainer.strippedClassName
      if let textContent = textContainer.content?.prefix(30) {
        return "\"\(textContent)\" (\(name))"
      }
      return "\(name) - no text content"
    }

    if let identifier = truncatedAccessibilityIdentifier {
      return "\(strippedClassName) (\(identifier))"
    }

    return strippedClassName
  }

  /// Constructs a string for the view's superclass
  private var superclassName: String {
    guard let superclass = superclass else { return "🦸🏻 Superclass: nil" }
    return "🦸🏻 Superclass: " + String(describing: superclass)
  }

  /// Pared down accessibility identifier
  private var truncatedAccessibilityIdentifier: String? {
    guard let subSequence = accessibilityIdentifier?.split(separator: ".").last else { return nil }
    return String(subSequence)
  }
}
