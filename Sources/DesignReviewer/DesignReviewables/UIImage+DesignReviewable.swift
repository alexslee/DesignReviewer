//
//  UIImage+DesignReviewable.swift
//
//
//  Created by Alex Lee on 3/4/22.
//

import Foundation
import UIKit

extension UIImage: DesignReviewable {
  public func createReviewableAttributes() -> [DesignReviewInspectorAttributeGroup: [DesignReviewInspectorAttribute]] {
    var attributes = [DesignReviewInspectorAttributeGroup: [DesignReviewInspectorAttribute]]()

    attributes[.screenshot] = [DesignReviewInspectorAttribute]()
    attributes[.screenshot]?.append(DesignReviewScreenshotAttribute(image: self))

    attributes[.styling] = [DesignReviewInspectorAttribute]()
    attributes[.styling]?.append(DesignReviewEnumAttribute<UIImage.RenderingMode>(
      title: "Rendering Mode",
      keyPath: "renderingMode",
      reviewable: self))

    return attributes
  }

  var displayableSize: String {
    let width = size.width.toString()
    let height = size.height.toString()

    return "\(width)w x \(height)h"
  }
}
