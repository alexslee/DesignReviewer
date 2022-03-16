//
//  UILabel+CustomAttribute.swift
//  DesignReviewerExample
//
//  Created by Alex Lee on 3/7/22.
//

import Foundation
import UIKit
import DesignReviewer

var globalDummyEnum: MyDummyEnum = .first

extension UILabel {
  /// Example of a KVC-compliant value that may be tracked. See the `AppDelegate` of this sample project,
  /// for how this is indicated to the `DesignReviewer`.
  @objc dynamic var dummyString: String {
    return "\(Int.random(in: 1..<5000))"
  }

  /// This enum functionality is admittedly limited. You could in theory have something run on the setter that updates a meaningful property of the UILabel here.
  /// For example, text, or color. Since there's nothing to do in this dummy project with this label right now, it's just updating a global to show that
  /// the value does update and callbacks are triggered in the same fashion as the default tracked attributes.
  @objc dynamic var dummyEnum: MyDummyEnum {
    get {
      return globalDummyEnum
    }
    set {
      globalDummyEnum = newValue
    }
  }
}

@objc enum MyDummyEnum: Int, ReviewableDescribing {
  case first, second, third, fourth

  static var allCases: [MyDummyEnum] {
    [first, second, third, fourth]
  }

  var displayName: String {
    switch self {
    case .first:
      return "first"
    case .second:
      return "second"
    case .third:
      return "third"
    case .fourth:
      return "fourth"
    }
  }
}
