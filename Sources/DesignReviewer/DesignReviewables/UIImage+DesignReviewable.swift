//
//  UIImage+DesignReviewable.swift
//
//
//  Created by Alex Lee on 3/4/22.
//

import Foundation
import UIKit

extension UIImage: DesignReviewable {
  func createReviewableAttributes() -> [DesignReviewInspectorAttributeGroup: [DesignReviewInspectorAttribute]] {
    var attributes = [DesignReviewInspectorAttributeGroup: [DesignReviewInspectorAttribute]]()

    attributes[.preview] = [DesignReviewInspectorAttribute]()
    attributes[.preview]?.append(DesignReviewPreviewAttribute(image: self))

    attributes[.appearance] = [DesignReviewInspectorAttribute]()
    attributes[.appearance]?.append(DesignReviewEnumAttribute<UIImage.RenderingMode>(
      title: "Rendering Mode",
      keyPath: "renderingMode",
      reviewable: self))

    return attributes
  }
}
