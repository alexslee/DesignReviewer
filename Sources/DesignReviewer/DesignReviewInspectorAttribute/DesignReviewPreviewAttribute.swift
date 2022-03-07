//
//  DesignReviewPreviewAttribute.swift
//
//
//  Created by Alex Lee on 3/3/22.
//

import Foundation
import UIKit

/// The image preview that can be added to the inspector for any given `DesignReviewable`.
class DesignReviewPreviewAttribute: DesignReviewInspectorAttribute {
  let keyPath: String
  let subtitle: String? = nil
  let title: String
  let value: Any?

  var image: UIImage? {
    return value as? UIImage
  }

  init(image: UIImage) {
    title = ""
    value = image
    keyPath = "nada"
  }
}
