//
//  UILabel+CustomAttribute.swift
//  DesignReviewerExample
//
//  Created by Alex Lee on 3/7/22.
//

import Foundation
import UIKit

extension UILabel {
  /// Example of a KVC-compliant value that may be tracked. See the `AppDelegate` of this sample project,
  /// for how this is indicated to the `DesignReviewer`.
  @objc dynamic var dummyString: String {
    return "\(Int.random(in: 1..<5000))"
  }
}
