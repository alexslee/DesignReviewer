//
//  DesignReviewPreviewAttribute.swift
//
//
//  Created by Alex Lee on 3/3/22.
//

import Foundation
import UIKit

/// A summary entry that can be added to the inspector for any given `DesignReviewable`.
class DesignReviewSummaryAttribute: DesignReviewInspectorAttribute {
  let keyPath = ""
  var subtitle: String?
  var title: String
  var value: Any?

  var image: UIImage?

  init(title: String, subtitle: String?, image: UIImage?) {
    self.title = title
    self.subtitle = subtitle
    self.image = image
  }
}
