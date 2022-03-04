//
//  UIView+Constraints.swift
//  
//
//  Created by Alex Lee on 3/3/22.
//

import UIKit

extension UIView {
  /**
   Returns a list of `NSLayoutConstraint`s between self and the given view.
   Note that the `left` and `right` `UIRectEdge`s will match up to the given view's `leadingAnchor`
   and `trailingAnchor` respectively.

   - Parameters:
       - view: The view to constrain to.
       - edges: The desired edges to match.
       - inset: The equal inset applied to the view

   - Returns: The array of layout constraints created
   */
  func constraints(toView view: UIView,
                   edges: UIRectEdge = [.all],
                   withEqualInset inset: CGFloat) -> [NSLayoutConstraint] {
    return constraints(
      toView: view,
      edges: edges,
      withInsets: UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset))
  }

  /**
   Returns a list of `NSLayoutConstraint`s between self and the given view.
   Note that the `left` and `right` `UIRectEdge`s will match up to the given view's `leadingAnchor`
   and `trailingAnchor` respectively.

   - Parameters:
       - view: The view to constrain to.
       - edges: The desired edges to match.
       - insets: The desired insets for each edge constraint.

   - Returns: The array of layout constraints created
   */
  func constraints(toView view: UIView,
                   edges: UIRectEdge = [.all],
                   withInsets insets: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
    var constraints = [NSLayoutConstraint]()

    if edges.contains(.left) {
      constraints.append(leadingAnchor.constraint(
        equalTo: view.leadingAnchor, constant: insets.left))
    }

    if edges.contains(.right) {
      constraints.append(trailingAnchor.constraint(
        equalTo: view.trailingAnchor, constant: -insets.right))
    }

    if edges.contains(.top) {
      constraints.append(topAnchor.constraint(
        equalTo: view.topAnchor, constant: insets.top))
    }

    if edges.contains(.bottom) {
      constraints.append(bottomAnchor.constraint(
        equalTo: view.bottomAnchor, constant: -insets.bottom))
    }

    return constraints
  }

  /**
   Returns a list of `NSLayoutConstraint`s between self and the given layout guide.
   Note that the `left` and `right` `UIRectEdge`s will match up to the given layout guide's
   `leadingAnchor` and  `trailingAnchor` respectively.

   - Parameters:
       - guide: The layout guide to constrain to.
       - edges: The desired edges to match.
       - insets: The desired insets for each edge constraint.

   - Returns: The array of layout constraints created
   */
  func constraints(toGuide guide: UILayoutGuide,
                   edges: UIRectEdge = [.all],
                   withInsets insets: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
    var constraints = [NSLayoutConstraint]()

    if edges.contains(.left) {
      constraints.append(leadingAnchor.constraint(
        equalTo: guide.leadingAnchor, constant: insets.left))
    }

    if edges.contains(.right) {
      constraints.append(trailingAnchor.constraint(
        equalTo: guide.trailingAnchor, constant: -insets.right))
    }

    if edges.contains(.top) {
      constraints.append(topAnchor.constraint(
        equalTo: guide.topAnchor, constant: insets.top))
    }

    if edges.contains(.bottom) {
      constraints.append(bottomAnchor.constraint(
        equalTo: guide.bottomAnchor, constant: -insets.bottom))
    }

    return constraints
  }
}
