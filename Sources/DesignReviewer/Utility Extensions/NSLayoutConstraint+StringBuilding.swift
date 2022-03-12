//
//  NSLayoutConstraint+StringBuilding.swift
//  
//
//  Created by Alex Lee on 3/11/22.
//

import Foundation
import UIKit

extension NSLayoutConstraint {
  private var firstAttributeName: String { firstAttribute.displayName }

  private var firstItemAsViewName: String {
    guard let firstItem = firstItem as? UIView else { return "--" }

    return firstItem.summaryDisplayName
  }

  private var secondAttributeName: String { secondAttribute.displayName }

  private var secondItemAsViewName: String {
    guard let secondItem = secondItem as? UIView else { return "--" }

    return secondItem.summaryDisplayName
  }

  /// Concatenates the views of this particular constraint ('--' indicates no view)
  var summaryDisplayName: String {
    [firstItemAsViewName, secondItemAsViewName].joined(separator: " to \n")
  }

  /// Concatenates the attributes of this particular constraint
  var summaryDescription: String {
    [firstAttributeName, secondAttributeName].joined(separator: " to ")
  }
}
